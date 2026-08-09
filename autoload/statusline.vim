" Lightline component functions (referenced by name in plugin/lightline.vim;
" autoloaded on first statusline redraw rather than at startup).

function! statusline#filetype() abort
	return winwidth(0) > 70 ? (strlen(&filetype) ? &filetype . ' ' . WebDevIconsGetFileTypeSymbol() : 'no ft') : ''
endfunction

function! statusline#readonly() abort
	return &readonly && &filetype !=# 'help' ? ' ' : ''
endfunction

function! statusline#modified() abort
	return &ft =~ 'help' ? '' : &modified ? '+' : &modifiable ? '' : '-'
endfunction

function! statusline#fileformat() abort
	return winwidth(0) > 70 ? (&fileformat . ' ' . WebDevIconsGetFileFormatSymbol()) : ''
endfunction

function! statusline#fugitive() abort
	if expand('%:t') =~? 'Tagbar\|Gundo\|NERD' || &ft =~? 'vimfiler'
		return ''
	endif
	let branch = exists('*FugitiveHead') ? FugitiveHead() : ''
	if branch ==# ''
		return ''
	endif
	let mark = ' '
	return mark . branch . get(b:, 'lightline_git_status', '')
endfunction

" Cache the current file's git state as a statusline suffix:
" '' (tracked & clean), ' [untracked]', ' [staged]', ' [modified]',
" or ' [staged,modified]'. Parsed from the two-column XY code of
" git status --porcelain (X = index, Y = worktree). Cached per buffer
" because the statusline redraws far too often to shell out each time.
" Async (jobstart, not system()): the synchronous version forked git on the
" startup path (BufReadPost of the first file) and stalled every write and
" tmux focus switch by a few ms. The suffix now lands a moment later via the
" callback, which re-renders the statusline.
function! statusline#update_git_status() abort
	let b:lightline_git_status = ''
	let path = expand('%:p')
	if empty(path) || !filereadable(path) || !exists('*FugitiveGitDir') || empty(FugitiveGitDir())
		return
	endif
	call jobstart(
		\ ['git', '-C', expand('%:p:h'), 'status', '--porcelain', '--', path],
		\ {
		\   'stdout_buffered': v:true,
		\   'on_stdout': function('s:OnGitStatus', [bufnr('%')]),
		\ })
endfunction

function! s:OnGitStatus(bufnr, job, data, event) abort
	if !bufexists(a:bufnr)
		return
	endif
	let out = get(a:data, 0, '')
	let status = ''
	if !empty(out)
		if out[0] ==# '?'
			let status = ' [untracked]'
		else
			let parts = []
			if out[0] !=# ' '
				call add(parts, 'staged')
			endif
			if out[1] !=# ' '
				call add(parts, 'modified')
			endif
			if !empty(parts)
				let status = ' [' . join(parts, ',') . ']'
			endif
		endif
	endif
	call setbufvar(a:bufnr, 'lightline_git_status', status)
	call lightline#update()
endfunction

" The gruvbox lightline theme (lightline-gruvbox.vim) uses gray statusline
" text; brighten it to gruvbox's normal foreground (fg1, a warm off-white).
" The theme is a plugin file sourced AFTER our plugin files, so the palette
" can only be patched on VimEnter, followed by a lightline re-init (the
" method from lightline's FAQ). Palette entries are [guifg, guibg, ctermfg,
" ctermbg]. The mode block (left[0]) keeps its dark-on-color text, and the
" right side (percent, line:col) keeps the theme's dark-on-gray text to
" match the tmux statusbar.
let s:statusline_fg   = '#d5c4a1'
let s:statusline_ctfg = 250

function! statusline#brighten() abort
	let palette = g:lightline#colorscheme#gruvbox#palette
	for mode in ['normal', 'insert', 'visual', 'replace']
		if has_key(palette, mode) && has_key(palette[mode], 'left') && len(palette[mode].left) > 1
			let palette[mode].left[1][0] = s:statusline_fg
			let palette[mode].left[1][2] = s:statusline_ctfg
		endif
	endfor
	let palette.normal.middle[0][0] = s:statusline_fg
	let palette.normal.middle[0][2] = s:statusline_ctfg
	" The gruvbox lightline theme ships no error/warning/info/hint entries, so
	" the typed coc_* segments would render with detached-looking fallback
	" colors. Gruvbox bright red/yellow/blue/aqua, dark text — descending
	" severity, so the eye reads red as loudest and aqua as quietest.
	let palette.normal.error   = [[ '#282828', '#fb4934', 235, 167 ]]
	let palette.normal.warning = [[ '#282828', '#fabd2f', 235, 214 ]]
	let palette.normal.info    = [[ '#282828', '#83a598', 235, 109 ]]
	let palette.normal.hint    = [[ '#282828', '#8ec07c', 235, 108 ]]
	call lightline#init()
	call lightline#colorscheme()
	call lightline#update()
endfunction
