-- The default of 31 is just a little too narrow.
vim.g.NERDTreeWinSize = 40

-- Disable display of '?' text and 'Bookmarks' label.
vim.g.NERDTreeMinimalUI = 1

-- Let <Leader><Leader> (^#) return from NERDTree window.
vim.g.NERDTreeCreatePrefix = 'silent keepalt keepjumps'

-- Single-click to toggle directory nodes, double-click to open non-directory
-- nodes.
vim.g.NERDTreeMouseMode = 2


-- Make NERDTree behave more like vim-vinegar
vim.api.nvim_create_autocmd('User', {
	group = vim.api.nvim_create_augroup('WincentNERDTree', {}),
	pattern = 'NERDTreeInit',
	callback = function() require('autocmds').attempt_select_last_file() end,
})

-- Keep NERDTree in sync with the filesystem
vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter' }, {
	group = vim.api.nvim_create_augroup('NerdTreeAutoRefresh', {}),
	command = [[if exists(':NERDTreeRefreshRoot') | silent! NERDTreeRefreshRoot | endif]],
})
