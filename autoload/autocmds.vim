let g:WincentColorColumnBlacklist = ['diff', 'undotree', 'nerdtree', 'qf']
let g:WincentCursorlineBlacklist = ['command-t']
let g:WincentMkviewFiletypeBlacklist = ['diff', 'hgcommit', 'gitcommit']

function! autocmds#attempt_select_last_file() abort
  let l:previous=expand('#:t')
  if l:previous != ''
    call search('\v<' . l:previous . '>')
  endif
endfunction

function! autocmds#blur_window() abort
  setlocal nocursorline
  if autocmds#should_colorcolumn()
    if !exists('w:wincent_matches')
      " Instead of unconditionally resetting, append to existing array.
      " This allows us to gracefully handle duplicate autocmds.
      let w:wincent_matches=[]
    endif
    let l:height=&lines
    let l:slop=l:height / 2
    let l:start=max([1, line('w0') - l:slop])
    let l:end=min([line('$'), line('w$') + l:slop])
    while l:start <= l:end
      let l:next=l:start + 8
      let l:id=matchaddpos(
            \   'InactiveText',
            \   range(l:start, min([l:end, l:next])),
            \   1000
            \ )
      call add(w:wincent_matches, l:id)
      let l:start=l:next
    endwhile
  endif
endfunction

function! autocmds#should_colorcolumn() abort
  return index(g:WincentColorColumnBlacklist, &filetype) == -1
endfunction

function! autocmds#focus_window() abort
  setlocal cursorline
  if autocmds#should_colorcolumn()
    if exists('w:wincent_matches')
      for l:match in w:wincent_matches
        try
          call matchdelete(l:match)
        catch /.*/
          " In testing, not getting any error here, but being ultra-cautious.
        endtry
      endfor
      let w:wincent_matches=[]
    endif
  endif
endfunction
