-- Autocommand handler functions (formerly autoload/autocmds.vim; the
-- autocmds that call them are registered in plugin/autocmds.lua, and this
-- module is only loaded the first time one of them fires).

vim.g.WincentColorColumnBlacklist = { 'diff', 'undotree', 'nerdtree', 'qf' }
vim.g.WincentCursorlineBlacklist = { 'command-t' }
vim.g.WincentMkviewFiletypeBlacklist = { 'diff', 'hgcommit', 'gitcommit' }

local M = {}

function M.attempt_select_last_file()
	local previous = vim.fn.expand('#:t')
	if previous ~= '' then
		vim.fn.search([[\v<]] .. previous .. [[>]])
	end
end

function M.should_colorcolumn()
	return not vim.tbl_contains(vim.g.WincentColorColumnBlacklist, vim.bo.filetype)
end

function M.blur_window()
	vim.opt_local.cursorline = false
	if M.should_colorcolumn() then
		-- Instead of unconditionally resetting, append to existing array.
		-- This allows us to gracefully handle duplicate autocmds.
		local matches = vim.w.wincent_matches or {}
		local height = vim.o.lines
		local slop = math.floor(height / 2)
		local start = math.max(1, vim.fn.line('w0') - slop)
		local last = math.min(vim.fn.line('$'), vim.fn.line('w$') + slop)
		while start <= last do
			local next_chunk = start + 8
			local positions = {}
			for lnum = start, math.min(last, next_chunk) do
				positions[#positions + 1] = lnum
			end
			local id = vim.fn.matchaddpos('InactiveText', positions, 1000)
			matches[#matches + 1] = id
			start = next_chunk
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
