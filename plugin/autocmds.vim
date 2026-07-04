if has('autocmd')
  augroup WincentAutocmds
    autocmd!
    autocmd VimResized * execute "normal! \<c-w>="
    augroup END
endif
