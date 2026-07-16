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

" Auto-clearing of the message area (see plugin/autocmds.vim).
"
" Anything echoed below the statusline stays on screen until something else
" happens to overwrite it. The autocmds that produce such output call
" functions#schedule_message_clear(), which blanks the area again after
" 5 seconds. Two kinds of output are exempt and stay up until dismissed with
" <Leader>L (see plugin/mappings.vim): errors, and :messages output.
let s:message_timeout=5000
let s:message_retry=1000
let s:message_timer=-1
let s:messages_command='\v^\s*mes%[sages]>'

function! functions#clear_message_area(...) abort
	" schedule_message_clear() blanked v:errmsg, so anything in it now came
	" from the command this clear was scheduled for: leave the error on screen.
	if v:errmsg !=# ''
		let s:message_timer=-1
		return
	endif
	if mode() ==# 'n'
		echo ''
		let s:message_timer=-1
	else
		" Echoing now would clobber an open cmdline, a press-enter prompt or
		" the text being typed in insert mode ('noshowmode' means insert mode
		" does not overwrite the message itself). Wait for normal mode.
		let s:message_timer=timer_start(s:message_retry, function('functions#clear_message_area'))
	endif
endfunction

function! functions#cancel_message_clear() abort
	if s:message_timer != -1
		call timer_stop(s:message_timer)
		let s:message_timer=-1
	endif
endfunction

function! functions#schedule_message_clear() abort
	call functions#cancel_message_clear()
	" v:errmsg is not cleared by a later successful command, so blank it now
	" and read it back in the timer to tell 'this command errored' from 'an
	" error some time ago'. Done here, not in the autocmd, so it covers the
	" commands scheduled before they run and the yanks scheduled after.
	let v:errmsg=''
	let s:message_timer=timer_start(s:message_timeout, function('functions#clear_message_area'))
endfunction

" Clear the message area right now, whatever is in it: the error messages and
" :messages output the timer deliberately leaves alone. 'redraw' is what
" actually removes an error and restores the screen after the message area has
" grown to more than one line.
function! functions#clear_message_area_now() abort
	call functions#cancel_message_clear()
	let v:errmsg=''
	echo ''
	redraw
endfunction

function! functions#on_cmdline_leave() abort
	if getcmdline() =~# s:messages_command
		" Also cancel a clear left pending by an earlier command, which would
		" otherwise wipe the :messages output part-way through reading it.
		call functions#cancel_message_clear()
	else
		call functions#schedule_message_clear()
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
