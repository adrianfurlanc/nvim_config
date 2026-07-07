" NERDTree is installed as an *opt* package and loaded on first use: loading
" it eagerly cost ~40ms at startup (its fs_menu extension probes the
" clipboard provider and $PATH). Entry points:
"   - the vinegar-style '-' mapping (plugin/mappings.vim)
"   - entering a directory buffer, e.g. `nvim .` (autocmd below)
" Its settings live in after/plugin/NERDTree.vim and are set long before the
" plugin actually loads, so lazy-loading doesn't affect them.
augroup LazyLoadNERDTree
	autocmd!
	autocmd VimEnter,BufEnter * if !exists('g:loaded_nerd_tree') && isdirectory(expand('<amatch>'))
				\ | call functions#load_nerdtree(expand('<amatch>'))
				\ | endif
augroup END
