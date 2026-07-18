-- NERDTree is installed as an *opt* package and loaded on first use: loading
-- it eagerly cost ~40ms at startup (its fs_menu extension probes the
-- clipboard provider and $PATH). Entry points:
--   - the vinegar-style '-' mapping (plugin/mappings.lua)
--   - entering a directory buffer, e.g. `nvim .` (autocmd below)
-- Its settings live in after/plugin/NERDTree.lua and are set long before the
-- plugin actually loads, so lazy-loading doesn't affect them.
vim.api.nvim_create_autocmd({ 'VimEnter', 'BufEnter' }, {
	group = vim.api.nvim_create_augroup('LazyLoadNERDTree', {}),
	callback = function(args)
		if not vim.g.loaded_nerd_tree and vim.fn.isdirectory(args.match) == 1 then
			require('functions').load_nerdtree(args.match)
		end
	end,
})
