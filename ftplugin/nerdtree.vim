setlocal colorcolumn=

if has('folding')
  setlocal nofoldenable
endif

setlocal nolist

" Move up a directory using "-" like vim-vinegar 
nmap <buffer> <expr> - g:NERDTreeMapUpdir
