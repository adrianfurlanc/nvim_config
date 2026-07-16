" Cleaner/simpler clone of the built-in tabline, but without the window
" counts, the modified flag, or the close widget.
function! tabline#line() abort
  let l:line=''
  let l:current=tabpagenr()
  for l:i in range(1, tabpagenr('$'))
    if l:i == l:current
      let l:line.='%#TabLineSel#'
    else
      let l:line.='%#TabLine#'
    end
    let l:line.='%' . l:i . 'T' " Starts mouse click target region.
    let l:line.=' %{tabline#label(' . l:i . ')} '
  endfor
  let l:line.='%#TabLineFill#'
  let l:line.='%T' " Ends mouse click target region(s).
  return l:line
endfunction

function! tabline#label(n) abort
  let l:buflist=tabpagebuflist(a:n)
  let l:winnr=tabpagewinnr(a:n)
  let l:name=bufname(l:buflist[l:winnr - 1])
  if l:name ==# ''
    return '[No Name]'
  endif
  return pathshorten(fnamemodify(l:name, ':~:.'))
endfunction
