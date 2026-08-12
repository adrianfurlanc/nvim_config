-- Helper functions (formerly autoload/functions.vim; the module is only
-- read from disk on the first require(), then cached).

local M = {}

-- Open a file in Marked for a rendered preview (see the :Preview command in
-- ftplugin/markdown.lua). Marked watches the file it was given and re-renders
-- on every write, so this only needs to run once per file: leave it open on a
-- second monitor and it follows along as you save.
--
-- Launched by name rather than by path or bundle id on purpose. The Setapp
-- build lives at /Applications/Setapp/Marked.app with the bundle id
-- com.brettterpstra.marked-setapp, which differs from both the direct-download
-- and App Store builds; asking LaunchServices for "Marked" finds whichever one
-- is installed, and keeps working if Setapp moves or updates the bundle.
local preview_app = 'Marked'

function M.preview(file)
	-- No argument: preview the current buffer's file.
	local is_current = file == nil or file == ''
	local path = is_current and vim.fn.expand('%:p') or vim.fn.fnamemodify(file, ':p')

	if path == '' then
		vim.notify('Preview: buffer has no file name; write it first', vim.log.levels.ERROR)
		return
	end
	if vim.fn.filereadable(path) == 0 then
		vim.notify('Preview: no such file on disk: ' .. path, vim.log.levels.ERROR)
		return
	end

	-- Marked renders what is on disk, so an unsaved buffer previews as its
	-- last-written state. Not auto-writing here: :Preview shouldn't have the
	-- side effect of saving. The next :w brings Marked in sync by itself.
	if is_current and vim.bo.modified then
		vim.notify('Preview: showing last saved version (buffer is modified)', vim.log.levels.WARN)
	end

	-- Async so nvim doesn't block on the app launch (cold start is slow).
	-- Passing argv, not a shell string, so paths with spaces need no quoting —
	-- which matters here, given ~/Desktop/Vibe Coding and the iCloud vault.
	vim.system({ 'open', '-a', preview_app, path }, { text = true }, function(result)
		if result.code ~= 0 then
			-- Callback runs in a fast event context, where notify is unsafe.
			vim.schedule(function()
				local detail = (result.stderr or ''):gsub('%s+$', '')
				vim.notify('Preview failed: ' .. (detail ~= '' and detail or 'open exited ' .. result.code),
					vim.log.levels.ERROR)
			end)
		end
	end)
end

-- Whole-project checks into the quickfix list, behind the :Lint, :Eslint,
-- :Stylelint, :Typecheck and :AstroCheck commands (see lua/config/keymaps.lua).
-- coc only reports diagnostics for buffers that are actually open; these run
-- the real CLI across the project and fill the quickfix list, which the
-- <Up>/<Down>/<Left>/<Right> mappings already walk.

-- Appended to the project root for tools that want file arguments rather than
-- a directory. Kept here, keyed by compiler, so a target is described once:
-- :Stylelint, :Lint and the merged runner all read it from this table.
local target_glob = { stylelint = '/**/*.{css,astro,html}' }

-- The project the current buffer belongs to, or nil (having said why).
local function project_root()
	local source = vim.api.nvim_buf_get_name(0)
	if source == '' then
		source = vim.uv.cwd()
	end
	local root = vim.fs.root(source, { 'package.json', '.git' })
	if not root then
		vim.notify('No package.json or .git above ' .. source, vim.log.levels.ERROR)
	end
	return root
end

-- Write the buffer first. Every one of these tools reads from disk, so an
-- unsaved buffer gets checked in its last-written state — the errors you are
-- looking at go unreported and the run looks like a false negative. This is
-- what 'autowrite' does for :make; done explicitly here rather than by setting
-- that option, which would also write on :next, :cnext and friends. :update is
-- a no-op when the buffer is unmodified.
--
-- Only the current buffer, same as 'autowrite'. Use :wall first if other
-- buffers in the project are also dirty.
local function write_current_buffer()
	if vim.api.nvim_buf_get_name(0) ~= '' and vim.bo.modified and vim.bo.buftype == '' then
		vim.cmd('update')
	end
end

-- Run one check through vim-dispatch, which owns the quickfix list for the
-- duration. The target is passed to :Make instead of being baked into
-- 'makeprg' so the compiler plugins stay project-agnostic, and it is
-- shell-escaped because these projects live under ~/Desktop/Vibe Coding — an
-- unquoted path with a space would be split into two arguments. Escaping also
-- stops the shell expanding the glob, leaving stylelint to expand it.
function M.lint(compiler)
	local root = project_root()
	if not root then
		return
	end
	write_current_buffer()

	vim.cmd('compiler ' .. compiler)
	-- vim-dispatch is lazy-loaded on :Make (see lua/plugins/test.lua), so this
	-- is also what pulls it in; it runs the build asynchronously and populates
	-- the quickfix list when it finishes.
	vim.cmd('Make ' .. vim.fn.shellescape(root .. (target_glob[compiler] or '')))
end

-- What :Lint runs for each filetype. Where several are listed it is because
-- they do not overlap, and any one of them alone answers part of the question
-- while looking like it answered all of it:
--
--   .ts/.tsx  tsc owns types and has no warning severity at all; the rules
--             that do warn — unused bindings and friends — are ESLint's.
--   .astro    `astro check` covers the frontmatter and reports all three
--             severities, but only for TypeScript diagnostics. It is happy
--             with a <style> tag whose `>` is missing, where ESLint reports
--             the parse error and stylelint reports where the CSS then ran
--             off the end. Three tools, three genuinely different answers.
--
-- They run concurrently, so a list costs about as long as its slowest tool.
local checks_for_filetype = {
	astro = { 'astro', 'eslint', 'stylelint' },
	typescript = { 'tsc', 'eslint' },
	typescriptreact = { 'tsc', 'eslint' },
	javascript = { 'eslint' },
	javascriptreact = { 'eslint' },
	css = { 'stylelint' },
	html = { 'stylelint' },
}

-- Read a compiler plugin's command and format without leaving them on the
-- buffer: :compiler is the only way to source after/compiler/*.vim, but the
-- merged runner below needs two of them at once and must not corrupt the
-- buffer's own settings on the way through.
local function compiler_spec(compiler)
	local makeprg, errorformat = vim.bo.makeprg, vim.bo.errorformat
	local name = vim.b.current_compiler
	vim.cmd('compiler ' .. compiler)
	local spec = { makeprg = vim.bo.makeprg, errorformat = vim.bo.errorformat }
	vim.bo.makeprg, vim.bo.errorformat = makeprg, errorformat
	vim.b.current_compiler = name
	return spec
end

-- Build the merged list once every tool has finished, and say what happened.
--
-- Only valid entries are kept, which is also what filters each tool's banners
-- and summary lines: vim-dispatch drops the errorformat's %-G catch-all (its
-- stored format for after/compiler/astro.vim is the first pattern only), so
-- unmatched lines would otherwise arrive as || noise.
--
-- A tool that exits non-zero having produced nothing parseable did not lint —
-- it failed to start. That is reported separately and loudly, because the
-- alternative is an empty quickfix list, which reads exactly like a clean
-- project. Both of those looked identical before this said so out loud.
local function report(results)
	local items, failures, names = {}, {}, {}
	-- One entry per line of a file, whichever tool reported it. A syntax error
	-- makes a parser resynchronise and complain again a few tokens later: a
	-- missing "im" in `import` gets tsc to report "Unexpected keyword or
	-- identifier" at three columns of line 1, and ESLint to report its own
	-- "Parsing error" on the same line. One mistake, four entries to walk past.
	--
	-- Whatever arrives first wins, which is the first tool in the filetype's
	-- list — tsc before ESLint, so a line carrying both keeps the type error
	-- and its precise message rather than ESLint's summary of the same thing.
	--
	-- The cost is that a line with two genuinely different problems reports
	-- only the first: common in CSS, where several rules can fail on one
	-- declaration. Key on `.. ':' .. item.text` as well to get those back.
	local seen = {}
	for _, result in ipairs(results) do
		names[#names + 1] = result.compiler
		local output = (result.done.stdout or '') .. (result.done.stderr or '')
		local lines = vim.split(output, '\n', { trimempty = true })
		local parsed = vim.fn.getqflist({ lines = lines, efm = result.spec.errorformat }).items
		local kept = 0
		for _, item in ipairs(parsed) do
			if item.valid == 1 then
				kept = kept + 1
				local key = item.bufnr .. ':' .. item.lnum
				if not seen[key] then
					seen[key] = true
					items[#items + 1] = item
				end
			end
		end
		if kept == 0 and result.done.code ~= 0 then
			-- The first line mentioning an error, not simply the first line:
			-- npm leads with "npm warn exec The following package was not
			-- found and will be installed", and buries "npx canceled due to
			-- missing packages" — the half that says what to do — underneath.
			local detail = ''
			for _, line in ipairs(lines) do
				if line:lower():find('error') then
					detail = line
					break
				end
			end
			if detail == '' then
				detail = lines[1] or '(no output)'
			end
			failures[#failures + 1] = result.compiler .. ' exited ' .. result.done.code .. ': ' .. detail
		end
	end

	local title = table.concat(names, ' + ')
	vim.fn.setqflist({}, ' ', { title = title, items = items })
	vim.cmd('cwindow')
	-- :cwindow leaves the cursor in the quickfix window; go back to the code,
	-- the way vim-dispatch does after its own :copen.
	if vim.bo.buftype == 'quickfix' then
		vim.cmd('wincmd p')
	end

	if #failures > 0 then
		vim.notify(table.concat(failures, '\n'), vim.log.levels.WARN)
	elseif #items == 0 then
		vim.notify(title .. ': no problems', vim.log.levels.INFO)
	else
		vim.notify(title .. ': ' .. #items .. ' problem' .. (#items == 1 and '' or 's'), vim.log.levels.INFO)
	end
end

-- Run every check for the current buffer's filetype and merge them into one
-- quickfix list. Nothing is guessed when the filetype isn't in the table above
-- — a check picked at random is worse than none, since a clean list would then
-- read as "no problems".
--
-- These go through vim.system() rather than :Make because dispatch owns the
-- whole quickfix list per run: a second :Make would replace the first one's
-- results, and chaining them would flash the window open, shut and open again.
-- Run together here they also run concurrently, so two tools cost about as
-- long as the slower one. The jobs deliberately inherit nvim's directory
-- rather than being given the root: tools report paths relative to where they
-- run, and the quickfix list resolves them relative to nvim, so the two have
-- to agree — which is also what :Make does.
function M.lint_filetype()
	local ft = vim.bo.filetype
	local compilers = checks_for_filetype[ft]
	if not compilers then
		vim.notify(
			'No check configured for filetype ' .. (ft ~= '' and ft or '(none)')
				.. ' — :Eslint, :Stylelint, :Typecheck and :AstroCheck run one directly',
			vim.log.levels.WARN
		)
		return
	end

	local root = project_root()
	if not root then
		return
	end
	write_current_buffer()

	local results, pending = {}, #compilers
	for i, compiler in ipairs(compilers) do
		local spec = compiler_spec(compiler)
		local command = spec.makeprg .. ' ' .. vim.fn.shellescape(root .. (target_glob[compiler] or ''))
		vim.system({ vim.o.shell, '-c', command }, { text = true }, function(done)
			results[i] = { compiler = compiler, spec = spec, done = done }
			pending = pending - 1
			if pending == 0 then
				-- vim.system's callback runs in a fast event context, where
				-- neither the quickfix calls nor vim.notify are allowed.
				vim.schedule(function()
					report(results)
				end)
			end
		end)
	end
end

-- Switch to plaintext mode with: require('functions').plaintext()
function M.plaintext()
	vim.opt_local.linebreak = true
	vim.opt_local.list = false
	vim.opt_local.number = false
	vim.opt_local.textwidth = 0
	vim.opt_local.wrap = true
	vim.opt_local.wrapmargin = 0

	-- Spell-check English and Spanish at once: a word is only flagged when
	-- neither dictionary knows it, so mixed-language notes don't light up.
	-- (The 'es' dictionary is not bundled with nvim; it lives in
	-- ~/.local/share/nvim/site/spell/, downloaded by nvim on first use.)
	--
	-- 'spellfile' is where zg/zw write: pinned to one file next to this config
	-- so the additions are versioned with it, rather than landing in the first
	-- writable 'runtimepath' entry under whichever language happens to be first
	-- in 'spelllang'.
	vim.opt_local.spell = true
	vim.opt_local.spelllang = { 'en', 'es' }
	vim.opt_local.spellfile = vim.fn.expand('~/.config/nvim/spell/en.utf-8.add')

	vim.keymap.set('n', 'j', 'gj', { buffer = true })
	vim.keymap.set('n', 'k', 'gk', { buffer = true })

	-- Ideally would keep 'list' set, and restrict 'listchars' to just show
	-- whitespace errors, but 'listchars' is global and I don't want to go through
	-- the hassle of saving and restoring.
	vim.api.nvim_create_autocmd('BufWinEnter', { buffer = 0, command = [[match Error /\s\+$/]] })
	vim.api.nvim_create_autocmd('InsertEnter', { buffer = 0, command = [[match Error /\s\+\%#\@<!$/]] })
	vim.api.nvim_create_autocmd('InsertLeave', { buffer = 0, command = [[match Error /\s\+$/]] })
	vim.api.nvim_create_autocmd('BufWinLeave', { buffer = 0, callback = function() vim.fn.clearmatches() end })
end

-- Custom fold summary line, used via 'foldtext' (see plugin/settings.lua)
local middot = '·'
local raquo = '»'
local small_l = 'ℓ'

-- Override default `foldtext()`, which produces something like:
--
--   +---  2 lines: source $HOME/.config/nvim/pack/bundle/opt/vim-pathogen/autoload/pathogen.vim--------------------------------
--
-- Instead returning:
--
--   »··[2ℓ]··: source $HOME/.config/nvim/pack/bundle/opt/vim-pathogen/autoload/pathogen.vim···································
--
-- The run of middots is sized so that the text lands at the indent the folded
-- line sits at, keeping closed folds aligned with the code around them.
function M.foldtext()
	local line_count = vim.v.foldend - vim.v.foldstart + 1
	local lines = '[' .. line_count .. small_l .. ']'
	local first = vim.api.nvim_buf_get_lines(0, vim.v.foldstart - 1, vim.v.foldstart, true)[1]
	local whitespace = first:match('^%s*')
	local tabs = whitespace:gsub(' +', ''):len()
	local spaces = whitespace:gsub('\t', ''):len()
	local indent = spaces + tabs * vim.bo.tabstop
	local stripped = first:match('^%s*(.-)$')
	local prefix = raquo .. middot .. middot .. lines
	local suffix = ': '

	-- Can't usefully use string.len() on UTF-8.
	local prefix_len = tostring(line_count):len() + 6

	local dash_count = math.max(indent - prefix_len - string.len(suffix), 0)
	local dashes = string.rep(middot, dash_count)
	return prefix .. dashes .. suffix .. stripped
end

-- Preserve cursor position across commands
function M.preserve(command)
	local search = vim.fn.getreg('/')
	local line = vim.fn.line('.')
	local col = vim.fn.col('.')
	vim.cmd(command)
	vim.fn.setreg('/', search)
	vim.fn.cursor(line, col)
end

-- Cycle through relativenumber + number, number (only), and no numbering
function M.cycle_numbering()
	local transitions = {
		['00'] = { number = true, relativenumber = true },
		['01'] = { number = true, relativenumber = false },
		['10'] = { number = false, relativenumber = false },
		['11'] = { number = true, relativenumber = false },
	}
	local key = (vim.o.number and '1' or '0') .. (vim.o.relativenumber and '1' or '0')
	vim.o.number = transitions[key].number
	vim.o.relativenumber = transitions[key].relativenumber
end

-- Auto-clearing of the message area (see plugin/autocmds.lua).
--
-- Anything echoed below the statusline stays on screen until something else
-- happens to overwrite it. The autocmds that produce such output call
-- schedule_message_clear(), which blanks the area again after 5 seconds.
-- Two kinds of output are exempt and stay up until dismissed with <Leader>L
-- (see plugin/mappings.lua): errors, and :messages output.
local message_timeout = 5000
local message_retry = 1000
local message_timer = -1
local messages_command = [[\C\v^\s*mes%[sages]>]]

function M.clear_message_area()
	-- schedule_message_clear() blanked v:errmsg, so anything in it now came
	-- from the command this clear was scheduled for: leave the error on screen.
	if vim.v.errmsg ~= '' then
		message_timer = -1
		return
	end
	if vim.fn.mode() == 'n' then
		vim.cmd([[echo '']])
		message_timer = -1
	else
		-- Echoing now would clobber an open cmdline, a press-enter prompt or
		-- the text being typed in insert mode ('noshowmode' means insert mode
		-- does not overwrite the message itself). Wait for normal mode.
		message_timer = vim.fn.timer_start(message_retry, M.clear_message_area)
	end
end

function M.cancel_message_clear()
	if message_timer ~= -1 then
		vim.fn.timer_stop(message_timer)
		message_timer = -1
	end
end

function M.schedule_message_clear()
	M.cancel_message_clear()
	-- v:errmsg is not cleared by a later successful command, so blank it now
	-- and read it back in the timer to tell 'this command errored' from 'an
	-- error some time ago'. Done here, not in the autocmd, so it covers the
	-- commands scheduled before they run and the yanks scheduled after.
	vim.v.errmsg = ''
	message_timer = vim.fn.timer_start(message_timeout, M.clear_message_area)
end

-- Clear the message area right now, whatever is in it: the error messages and
-- :messages output the timer deliberately leaves alone. 'redraw' is what
-- actually removes an error and restores the screen after the message area has
-- grown to more than one line.
function M.clear_message_area_now()
	M.cancel_message_clear()
	vim.v.errmsg = ''
	vim.cmd([[echo '']])
	vim.cmd('redraw')
end

function M.on_cmdline_leave()
	if vim.fn.match(vim.fn.getcmdline(), messages_command) >= 0 then
		-- Also cancel a clear left pending by an earlier command, which would
		-- otherwise wipe the :messages output part-way through reading it.
		M.cancel_message_clear()
	else
		M.schedule_message_clear()
	end
end

-- Zap trailing whitespace.
function M.zap()
	local pos = vim.fn.getcurpos()
	local search = vim.fn.getreg('/')
	vim.cmd([[keepjumps %substitute/\s\+$//e]])
	vim.fn.setreg('/', search)
	vim.cmd.nohlsearch()
	vim.fn.setpos('.', pos)
end

return M
