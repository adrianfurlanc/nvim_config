-- Fugitive: allow navigating up in git tree with ..
vim.api.nvim_create_autocmd('User', {
	pattern = 'fugitive',
	command = [[if fugitive#buffer().type() =~# '^\%(tree\|blob\)$' | nnoremap <buffer> .. :edit %:h<CR> | endif]],
})

-- Fugitive: prevent buffer list from being swamped
vim.api.nvim_create_autocmd('BufReadPost', {
	pattern = 'fugitive://*',
	callback = function()
		vim.bo.bufhidden = 'delete'
	end,
})
