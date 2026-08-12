-- No gutter diff plugin here on purpose. vim-gitgutter used to be, and
-- gitsigns was tried in its place; both want the sign column, which coc
-- already owns for its diagnostic icons ('signcolumn' is 'yes', one sign per
-- line, and coc's priority of 10 beats either of them). The git workflow runs
-- through fugitive below, where the diff is the point rather than a margin
-- note: :Gstatus to stage, :Gdiffsplit to see the change, :Gblame for history.
-- :VcsJump (vcs-jump, at the bottom) is what jumps to a changed hunk.
return {
	{
		-- Stays eager: the lightline branch component (statusline#fugitive)
		-- needs fugitive's buffer detection done by the first redraw.
		'tpope/vim-fugitive', -- Vim wrapper for git
		config = function()
			-- Fugitive: allow navigating up in git tree with ..
			-- (Lua callback wrapping vim.cmd on purpose: a `command` string
			-- with `if ... | ... | endif` silently aborts every remaining
			-- autocmd for that event on nvim 0.8.3)
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
	{
		'wincent/vcs-jump', -- Jumps to changed/conflicted hunks in a Git or Mercurial repo
		cmd = 'VcsJump',
	},
}
