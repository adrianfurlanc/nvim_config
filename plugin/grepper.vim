" Grepper
let g:grepper = {}
let g:grepper.tools = ['rg', 'grep', 'git']
let g:grepper.rg={'grepprg': 'rg -H --no-heading --vimgrep'}

nnoremap <Leader>g :Grepper -tool rg<CR>

" Alias :grep to :GrepperGrep
call functions#setup_command_alias("grep", "GrepperGrep")
