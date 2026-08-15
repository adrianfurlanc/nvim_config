-- Autocommand handler functions (formerly autoload/autocmds.vim; the
-- autocmds that call them are registered in plugin/autocmds.lua, and this
-- module is only loaded the first time one of them fires).

vim.g.WincentColorColumnBlacklist = { 'diff', 'undotree', 'oil', 'qf' }
vim.g.WincentCursorlineBlacklist = { 'command-t' }
vim.g.WincentMkviewFiletypeBlacklist = { 'diff', 'hgcommit', 'gitcommit' }

local M = {}

function M.should_colorcolumn()
	return not vim.tbl_contains(vim.g.WincentColorColumnBlacklist, vim.bo.filetype)
end

function M.blur_window()
	vim.opt_local.cursorline = false
	if M.should_colorcolumn() then
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
	end
end

function M.focus_window()
	vim.opt_local.cursorline = true
	if M.should_colorcolumn() then
		if vim.w.wincent_matches then
			for _, match in ipairs(vim.w.wincent_matches) do
				-- In testing, not getting any error here, but being ultra-cautious.
				pcall(vim.fn.matchdelete, match)
			end
			vim.w.wincent_matches = {}
		end
	end
end

return M
