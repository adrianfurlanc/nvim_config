-- Autocommand handler functions (formerly autoload/autocmds.vim; the
-- autocmds that call them are registered in lua/config/autocmds.lua, and this
-- module is only loaded the first time one of them fires).

-- Filetypes that don't get the inactive-window dimming below. Named for what it
-- does rather than for 'colorcolumn' (which the dimming never touched) -- the
-- old name is why focus_window()'s comment reads as being about something else.
vim.g.WincentDimBlacklist = { 'diff', 'undotree', 'oil', 'qf' }

-- The namespace dim_namespace() in lua/config/colors.lua fills with grey
-- copies of the groups the matchaddpos() overlay below cannot recolour --
-- coc's gutter icons, its end-of-line messages and its inlay hints, all of
-- them signs or virtual text rather than buffer characters. Fetched by name:
-- nvim_create_namespace() returns the existing id for a name it has already
-- seen, so this is the same namespace that file fills, not a second empty one.
local inactive_ns = vim.api.nvim_create_namespace('InactiveWindow')

local M = {}

function M.should_dim()
	return not vim.tbl_contains(vim.g.WincentDimBlacklist, vim.bo.filetype)
end

function M.blur_window()
	vim.opt_local.cursorline = false
	if M.should_dim() then
		-- Instead of unconditionally resetting, append to existing array.
		-- This allows us to gracefully handle duplicate autocmds.
		local matches = vim.w.wincent_matches or {}
		local slop = math.floor(vim.o.lines / 2)
		local first = math.max(1, vim.fn.line('w0') - slop)
		local last = math.min(vim.fn.line('$'), vim.fn.line('w$') + slop)

		-- One call for the whole range. It used to go in batches, because
		-- Vim's matchaddpos() takes at most 8 positions per call -- a limit
		-- nvim does not have and no longer documents (measured: 200 in one
		-- call, all 200 kept). The batches were also nine lines wide and
		-- restarted on their own last line, so every ninth line was matched
		-- twice. This runs on every window switch and tmux focus change.
		local positions = {}
		for lnum = first, last do
			positions[#positions + 1] = lnum
		end
		if #positions > 0 then
			matches[#matches + 1] = vim.fn.matchaddpos('InactiveText', positions, 1000)
		end

		vim.w.wincent_matches = matches

		-- What the overlay above cannot touch: signs and virtual text are
		-- drawn from extmarks, not from the buffer's characters, so no match
		-- recolours them at any priority. Resolving this window's highlights
		-- through the grey namespace does.
		vim.api.nvim_win_set_hl_ns(vim.api.nvim_get_current_win(), inactive_ns)
	end
end

function M.focus_window()
	vim.opt_local.cursorline = true

	-- Neither undo consults the blacklist, though both of the corresponding
	-- dos in blur_window() above do. The guard reads 'filetype', and a window
	-- can change filetype while it sits blurred -- :Gdiffsplit turns a file
	-- into a 'diff' buffer, a scratch buffer becomes 'qf'. Asked again on the
	-- way back in, the guard then answers the opposite of what it answered on
	-- the way out, the cleanup is skipped, and the window stays dimmed while
	-- focused. Nothing would ever undo it either: every later visit asks the
	-- same question and gets the same answer, so the dimming is permanent.
	--
	-- Neither undo needs the guard to be cheap. Detaching a namespace that was
	-- never attached is a no-op, and the loop below already does nothing on a
	-- window with no w:wincent_matches to delete. Gate what you apply, not what
	-- you remove.
	vim.api.nvim_win_set_hl_ns(vim.api.nvim_get_current_win(), 0)

	if vim.w.wincent_matches then
		for _, match in ipairs(vim.w.wincent_matches) do
			-- In testing, not getting any error here, but being ultra-cautious.
			pcall(vim.fn.matchdelete, match)
		end
		vim.w.wincent_matches = {}
	end
end

return M
