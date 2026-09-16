-- Run SearchLink on the visual selection and put the result back in its
-- place: <Leader>k in lua/config/keymaps.lua.
--
-- SearchLink (https://github.com/ttscoff/searchlink) turns search shorthand
-- into Markdown links: "!wiki Sid Vicious" becomes
-- "[Sid Vicious](https://en.wikipedia.org/wiki/Sid_Vicious)", and a block
-- with [text](!code "terms") marks comes back with every mark filled in, as
-- reference links. The CLI is the gem (gem install --user-install
-- searchlink); it reads the same ~/.config/searchlink/config.yaml as the
-- macOS Service, so the custom searches and settings are the same here.
--
-- Text goes in on stdin and comes out on stdout, nothing on stderr. A
-- charwise selection is sent as it is and works as a one-line search; a
-- linewise one is the bracket format. Each search is a network round trip of
-- a second or so, so the CLI runs in the background and the buffer stays
-- usable. The result is pasted only if the buffer has not changed meanwhile;
-- otherwise it is shown in the message area rather than replacing the wrong
-- text.
--
-- SearchLink reports through HTML comments appended to its output: an
-- "<!-- Errors: ... -->" after a failed search (config debug: true) and a
-- "<!-- Report: ... -->" block after a multi-link run (report: true). Both
-- are stripped here and shown as notifications; only the text is pasted.

local M = {}

-- SearchLink gives up on a single search after 15s (config timeout), so
-- this only catches a hung process.
local TIMEOUT_MS = 60000

local function notify(msg, level)
	vim.notify('SearchLink: ' .. msg, level or vim.log.levels.INFO)
end

-- The CLI. nvim started from the Dock gets the login PATH, without the user
-- gem dir the shell config adds, so look there directly as a fallback.
local function cli()
	if vim.fn.executable('searchlink') == 1 then
		return 'searchlink'
	end
	return vim.fn.glob('~/.gem/ruby/*/bin/searchlink', true, true)[1]
end

-- The selection just left, as lines plus the region to write back into.
-- Called from a ':' mapping, so Visual mode has ended and '< '> are set.
-- getregionpos() gives byte columns with the end inclusive and clamped to the
-- line (a "$" selection does not run past it), which is what the multibyte
-- case needs: '> alone points at the first byte of the last character.
local function selection()
	local mode = vim.fn.visualmode()
	if mode == '\22' then
		return nil, 'blockwise selections are not supported'
	end
	local s, e = vim.fn.getpos("'<"), vim.fn.getpos("'>")
	local lines = vim.fn.getregion(s, e, { type = mode })
	local pos = vim.fn.getregionpos(s, e, { type = mode })
	if #lines == 0 or #pos == 0 then
		return nil, 'nothing selected'
	end
	local first, last = pos[1][1], pos[#pos][2]
	return {
		mode = mode,
		lines = lines,
		-- 0-based and end-exclusive, as nvim_buf_set_text() wants them
		start_row = first[2] - 1,
		start_col = first[3] - 1,
		end_row = last[2] - 1,
		end_col = last[3],
	}
end

-- SearchLink's comments, out of its output and into a list. The Errors one
-- is appended to the line it concerns with a space either side; the Report
-- one follows the text after blank lines.
local function strip_comments(text)
	local notes = {}
	text = text:gsub('[ \t]*<!%-%- ?(Errors:.-)%-%->[ \t]*', function(body)
		notes[#notes + 1] = body
		return ''
	end)
	text = text:gsub('\n*<!%-%- ?(Report:.-)%-%->\n*', function(body)
		notes[#notes + 1] = body
		return ''
	end)
	return text, notes
end

-- The output as buffer lines. Linewise: SearchLink ends its output with
-- newlines of its own, so trailing ones are dropped and the blank lines the
-- selection itself ended with are put back. Charwise: one search, one line,
-- and its trailing whitespace goes.
local function to_lines(text, sel)
	if sel.mode ~= 'V' then
		return vim.split((text:gsub('%s+$', '')), '\n', { plain = true })
	end
	local lines = vim.split((text:gsub('\n+$', '')), '\n', { plain = true })
	for i = #sel.lines, 1, -1 do
		if sel.lines[i] ~= '' then
			break
		end
		lines[#lines + 1] = ''
	end
	return lines
end

local function paste(buf, tick, sel, res)
	if res.signal ~= 0 then
		return notify(('killed after %ds'):format(TIMEOUT_MS / 1000), vim.log.levels.ERROR)
	end
	if res.code ~= 0 then
		return notify(('exit %d %s'):format(res.code, vim.trim(res.stderr or '')), vim.log.levels.ERROR)
	end

	local text, notes = strip_comments(res.stdout or '')
	for _, note in ipairs(notes) do
		notify(vim.trim(note), note:match('^Errors') and vim.log.levels.WARN or vim.log.levels.INFO)
	end

	local lines = to_lines(text, sel)
	if table.concat(lines, '\n') == table.concat(sel.lines, '\n') then
		-- A failed search comes back as the text that went in.
		if #notes == 0 then
			notify('no change', vim.log.levels.WARN)
		end
		return
	end
	if not vim.api.nvim_buf_is_valid(buf) then
		return notify('the buffer is gone; result was:\n' .. text, vim.log.levels.WARN)
	end
	if vim.api.nvim_buf_get_changedtick(buf) ~= tick then
		return notify('the buffer changed meanwhile, not pasting. Result:\n' .. text, vim.log.levels.WARN)
	end
	if sel.mode == 'V' then
		vim.api.nvim_buf_set_lines(buf, sel.start_row, sel.end_row + 1, false, lines)
	else
		vim.api.nvim_buf_set_text(buf, sel.start_row, sel.start_col, sel.end_row, sel.end_col, lines)
	end
end

-- One run per buffer at a time: two in flight would race for the same text.
local running = {}

function M.selection()
	local buf = vim.api.nvim_get_current_buf()
	if running[buf] then
		return notify('still working on the last selection', vim.log.levels.WARN)
	end
	local exe = cli()
	if not exe then
		return notify('the CLI is not installed: gem install --user-install searchlink', vim.log.levels.ERROR)
	end
	local sel, err = selection()
	if not sel then
		return notify(err, vim.log.levels.WARN)
	end

	-- Always newline-terminated: a one-line search without it comes back as
	-- "No results" (tested), as if the line were read with a shell's echo.
	local input = table.concat(sel.lines, '\n') .. '\n'
	local tick = vim.api.nvim_buf_get_changedtick(buf)
	running[buf] = true
	notify('searching…')
	vim.system({ exe }, {
		stdin = input,
		text = true,
		timeout = TIMEOUT_MS,
		-- Never a confirmation dialog from inside the editor, whatever the
		-- config says.
		env = { SL_NO_CONFIRM = 'true' },
	}, function(res)
		vim.schedule(function()
			running[buf] = nil
			paste(buf, tick, sel, res)
		end)
	end)
end

return M
