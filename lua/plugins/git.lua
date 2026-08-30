-- No gutter diff plugin here on purpose. vim-gitgutter used to be, and
-- gitsigns was tried in its place; both want the sign column, which coc
-- already owns for its diagnostic icons ('signcolumn' is 'yes', one sign per
-- line, and coc's priority of 10 beats either of them). The git workflow runs
-- through fugitive below, where the diff is the point rather than a margin
-- note: :Gstatus to stage, :Gdiffsplit to see the change, :Gblame for history.
--
-- Jumping between hunks in an ordinary buffer is deliberately unavailable too.
-- wincent/vcs-jump did that, and came out once six months of shada history
-- showed :VcsJump had never once been run -- the diff gets read in fugitive,
-- where the hunks are already laid out, rather than by walking the file for
-- them. What would restore it is a gutter plugin, which is where this comment
-- came in.
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

			-- Fugitive: move the status window to a full-height vertical split
			-- on the right, instead of the short horizontal one :Git opens at
			-- the bottom. FileType is the hook because it only ever fires for
			-- the status buffer (fugitive#BufReadStatus is the single place
			-- setting this filetype) and it fires however the window was
			-- opened, including on the reload after staging. Already rightmost
			-- and full height makes it a no-op.
			vim.api.nvim_create_autocmd('FileType', {
				pattern = 'fugitive',
				callback = function()
					vim.cmd.wincmd('L')
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
}
