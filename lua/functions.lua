-- Helper functions (formerly autoload/functions.vim; the module is only
-- read from disk on the first require(), then cached).

local M = {}

-- Switch to plaintext mode with: require('functions').plaintext()
function M.plaintext()
	vim.opt_local.linebreak = true
	vim.opt_local.list = false
	vim.opt_local.spell = true
	vim.opt_local.number = false
	vim.opt_local.textwidth = 0
	vim.opt_local.wrap = true
	vim.opt_local.wrapmargin = 0

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

-- Load NERDTree on first use (it costs ~40ms at startup, mostly probing the
-- clipboard and $PATH, so it is marked lazy in lua/plugins/nerdtree.lua).
-- With a directory argument, hands that buffer to NERDTree's netrw hijack —
-- needed when the load is triggered by entering a directory buffer, because
-- NERDTree's own BufEnter autocmd was not yet installed when it fired.
function M.load_nerdtree(dir)
	if vim.g.loaded_nerd_tree then
		return
	end
	-- NERDTree only removes netrw's directory-browse autocmds at VimEnter,
	-- which has already passed; remove them here instead.
	vim.cmd('silent! autocmd! FileExplorer')
	require('lazy').load({ plugins = { 'nerdtree' } })
	if dir and vim.fn.isdirectory(dir) == 1 then
		vim.fn['nerdtree#checkForBrowse'](dir)
	end
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
