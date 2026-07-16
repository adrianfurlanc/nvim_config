" coc.nvim configuration.
"
" Extensions listed in g:coc_global_extensions are installed automatically
" the first time coc starts. Diagnostics display (virtual text, signs, etc.)
" is configured in coc-settings.json next to init.vim.

let g:coc_global_extensions = [
			\ '@yaegassy/coc-astro',
			\ 'coc-tsserver',
			\ 'coc-prettier',
			\ 'coc-json',
			\ 'coc-diagnostic',
			\ 'coc-eslint',
			\ ]

" Faster CursorHold so diagnostics and hover feel responsive (default 4000ms)
set updatetime=300

" Always show the sign column so text doesn't shift when diagnostics appear
set signcolumn=yes

function! s:check_backspace() abort
	let col = col('.') - 1
	return !col || getline('.')[col - 1] =~# '\s'
endfunction

" <Tab>/<S-Tab> walk coc's completion menu, <CR> confirms the selection.
" Replaces supertab, which can't drive coc's custom popup.
inoremap <silent><expr> <Tab>
			\ coc#pum#visible() ? coc#pum#next(1) :
			\ <SID>check_backspace() ? "\<Tab>" :
			\ coc#refresh()
inoremap <silent><expr> <S-Tab> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
			\ : "\<C-g>u\<CR>\<C-r>=coc#on_enter()\<CR>"

" Jump between diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" Code navigation
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gr <Plug>(coc-references)

" Documentation for the symbol under the cursor
nnoremap <silent> K :call CocActionAsync('doHover')<CR>

" Rename symbol, code-action menu, and apply the preferred quickfix for the
" diagnostic on the current line
nmap <Leader>rn <Plug>(coc-rename)
nmap <Leader>ca <Plug>(coc-codeaction-cursor)
nmap <Leader>qf <Plug>(coc-fix-current)
