" ============================================================
" Highlight and cursor tweaks
" (the colorscheme itself is set in init.vim, before this runs)
" ============================================================

" Darker background for the active split, lighter for inactive ones
" (Normal = current window, NormalNC = non-current windows).
" Re-applied on ColorScheme so switching themes doesn't wipe it.
" InactiveText is the overlay autocmds#blur_window() paints across inactive
" windows: gray text, guibg=NONE so the window's own background shows through.
function! s:DimInactiveWindows() abort
	highlight Normal   guibg=#1d2021
	highlight NormalNC guibg=#32302f
	highlight InactiveText gui=NONE cterm=NONE guifg=#928374 guibg=NONE ctermfg=245 ctermbg=NONE
	" Gruvbox gives the sign column (and its per-color sign groups) a bg1
	" background, which shows as a differently-colored strip against the
	" Normal/NormalNC backgrounds above. Drop those backgrounds so the
	" gutter follows the window background instead.
	highlight SignColumn guibg=NONE
	for l:color in ['Red', 'Green', 'Yellow', 'Blue', 'Purple', 'Aqua', 'Orange']
		execute 'highlight Gruvbox' . l:color . 'Sign guibg=NONE'
	endfor
endfunction

" Syntax groups that link to Normal (gruvbox's Operator, vim's vimUserFunc,
" ...) paint Normal's explicit guibg over NormalNC in non-current windows,
" punching active-colored holes in the dimming. Break such links so those
" tokens fall back to the window's own background.
function! s:ClearNormalLinks() abort
	for l:line in split(execute('silent highlight'), "\n")
		if l:line =~# ' links to Normal$'
			execute 'highlight! link' matchstr(l:line, '^\S\+') 'NONE'
		endif
	endfor
endfunction

call s:DimInactiveWindows()
call s:ClearNormalLinks()
augroup ActiveWindowBackground
	autocmd!
	autocmd ColorScheme * call s:DimInactiveWindows()
	autocmd ColorScheme,Syntax * call s:ClearNormalLinks()
augroup END

" Syntax highlighting
hi clear SignColumn
hi DiffAdd ctermbg=White ctermfg=Green
hi DiffDelete ctermbg=White ctermfg=Red
hi DiffChange ctermbg=White ctermfg=Cyan
hi Search ctermfg=red
hi Comment gui=italic cterm=italic
hi ColorColumn ctermbg=237

" Bright cursor for contrast against the dark background, in every mode:
" block in normal/visual, thin bar in insert, underline in replace and
" operator-pending. All use the Cursor group below (nvim relays the color
" to the terminal).
" gui=NONE/cterm=NONE is required: gruvbox defines Cursor as `inverse`, and
" :hi merges arguments, so without clearing that attribute the fg/bg here
" get swapped at render time. Re-applied on ColorScheme because switching
" themes restores the inverse version.
function! s:LightCursor() abort
	hi Cursor gui=NONE cterm=NONE guifg=#282828 guibg=#ebdbb2 ctermfg=235 ctermbg=223
endfunction
call s:LightCursor()
augroup CursorColors
	autocmd!
	autocmd ColorScheme * call s:LightCursor()
augroup END
set guicursor=n-v-c-sm:block-Cursor,i-ci-ve:ver25-Cursor,r-cr-o:hor20-Cursor

" Color 81st column of longer lines
call matchadd('ColorColumn', '\%81v', 100)
