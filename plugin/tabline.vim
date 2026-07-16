" Custom tabline. The rendering functions live in autoload/tabline.vim so they
" are only loaded on first redraw.
"
" Note: lightline would otherwise take over 'tabline' itself; it is told to
" leave it alone in plugin/lightline.vim (g:lightline.enable.tabline).
if has('windows')
	set tabline=%!tabline#line()
endif
