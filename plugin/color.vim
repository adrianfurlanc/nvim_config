" ============================================================
" Highlight and cursor tweaks
" (the startup colorscheme is set in init.vim, before this runs;
" the per-filetype switch lives at the bottom of this file)
" ============================================================

" Darker background for the active split, lighter for inactive ones
" (Normal = current window, NormalNC = non-current windows).
" Re-applied on ColorScheme so switching themes doesn't wipe it.
" InactiveText is the overlay autocmds#blur_window() paints across inactive
" windows: gray text, guibg=NONE so the window's own background shows through.
function! s:DimInactiveWindows() abort
	if get(g:, 'colors_name', '') ==# 'OceanicNext'
		" OceanicNext palette: active darker than base00 (#1b2b34),
		" inactive base00 itself; gray is base03.
		highlight Normal   guibg=#16232b
		highlight NormalNC guibg=#1b2b34
		highlight InactiveText gui=NONE cterm=NONE guifg=#65737e guibg=NONE ctermfg=243 ctermbg=NONE
	else
		highlight Normal   guibg=#1d2021
		highlight NormalNC guibg=#32302f
		highlight InactiveText gui=NONE cterm=NONE guifg=#928374 guibg=NONE ctermfg=245 ctermbg=NONE
	endif
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
hi Comment gui=italic cterm=italic
hi ColorColumn ctermbg=237

" Search matches: the match under the cursor (CurSearch) keeps the scheme's
" default reverse-video Search look; every other match is drawn as red
" underlined text on the plain background. Re-applied on ColorScheme because
" switching themes (gruvbox <-> OceanicNext) resets both groups.
function! s:SearchColors() abort
	if get(g:, 'colors_name', '') ==# 'OceanicNext'
		highlight CurSearch gui=reverse cterm=reverse guifg=#fac863 guibg=#1b2b34 ctermfg=221 ctermbg=235
		highlight Search gui=underline cterm=underline guifg=#ec5f67 guibg=NONE ctermfg=203 ctermbg=NONE
	else
		highlight CurSearch gui=reverse cterm=reverse guifg=#fabd2f guibg=#282828 ctermfg=214 ctermbg=235
		highlight Search gui=underline cterm=underline guifg=#fb4934 guibg=NONE ctermfg=167 ctermbg=NONE
	endif
endfunction
call s:SearchColors()
augroup SearchColors
	autocmd!
	autocmd ColorScheme * call s:SearchColors()
augroup END

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

" ============================================================
" Per-filetype colorscheme: OceanicNext for markdown, gruvbox
" for everything else. A colorscheme is global, so this switches
" on buffer entry; the g:colors_name guard keeps buffer moves
" between same-scheme files from re-sourcing the theme (which
" would also re-fire every ColorScheme autocmd above).
" ============================================================
function! s:SchemeForFiletype() abort
	let l:want = &filetype ==# 'markdown' ? 'OceanicNext' : 'gruvbox'
	if get(g:, 'colors_name', '') !=# l:want
		execute 'colorscheme' l:want
	endif
endfunction

augroup FiletypeColorscheme
	autocmd!
	" BufEnter covers moving into an already-loaded markdown buffer;
	" FileType covers the first load, when BufEnter fired before the
	" filetype was detected. 'nested' lets the :colorscheme fire the
	" ColorScheme autocmds above (dimming, cursor), which are otherwise
	" suppressed inside an autocmd.
	autocmd BufEnter,FileType * nested call s:SchemeForFiletype()
augroup END
