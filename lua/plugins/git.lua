return {
	{ 'airblade/vim-gitgutter' }, -- View git diff in gutter
	{
		'tpope/vim-fugitive', -- Vim wrapper for git
		config = function()
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
		end,
	},
	{ 'tpope/vim-rhubarb' }, -- GitHub :GBrowse handler for vim-fugitive
	{ 'wincent/vcs-jump' },  -- Jumps to changed/conflicted hunks in a Git or Mercurial repo
}
