" ============================================================
" init.vim
" ============================================================


" ============================================================
" PACKAGE MANAGEMENT
" ============================================================

" If FZF installed using git
set rtp+=~/.fzf

packadd minpac
call minpac#init()

call minpac#add('airblade/vim-gitgutter')           " View git diff in gutter
call minpac#add('artnez/vim-wipeout')               " Close all buffers & tabs
call minpac#add('bling/vim-bufferline')             " View open buffers in cmd bar
call minpac#add('blueyed/vim-diminactive')          " Dim inactive buffer in vim
call minpac#add('brooth/far.vim')                   " Find and replace across multiple files with a preview window
call minpac#add('christoomey/vim-tmux-navigator')   " Easier (tmux - vim) navigation
call minpac#add('coder/claudecode.nvim')            " Claude Code integration for Neovim
call minpac#add('cocopon/lightline-hybrid.vim')     " Hybrid theme for lightline
call minpac#add('edkolev/tmuxline.vim')             " Create tmux line from lightline theme
call minpac#add('ervandew/supertab')                " Complete with <Tab>
call minpac#add('honza/vim-snippets')               " Default snippet definitions for vim-snipmate and UltiSnips
call minpac#add('itchyny/lightline.vim')            " Light and configurable statusline/tabline plugin
call minpac#add('janko-m/vim-test')                 " Run tests for multiple languages/frameworks directly from Vim
call minpac#add('junegunn/fzf.vim')                 " Use FZF for searching buffers, Ex commands, etc
call minpac#add('junegunn/vim-peekaboo')            " Extends \" / @ / CTRL-R to peek into registers and marks before using them
call minpac#add('justinmk/vim-sneak')               " Goto 2x characters
call minpac#add('kshenoy/vim-signature')            " View marks in gutter
call minpac#add('lilydjwg/colorizer')               " Colorizes hex color codes (#rrggbb / #rgb) inline in the buffer
call minpac#add('luochen1990/rainbow')              " Rainbow parentheses — colors nested brackets by depth for easier reading
call minpac#add('machakann/vim-highlightedyank')    " Preview selected yanked text
call minpac#add('majutsushi/tagbar')                " A class outline viewer for Vim
call minpac#add('mattn/emmet-vim')                  " Emmet for web development
call minpac#add('maximbaz/lightline-ale')           " ALE linting indicators (errors/warnings) for lightline statusbar
call minpac#add('mhartington/oceanic-next')         " Neovim color scheme inspired by Oceanic Next for Sublime — cool blue/teal palette, supports true color, italics, and terminal transparency
call minpac#add('mhinz/vim-grepper')                " Async grep across multiple tools (rg, ag, git grep, etc.) with quickfix integration
call minpac#add('nelstrom/vim-visual-star-search')  " Use the star command with the visual mode selection and not the current word
call minpac#add('pangloss/vim-javascript')          " Vastly improved JavaScript indentation and syntax support
call minpac#add('posva/vim-vue')                    " Syntax highlighting for Vue.js single-file components (.vue files)
call minpac#add('qpkorr/vim-bufkill')               " Unload/delete/wipe buffers without closing the window or split
call minpac#add('radenling/vim-dispatch-neovim')    " Adds Neovim terminal support to vim-dispatch
call minpac#add('rafi/awesome-vim-colorschemes')    " Lots of Colorschemes
call minpac#add('raimondi/delimitmate')             " Autoclose brackets, parentheses, quotes, etc.
call minpac#add('rhysd/clever-f.vim')               " Extends f, F, t, T to repeat with f/F instead of semicolon, with highlighting
call minpac#add('RRethy/vim-illuminate')            " Auto-highlights other uses of the word under the cursor via LSP, Tree-sitter, or regex
call minpac#add('ryanoasis/vim-devicons')           " Pretty Icons
call minpac#add('scrooloose/nerdtree')              " File system tree explorer sidebar for navigating and managing files
call minpac#add('sgur/vim-editorconfig')            " Reads .editorconfig files and applies indent/style settings per project
call minpac#add('sheerun/vim-polyglot')             " A collection of language packs for VIM
call minpac#add('shinchu/lightline-gruvbox.vim')    " Gruvbox theme for light-line
call minpac#add('tmux-plugins/vim-tmux-focus-events') " Better tmux handling
call minpac#add('tommcdo/vim-lion')                 " Aligns text to a character with the gl and gL operators
call minpac#add('tpope/vim-commentary')             " Toggle comments in vim
call minpac#add('tpope/vim-dispatch', {'type':'opt'}) " Asynchronous build and test dispatcher — runs jobs in the background
call minpac#add('tpope/vim-eunuch')                 " Helpers for unix
call minpac#add('tpope/vim-fugitive')               " Vim wrapper for git
call minpac#add('tpope/vim-rhubarb')                " GitHub :GBrowse handler for vim-fugitive
call minpac#add('tpope/vim-repeat')                 " Allow plugins to repeat
call minpac#add('tpope/vim-surround')               " Add/Change surround characters
call minpac#add('tpope/vim-unimpaired')             " Provides several pair
call minpac#add('mbbill/undotree')
call minpac#add('Valloric/ListToggle')              " Toggles the quickfix list and location-list open/closed with simple keybindings
call minpac#add('wellle/targets.vim')               " Better vim text objects
" call minpac#add('w0rp/ale')                         " Asynchronous linter
call minpac#add('wincent/loupe')                    " Enhanced in-file search with smarter highlighting and sane defaults
call minpac#add('wincent/pinnacle')                 " Utility functions for tweaking and reading Vim highlight groups
call minpac#add('wincent/scalpel')
call minpac#add('wincent/terminus')                 " Enhanced terminal integration — cursor shape, mouse support, bracketed paste
call minpac#add('wincent/vcs-jump')                 " Jumps to changed/conflicted hunks in a Git or Mercurial repo
call minpac#add('xolox/vim-misc')                   " Required for vim-session

" Packages to install
" vim-session
" ale linter

command! PackUpdate call minpac#update()
command! PackClean call minpac#clean()


" ============================================================
" SET OPTIONS
" ============================================================

let mapleader = "\<Space>"

colorscheme gruvbox
set background=dark
set termguicolors

set encoding=utf-8

set autoindent
set backspace=indent,eol,start
set breakindent
set clipboard=unnamed
set copyindent
set diffopt=vertical
set diffopt+=iwhite
set encoding=utf-8 nobomb
set exrc
set fileformats=unix,dos
set fillchars=vert:│
set fillchars+=fold:·
set foldlevelstart=99
set foldmethod=marker
set foldtext=Foldtext()
set formatoptions+=j
set gdefault
" set gfn=Sauce\ Code\ Pro\ Medium\ Nerd\ Font\ Complete:h14
set guifont=Sauce\ Code\ Pro\ Medium\ Nerd\ Font\ Complete:h14
set hidden
set history=1000
set hlsearch
set ignorecase
set incsearch
set infercase
set laststatus=2
set lazyredraw
set linebreak
set listchars=tab:▸\ ,eol:¬,trail:·
set magic
set modeline
set modelines=2
set nobackup
set noeol
set noerrorbells
set noshowmode
set nostartofline
set noswapfile
set nrformats=
set number
" set relativenumber
set pastetoggle=<Leader>z
set report=0
set ruler
set scrolloff=40
set secure
set shiftwidth=4
set tabstop=4
set shortmess+=A
set shortmess+=I
set showcmd
set showbreak=\\\\
set showmatch
set smartcase
set splitbelow
set splitright
set switchbuf=usetab
set synmaxcol=200
set t_CO=256
set tildeop
set title
set ttimeoutlen=50
set undodir=~/.config/nvim/undodir
set undofile
set undolevels=1000
set virtualedit=block
set visualbell
set whichwrap=b,s,h,l,<,>,[,]
set wildignore=*.swp,*.bak,*.pyc,*.class,*.pdf,*.zip,*.mkv,*.mp4,*.mp3
set wildmenu
set wildmode=list:full
set wrap
setlocal keywordprg=:help

" Syntax highlighting
hi clear SignColumn
hi DiffAdd ctermbg=White ctermfg=Green
hi DiffDelete ctermbg=White ctermfg=Red
hi DiffChange ctermbg=White ctermfg=Cyan
hi Search ctermfg=red
hi Comment gui=italic cterm=italic
hi ColorColumn ctermbg=237

let g:gruvbox_italic=1
let g:oceanic_next_terminal_italic = 1

" Color 81st column of longer lines
call matchadd('ColorColumn', '\%81v', 100)

" Folding helpers
let s:middot='·'
let s:raquo='»'
let s:small_l='ℓ'

function! Foldtext() abort
	let l:lines='[' . (v:foldend - v:foldstart + 1) . s:small_l . ']'
	let l:first=substitute(getline(v:foldstart), '\v *', '', '')
	let l:dashes=substitute(v:folddashes, '-', s:middot, 'g')
	return s:raquo . s:middot . s:middot . l:lines . l:dashes . ': ' . l:first
endfunction


" ============================================================
" KEYBOARD MAPPINGS
" ============================================================

" NORMAL

" nnoremap <C-n> :NERDTreeToggle<CR>
nnoremap <silent> - :silent edit <C-R>=empty(expand('%')) ? '.' : expand('%:p:h')<CR><CR>

nnoremap <F5> :UndotreeToggle<CR>

" Map the Enter key to repeat last macro
nnoremap <Enter> @@

" Repeat last macro if in a normal buffer.
nnoremap <expr> <CR> empty(&buftype) ? '@@' : '<CR>'

" Use <Leader>s instead of default <Leader>e:
nmap <Leader>s <Plug>(Scalpel)

" Toggle show/hide invisible chars
nnoremap <leader>i :set list!<cr>

" Toggle FZF for fuzzy file search
nnoremap <C-p> :<C-u>FZF<CR>

" Easier buffer navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Store relative line number jumps in the jumplist if they exceed a threshold
nnoremap <expr> k (v:count >= 5 ? "m'" . v:count : '') . 'k'
nnoremap <expr> j (v:count >= 5 ? "m'" . v:count : '') . 'j'

" Cycle through Quickfix list
nnoremap <silent> <Up> :cprevious<CR>
nnoremap <silent> <Down> :cnext<CR>
nnoremap <silent> <Left> :cpfile<CR>
nnoremap <silent> <Right> :cnfile<CR>

" Switch between last two files
nnoremap <leader><leader> <c-^>

" :only mapped to leader+o
nnoremap <leader>o :only<cr>

" «leader>p -- Show the path of the current file (mnemonic: path; useful when
" you have a lot of splits and the status line gets truncated).
nnoremap <Leader>p :echo expand('%:p:h') . '/'<CR>

" Edit vimrc in new buffer
nnoremap <leader>mv :edit $MYVIMRC<CR>

" Clears the search register
nnoremap <Leader>/ :nohlsearch<CR>

nnoremap <silent> <Leader>zz :call functions#zap()<CR>


" Delete Trailing Whitespace
nnoremap _$ :call Preserve("%s/\\s\\+$//e")<CR>

" Use \+e to edit a new file in the same directory as the current buffer
nnoremap <LocalLeader>e :edit <C-R>=expand('%:p:h') . '/'<CR>

" Auto Indent File
nnoremap _= :call Preserve("normal gg=G")<CR>

" Yank entire line
nnoremap yy :call Preserve("normal 0y$")<CR>

" Yank to end of line
nnoremap Y y$

" Jump to next visual row (not logical line)
nnoremap j gj
nnoremap k gk

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
nnoremap <silent> <Leader>r :call Cycle_numbering()<CR>


" VISUAL
" Visual shifting (does not exit Visual mode)
vnoremap < <gv
vnoremap > >gv

" Move several lines around within Visual Mode
vmap <C-Up> [egv
vmap <C-Down> ]egv

" Visual mode mappings.
xnoremap <C-h> <C-w>h
xnoremap <C-]> <C-w>]
xnoremap <C-k> <C-w>k
xnoremap <C-l> <C-w>l


" COMMAND
" w!! to write a file as sudo
cnoremap w!! w !sudo tee % >/dev/null

" Open files in same directory as current file
cnoremap %% <C-R>=fnameescape(expand('%:h')).'/'<cr>

" Change Working Directory to that of the current file
cnoremap cd. lcd %:p:h


" Command mode mappings.
cnoremap <C-a> <Home>
cnoremap <C-e> <End>


" VISUAL (xnoremap)
" Make dot work over visual line selections
xnoremap . :norm.<CR>

xnoremap <C-h> <C-w>h
xnoremap <C-j> <C-w>j
xnoremap <C-k> <C-w>k
xnoremap <C-l> <C-w>l

" Execute a macro over visual line selections
xnoremap Q :'<,'>:normal @q<CR>



" ============================================================
" PLUGIN CONFIGURATION
" ============================================================

" ALE
let g:jsx_ext_required = 0

let g:ale_linters = {
			\ 'javascript': ['standard'],
			\ 'java': ['javac'],
			\ }

let g:ale_fixers = {
\   'javascript': ['prettier'],
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\}

let g:ale_lint_on_save = 1
let g:ale_lint_on_text_changed = 0




" Closetag / DelimitMate
" let g:closetag_filenames = '*.html,*.xhtml,*.phtml'
" let g:closetag_xhtml_filenames = '*.xhtml,*.jsx'
let delimitMate_matchpairs = "(:),[:],{:}"

" Grepper
let g:grepper = {}
let g:grepper.tools = ['rg', 'grep', 'git']
let g:grepper.rg={'grepprg': 'rg -H --no-heading --vimgrep'}

nnoremap <Leader>g :Grepper -tool rg<CR>

" Tells the vim-devicons plugin to add Unicode folder icons (📁-style glyphs from a Nerd Font) to directory nodes in NERDTree, so folders are visually distinguishable from files.
let g:WebDevIconsUnicodeDecorateFolderNodes = 1

" Rainbow
let g:rainbow_active = 1


" Session
let g:session_autosave='no'
let g:session_autoload='no'
let g:session_command_aliases = 1
let g:session_directory='~/.config/nvim/sessions'


" Sneak
let g:sneak#s_next = 1


" SuperTab
let g:SuperTabDefaultCompletionType = "context"
let g:SuperTabLongestEnhanced = 1
let g:SuperTabDefaultCompletionTypeDiscovery = [
			\ "&completefunc:<c-x><c-u>",
			\ "&omnifunc:<c-x><c-o>",
			\ ]
let g:SuperTabLongestHighlight = 1
let g:SuperTabClosePreviewOnPopupClose = 1


" Tagbar
let g:tagbar_compact = 1


" Ultisnips
" let g:UltiSnipsExpandTrigger="<tab>"
" let g:UltiSnipsJumpForwardTrigger="<tab>"
" let g:UltiSnipsJumpBackwardTrigger="<s-tab>"


" Lightline
let g:lightline = {
			\ 'colorscheme': 'gruvbox',
			\ 'active': {
			\   'left': [ [ 'mode', 'paste' ],
			\             [ 'fugitive', 'realpath', 'readonly', 'modified', ] ],
			\ 'right': [ [ 'linter_checking', 'linter_errors', 'linter_warnings', 'lineinfo' ],
			\              [ 'percent' ],
			\              [ 'fileformat', 'tagbar', 'filetype', ]]
			\},
			\
			\ 'component': {
			\         'tagbar': '%{tagbar#currenttag("%s", "", "f")}',
			\         'realpath': '%f',
			\ },
			\
			\ 'component_expand': {
			\  'linter_checking': 'lightline#ale#checking',
			\  'linter_warnings': 'lightline#ale#warnings',
			\  'linter_errors': 'lightline#ale#errors',
			\  'linter_ok': 'lightline#ale#ok',
			\ },
			\
			\ 'component_type' : {
			\     'linter_checking': 'left',
			\     'linter_warnings': 'warning',
			\     'linter_errors': 'error',
			\     'linter_ok': 'left',
			\ },
			\ 'component_function': {
			\   'fugitive': 'LightlineFugitive',
			\   'readonly': 'LightlineReadonly',
			\   'filetype': 'MyFiletype',
			\   'modified': 'LightlineModified',
			\   'fileformat': 'LightlineFileformat'
			\ },
			\}

let g:lightline.mode_map = {
			\ 'n'      : ' N ',
			\ 'i'      : ' I ',
			\ 'R'      : ' R ',
			\ 'v'      : ' V ',
			\ 'V'      : 'V-L',
			\ 'c'      : ' C ',
			\ "\<C-v>" : 'V-B',
			\ 's'      : ' S ',
			\ 'S'      : 'S-L',
			\ "\<C-s>" : 'S-B',
			\}

let g:lightline.separator    = { 'left': '', 'right': '' }
let g:lightline.subseparator = { 'left': '', 'right': '' }
" let g:lightline.colorscheme  = 'gruvbox'

let g:lightline#ale#indicator_checking = "  "
let g:lightline#ale#indicator_warnings = " "
let g:lightline#ale#indicator_errors   = " "

" The gruvbox lightline theme (lightline-gruvbox.vim) uses gray statusline
" text; brighten it to gruvbox's normal foreground (fg1, a warm off-white).
" The theme is a plugin file sourced AFTER init.vim, so the palette can
" only be patched on VimEnter, followed by a lightline re-init (the method
" from lightline's FAQ). Palette entries are [guifg, guibg, ctermfg,
" ctermbg]; the mode block (left[0]) keeps its dark-on-color text.
let s:statusline_fg   = '#d5c4a1'
let s:statusline_ctfg = 250
function! s:LightlineWhiteText() abort
	let palette = g:lightline#colorscheme#gruvbox#palette
	for mode in ['normal', 'insert', 'visual', 'replace']
		if has_key(palette, mode) && has_key(palette[mode], 'left') && len(palette[mode].left) > 1
			let palette[mode].left[1][0] = s:statusline_fg
			let palette[mode].left[1][2] = s:statusline_ctfg
		endif
	endfor
	let palette.normal.middle[0][0] = s:statusline_fg
	let palette.normal.middle[0][2] = s:statusline_ctfg
	for section in palette.normal.right
		let section[0] = s:statusline_fg
		let section[2] = s:statusline_ctfg
	endfor
	call lightline#init()
	call lightline#colorscheme()
	call lightline#update()
endfunction

augroup LightlineWhiteText
	autocmd!
	autocmd VimEnter * call s:LightlineWhiteText()
augroup END

function! MyFiletype()
	return winwidth(0) > 70 ? (strlen(&filetype) ? &filetype . ' ' . WebDevIconsGetFileTypeSymbol() : 'no ft') : ''
endfunction

function! LightlineReadonly()
	return &readonly && &filetype !=# 'help' ? ' ' : ''
endfunction

function! LightlineModified()
	return &ft =~ 'help' ? '' : &modified ? '+' : &modifiable ? '' : '-'
endfunction

function! LightlineFileformat()
	return winwidth(0) > 70 ? (&fileformat . ' ' . WebDevIconsGetFileFormatSymbol()) : ''
endfunction

function! LightlineFugitive()
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
function! UpdateGitStatus() abort
	let b:lightline_git_status = ''
	let path = expand('%:p')
	if empty(path) || !filereadable(path) || !exists('*FugitiveGitDir') || empty(FugitiveGitDir())
		return
	endif
	let out = system('git -C ' . shellescape(expand('%:p:h')) . ' status --porcelain -- ' . shellescape(path))
	if v:shell_error || empty(out)
		return
	endif
	if out[0] ==# '?'
		let b:lightline_git_status = ' [untracked]'
		return
	endif
	let parts = []
	if out[0] !=# ' '
		call add(parts, 'staged')
	endif
	if out[1] !=# ' '
		call add(parts, 'modified')
	endif
	if !empty(parts)
		let b:lightline_git_status = ' [' . join(parts, ',') . ']'
	endif
endfunction

augroup LightlineGitStatus
	autocmd!
	autocmd BufReadPost,BufWritePost,FocusGained * call UpdateGitStatus()
	autocmd User FugitiveChanged call UpdateGitStatus()
augroup END



" ============================================================
" FUNCTIONS
" ============================================================

" Alias grep to GrepperGrep
function! SetupCommandAlias(input, output)
  exec 'cabbrev <expr> '.a:input
        \ .' ((getcmdtype() is# ":" && getcmdline() is# "'.a:input.'")'
        \ .'? ("'.a:output.'") : ("'.a:input.'"))'
endfunction

call SetupCommandAlias("grep", "GrepperGrep")

" Preserve cursor position across commands
function! Preserve(command)
	let _s = @/
	let l  = line(".")
	let c  = col(".")
	execute a:command
	let @/ = _s
	call cursor(l, c)
endfunction

" Cycle through relativenumber + number, number (only), and no numbering
function! Cycle_numbering() abort
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


" ============================================================
" AUTOCOMMANDS
" ============================================================

augroup MyAutoCmd
	autocmd!
	autocmd MyAutoCmd BufWritePost $MYVIMRC nested source $MYVIMRC
augroup END

augroup git_files
	au!
	" Don't remember the last cursor position when editing commit
	" messages, always start on line 1
	autocmd filetype gitcommit call setpos('.', [0, 1, 1, 0])
augroup end

augroup vimrcEx
	autocmd!
	" When editing a file, always jump to the last known cursor position.
	" Don't do it for commit messages, when the position is invalid, or when
	" inside an event handler (happens when dropping a file on gvim).
	autocmd BufReadPost *
				\ if &ft != 'gitcommit' && line("'\"") > 0 && line("'\"") <= line("$") |
				\   exe "normal g`\"" |
				\ endif
augroup end

" Enable soft-wrapping for text files
autocmd FileType text,markdown,html,xhtml,eruby setlocal wrap linebreak nolist

" Fugitive: allow navigating up in git tree with ..
autocmd user fugitive
			\ if fugitive#buffer().type() =~# '^\%(tree\|blob\)$' |
			\   nnoremap <buffer> .. :edit %:h<CR> |
			\ endif

" Fugitive: prevent buffer list from being swamped
autocmd BufReadPost fugitive://* set bufhidden=delete

" ====Claude Code===
" claudecode.nvim
lua << EOF
require("claudecode").setup({
  terminal = {
    provider = "none", -- we will use tmux splits instead of Neovim terminal UI
  },
})
EOF

