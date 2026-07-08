" Move current line up and down
function! s:Move(address, at_limit)
  if !a:at_limit
    execute 'move ' . a:address
    normal! ==
  endif
endfunction

function! mappings#normal#move_up() abort
  let l:at_top=line('.') == 1
  call s:Move('.-2', l:at_top)
endfunction

function! mappings#normal#move_down() abort
  let l:at_bottom=line('.') == line('$')
  call s:Move('.+1', l:at_bottom)
endfunction
