-- NERDTree is lazy-loaded on first use: loading it eagerly cost ~40ms at
-- startup (its fs_menu extension probes the clipboard provider and $PATH).
-- Entry points:
--   - the vinegar-style '-' mapping (lua/config/keymaps.lua)
--   - entering a directory buffer, e.g. `nvim .` (autocmd below)
-- Both go through require('functions').load_nerdtree(). All settings are
-- applied in init, long before the plugin actually loads.
return {
	'scrooloose/nerdtree', -- File tree sidebar
	lazy = true,
	init = function()
		-- The default of 31 is just a little too narrow.
		vim.g.NERDTreeWinSize = 40

		-- Disable display of '?' text and 'Bookmarks' label.
		vim.g.NERDTreeMinimalUI = 1

		-- Let <Leader><Leader> (^#) return from NERDTree window.
		vim.g.NERDTreeCreatePrefix = 'silent keepalt keepjumps'

		-- Single-click to toggle directory nodes, double-click to open
		-- non-directory nodes.
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

		-- Load NERDTree when entering a directory buffer, e.g. `nvim .`
		vim.api.nvim_create_autocmd({ 'VimEnter', 'BufEnter' }, {
			group = vim.api.nvim_create_augroup('LazyLoadNERDTree', {}),
			callback = function(args)
				if not vim.g.loaded_nerd_tree and vim.fn.isdirectory(args.match) == 1 then
					require('functions').load_nerdtree(args.match)
				end
			end,
		})
	end,
}
