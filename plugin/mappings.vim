" ============================================================
" Keyboard mappings
" (mapleader is set in init.vim, before this file is sourced)
" ============================================================

" NORMAL

" Behave like vim-vinegar. Entering NERDTree on the parent folder.
" NERDTree is an opt package, so load it first (no-op once loaded).
nnoremap <silent> - :<C-u>call functions#load_nerdtree() <Bar> silent edit <C-R>=empty(expand('%')) ? '.' : expand('%:p:h')<CR><CR>

nnoremap <expr> <CR> (empty(&buftype) && !empty(reg_recorded())) ? '@' . reg_recorded() : '<CR>'

" Use <Leader>s instead of default <Leader>e:
nmap <Leader>s <Plug>(Scalpel)

" Toggle show/hide invisible chars
nnoremap <leader>i :set list!<cr>

" Toggle FZF for fuzzy file search
nnoremap <C-p> :<C-u>FZF<CR>

" Easier split navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Move by visual row (not logical line), but store relative line number
" jumps in the jumplist when they exceed a threshold.
nnoremap <expr> j v:count ? (v:count >= 5 ? "m'" . v:count : '') . 'j' : 'gj'
nnoremap <expr> k v:count ? (v:count >= 5 ? "m'" . v:count : '') . 'k' : 'gk'

" Cycle through Quickfix list
nnoremap <silent> <Up> :cprevious<CR>
nnoremap <silent> <Down> :cnext<CR>
nnoremap <silent> <Left> :cpfile<CR>
nnoremap <silent> <Right> :cnfile<CR>

" Switch between last two files
nnoremap <leader><leader> <c-^>

" :only mapped to leader+o
nnoremap <leader>o :only<cr>

" <leader>p -- Show the path of the current file (mnemonic: path; useful when
" you have a lot of splits and the status line gets truncated).
nnoremap <Leader>p :echo expand('%:p:h') . '/'<CR>

" Edit vimrc in new buffer
nnoremap <leader>mv :edit $MYVIMRC<CR>

" Clears the search register
nnoremap <Leader>/ :nohlsearch<CR>

" Zap trailing whitespace
nnoremap <silent> <Leader>zz :call functions#zap()<CR>

" Delete Trailing Whitespace
nnoremap _$ :call functions#preserve("%s/\\s\\+$//e")<CR>

" Use \+e to edit a file in the directory of the current file
nnoremap <LocalLeader>e :edit <C-R>=expand('%:p:h') . '/'<CR>

" Auto Indent File
nnoremap _= :call functions#preserve("normal gg=G")<CR>

" Yank entire line
nnoremap yy :call functions#preserve("normal 0y$")<CR>

" Yank to end of line
nnoremap Y y$

" Find merge conflict markers
nnoremap <leader>fc /\v^[<\|=>]{7}( .*\|$)<CR>

nnoremap c* *Ncgn

" View changes in Gutter
nnoremap <leader>G :GitGutterToggle<CR>

nnoremap <Leader>v gv

" Mappings in the style of unimpaired-next
nmap <silent> [W <Plug>(ale_first)
nmap <silent> [w <Plug>(ale_previous)
nmap <silent> ]w <Plug>(ale_next)
nmap <silent> ]W <Plug>(ale_last)

" Toggle Folds
" nnoremap <Tab> za
" nnoremap <F6> <C-i>

" Go to functions
nmap [[ ?{<CR>w99[{
nmap ][ /}<CR>b99]}
nmap ]] j0[[%/{<CR>
nmap [] k$][%?}<CR>

" Commenting
nmap <Leader>c gcc

" Move lines around
nmap <C-Up> [e
nmap <C-Down> ]e

" Open files in same directory as current file
nmap <leader>ew :e %%
nmap <leader>es :sp %%
nmap <leader>ev :vsp %%
nmap <leader>et :tabe %%

" Cycle through line numbering modes
nnoremap <silent> <Leader>r :call functions#cycle_numbering()<CR>

" Stop annoying paren match highlighting from flashing all over the screen,
" or start it.
"
" (mnemonic: [m]atch paren)
nnoremap <silent> <Leader>m :execute (exists('g:loaded_matchparen') ? 'No' : 'Do') . 'MatchParen'<CR>

" VISUAL

" Visual shifting (does not exit Visual mode)
vnoremap < <gv
vnoremap > >gv

" Move several lines around within Visual Mode
vmap <C-Up> [egv
vmap <C-Down> ]egv

" Make dot work over visual line selections
xnoremap . :norm.<CR>

" Execute a macro over visual line selections
xnoremap Q :'<,'>:normal @q<CR>

" Split navigation from visual mode
xnoremap <C-h> <C-w>h
xnoremap <C-j> <C-w>j
xnoremap <C-k> <C-w>k
xnoremap <C-l> <C-w>l
xnoremap <C-]> <C-w>]


" COMMAND

" w!! to write a file as sudo
cnoremap w!! w !sudo tee % >/dev/null

" Open files in same directory as current file
cnoremap %% <C-R>=fnameescape(expand('%:h')).'/'<cr>

" Change Working Directory to that of the current file
cnoremap cd. lcd %:p:h

cnoremap <C-a> <Home>
cnoremap <C-e> <End>
