return {
	{ 'airblade/vim-gitgutter' }, -- View git diff in gutter
	{
		'tpope/vim-fugitive', -- Vim wrapper for git
		config = function()
			-- Fugitive: allow navigating up in git tree with ..
			-- (Lua callback wrapping vim.cmd on purpose: a `command` string
			-- with `if ... | ... | endif` aborts the rest of the event's
			-- autocmds on nvim 0.8.3, see lua/plugins/nerdtree.lua)
			vim.api.nvim_create_autocmd('User', {
				pattern = 'fugitive',
				callback = function()
					vim.cmd([[if fugitive#buffer().type() =~# '^\%(tree\|blob\)$' | nnoremap <buffer> .. :edit %:h<CR> | endif]])
				end,
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
