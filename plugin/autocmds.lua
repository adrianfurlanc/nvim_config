-- ============================================================
-- General autocommands
-- (plugin-specific ones live with their plugin's config file)
-- ============================================================

local autocmd = vim.api.nvim_create_autocmd
local augroup = function(name)
	return vim.api.nvim_create_augroup(name, {})
end

local wincent = augroup('WincentAutocmds')
-- Rebalance splits when the terminal window is resized
autocmd('VimResized', { group = wincent, command = 'wincmd =' })
autocmd({ 'BufEnter', 'FocusGained', 'VimEnter', 'WinEnter' }, {
	group = wincent,
	callback = function() require('autocmds').focus_window() end,
})
autocmd({ 'FocusLost', 'WinLeave' }, {
	group = wincent,
	callback = function() require('autocmds').blur_window() end,
})

autocmd('BufWritePost', {
	group = augroup('MyAutoCmd'),
	pattern = vim.env.MYVIMRC,
	nested = true,
	command = 'source $MYVIMRC',
})

-- Don't remember the last cursor position when editing commit
-- messages, always start on line 1
autocmd('FileType', {
	group = augroup('git_files'),
	pattern = 'gitcommit',
	callback = function() vim.fn.setpos('.', { 0, 1, 1, 0 }) end,
})

-- When editing a file, always jump to the last known cursor position.
-- Don't do it for commit messages, when the position is invalid, or when
-- inside an event handler (happens when dropping a file on gvim).
autocmd('BufReadPost', {
	group = augroup('vimrcEx'),
	callback = function()
		local last = vim.fn.line([['"]])
		if vim.bo.filetype ~= 'gitcommit' and last > 0 and last <= vim.fn.line('$') then
			vim.cmd([[normal! g`"]])
		end
	end,
})

-- Enable soft-wrapping for text files
autocmd('FileType', {
	pattern = { 'text', 'markdown', 'html', 'xhtml', 'eruby' },
	command = 'setlocal wrap linebreak nolist',
})

-- Blank the message area 5s after whatever printed into it: Ex command output
-- (:w and friends), search messages, and the yank/delete line counts that
-- 'report=0' asks for. Errors and :messages output are the exceptions and stay
-- up until dismissed with <Leader>L (see plugin/mappings.lua).
local clear_messages = augroup('AutoClearMessages')
autocmd('CmdlineLeave', {
	group = clear_messages,
	pattern = ':',
	callback = function() require('functions').on_cmdline_leave() end,
})
autocmd('CmdlineLeave', {
	group = clear_messages,
	pattern = '[/?]',
	callback = function() require('functions').schedule_message_clear() end,
})
autocmd('TextYankPost', {
	group = clear_messages,
	callback = function() require('functions').schedule_message_clear() end,
})
