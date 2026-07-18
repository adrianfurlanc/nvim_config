vim.opt_local.colorcolumn = ''
vim.opt_local.foldenable = false
vim.opt_local.list = false

-- Move up a directory using "-" like vim-vinegar
vim.keymap.set('n', '-', function()
	return vim.g.NERDTreeMapUpdir
end, { buffer = true, expr = true, remap = true })
