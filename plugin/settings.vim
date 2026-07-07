" ============================================================
" Options ('set' settings)
" ============================================================

set autoindent
set backspace=indent,eol,start                      " Backspace over indent, line breaks and insert start
set clipboard=unnamed                               " Yank and paste with the system clipboard
set copyindent                                      " Reuse existing indent characters on autoindent
set cursorline                                      " Highlight the current line
set diffopt=vertical                                " Open diffs in vertical splits
set diffopt+=iwhite                                 " Ignore whitespace changes in diffs
set encoding=utf-8 nobomb                           " UTF-8 without a byte order mark
set exrc                                            " Read project-local .nvimrc/.exrc (restricted by 'secure')
set fileformats=unix,dos                            " Prefer unix (LF) line endings, then dos (CRLF)
set formatoptions+=n                                " Recognize numbered lists when formatting
set formatoptions+=j                                " Remove comment leader when joining lines
set gdefault                                        " Substitute all matches per line by default
set guifont=Sauce\ Code\ Pro\ Medium\ Nerd\ Font\ Complete:h14 " Font for GUI clients
set hidden                                          " Switch buffers without saving first
set history=1000                                    " Remember 1000 command-line entries
set hlsearch                                        " Highlight search matches
set ignorecase                                      " Case-insensitive searching...
set incsearch                                       " Show matches while typing a search
set infercase                                       " Match case of typed text in completion
set laststatus=2                                    " Always show the statusline
set lazyredraw                                      " Don't redraw mid-macro
set linebreak                                       " Wrap lines at word boundaries
set listchars=tab:▸\ ,eol:¬,trail:·                 " Symbols for tab, eol and trailing spaces
set magic                                           " Standard regex special characters
set modeline                                        " Honor modelines in files
set modelines=2                                     " Look for modelines in first/last 2 lines
set nobackup                                        " No backup files
set noeol                                           " Don't force a trailing newline on write
set noerrorbells                                    " No beep on errors
set noshowmode                                      " Hide mode message (lightline shows it)
set nostartofline                                   " Keep cursor column on jumps
set noswapfile                                      " No swap files
set nrformats=                                      " Treat all numbers as decimal for CTRL-A/X
set number                                          " Show line numbers
set report=0                                        " Always report how many lines changed
set ruler                                           " Show cursor position in the statusline
set scrolloff=40                                    " Keep 40 lines visible around the cursor
set secure                                          " Restrict unsafe commands in exrc files
set shiftwidth=4                                    " Indent with 4 spaces
set tabstop=4                                       " Display tabs as 4 spaces
set shortmess+=A                                    " No swapfile-exists warning
set shortmess+=I                                    " No intro screen on startup
set showcmd                                         " Show pending command keys
set showmatch                                       " Briefly jump to the matching bracket
set sidescrolloff=3                                 " Same as scrolloff, but for columns
set smartcase                                       " ...unless the pattern has uppercase
set splitbelow                                      " Open horizontal splits below
set splitright                                      " Open vertical splits to the right
set switchbuf=usetab                                " Reuse windows/tabs already showing the buffer
set synmaxcol=200                                   " Only syntax-highlight the first 200 columns
set tildeop                                         " Make ~ (toggle case) work as an operator
set title                                           " Set the terminal window title
set ttimeoutlen=50                                  " 50ms key-code timeout (fast Esc)
set undodir=~/.config/nvim/undodir                  " Where undo history is stored
set undofile                                        " Persist undo history across sessions
set undolevels=1000                                 " Keep 1000 undo levels
set virtualedit=block                               " Free cursor movement in visual block mode
set visualbell                                      " Flash instead of beeping
set whichwrap=b,s,h,l,<,>,[,]                       " Let these keys move across line breaks
set wildignore=*.swp,*.bak,*.pyc,*.class,*.pdf,*.zip,*.mkv,*.mp4,*.mp3 " Files to ignore in completion
set wildmenu                                        " Command-line completion menu
set wildmode=list:full                              " List all matches, complete first match
set wrap                                            " Soft-wrap long lines
setlocal keywordprg=:help                           " K looks up the word under cursor with :help

if exists('&belloff')
	set belloff=all                                 " Never ring the bell, for any reason
endif

" Wrapped-line indentation and prefix
if has('linebreak')
	set breakindent                                 " Indent wrapped lines to match line start
	let &showbreak='⤷ '                             " ARROW POINTING DOWNWARDS THEN CURVING RIGHTWARDS (U+2937)
	if exists('&breakindentopt')
		set breakindentopt=shift:2                  " Emphasize broken lines by indenting them
	endif
endif

" Folding
if has('folding')
	set foldmethod=indent
	set foldlevelstart=99                           " Start with all folds open
	set foldtext=functions#foldtext()               " Custom fold summary line
endif

" Skip nvim's clipboard-provider auto-detection (probing $PATH and the
" environment at first use); on macOS we know it's pbcopy/pbpaste.
let g:clipboard = {
			\ 'name': 'pbcopy',
			\ 'copy':  {'+': 'pbcopy',  '*': 'pbcopy'},
			\ 'paste': {'+': 'pbpaste', '*': 'pbpaste'},
			\ 'cache_enabled': 0,
			\ }

" Commented out settings
" set gfn=Sauce\ Code\ Pro\ Medium\ Nerd\ Font\ Complete:h14 " GUI font (abbreviated form of guifont)
