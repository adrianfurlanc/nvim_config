" Switch to plaintext mode with: call functions#plaintext()
function! functions#plaintext()
  setlocal linebreak
  setlocal nolist
  setlocal spell
  setlocal nonumber
  setlocal textwidth=0
  setlocal wrap
  setlocal wrapmargin=0

  nnoremap <buffer> j gj
  nnoremap <buffer> k gk

  " Ideally would keep 'list' set, and restrict 'listchars' to just show
  " whitespace errors, but 'listchars' is global and I don't want to go through
  " the hassle of saving and restoring.
  if has('autocmd')
    autocmd BufWinEnter <buffer> match Error /\s\+$/
    autocmd InsertEnter <buffer> match Error /\s\+\%#\@<!$/
    autocmd InsertLeave <buffer> match Error /\s\+$/
    autocmd BufWinLeave <buffer> call clearmatches()
  endif
endfunction

" Custom fold summary line, used via 'foldtext' (see plugin/settings.vim)
let s:middot='·'
let s:raquo='»'
let s:small_l='ℓ'

function! functions#foldtext() abort
	let l:lines='[' . (v:foldend - v:foldstart + 1) . s:small_l . ']'
	let l:first=substitute(getline(v:foldstart), '\v *', '', '')
	let l:dashes=substitute(v:folddashes, '-', s:middot, 'g')
	return s:raquo . s:middot . s:middot . l:lines . l:dashes . ': ' . l:first
endfunction

" Preserve cursor position across commands
function! functions#preserve(command) abort
	let _s = @/
	let l  = line(".")
	let c  = col(".")
	execute a:command
	let @/ = _s
	call cursor(l, c)
endfunction

" Cycle through relativenumber + number, number (only), and no numbering
function! functions#cycle_numbering() abort
	if exists('+relativenumber')
		execute {
					\ '00': 'set relativenumber   | set number',
					\ '01': 'set norelativenumber | set number',
					\ '10': 'set norelativenumber | set nonumber',
					\ '11': 'set norelativenumber | set number' }[&number . &relativenumber]
	else
		" No relative numbering, just toggle numbers on and off.
		set number!
	endif
endfunction

" Alias a built-in command to another one, e.g. :grep -> :GrepperGrep
function! functions#setup_command_alias(input, output) abort
	exec 'cabbrev <expr> '.a:input
				\ .' ((getcmdtype() is# ":" && getcmdline() is# "'.a:input.'")'
				\ .'? ("'.a:output.'") : ("'.a:input.'"))'
endfunction

" Load the NERDTree opt package on first use (it costs ~40ms at startup,
" mostly probing the clipboard and $PATH, so it is not in pack/*/start).
" With a directory argument, hands that buffer to NERDTree's netrw hijack —
" needed when the load is triggered by entering a directory buffer, because
" NERDTree's own BufEnter autocmd was not yet installed when it fired.
function! functions#load_nerdtree(...) abort
	if exists('g:loaded_nerd_tree')
		return
	endif
	" NERDTree only removes netrw's directory-browse autocmds at VimEnter,
	" which has already passed; remove them here instead.
	silent! autocmd! FileExplorer
	packadd nerdtree
	if a:0 && isdirectory(a:1)
		call nerdtree#checkForBrowse(a:1)
	endif
endfunction

" Zap trailing whitespace.
function! functions#zap() abort
  let l:pos=getcurpos()
  let l:search=@/
  keepjumps %substitute/\s\+$//e
  let @/=l:search
  nohlsearch
  call setpos('.', l:pos)
endfunction
