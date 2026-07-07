" Fugitive: allow navigating up in git tree with ..
autocmd user fugitive
			\ if fugitive#buffer().type() =~# '^\%(tree\|blob\)$' |
			\   nnoremap <buffer> .. :edit %:h<CR> |
			\ endif

" Fugitive: prevent buffer list from being swamped
autocmd BufReadPost fugitive://* set bufhidden=delete
