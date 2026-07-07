" Fold indents
if has('folding')
  " if has ('windows')
    " set fillchars=vert:\|
  " endif
  set foldmethod=indent
  set foldlevelstart=99
endif

" remove comment leader when joining comment lines
if v:version > 703 || v:version == 703 && has('patch541')
  set formatoptions+=j
endif
