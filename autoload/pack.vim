" Plugin registry.
"
" minpac (and this file) are only loaded when :PackUpdate / :PackClean run.
" nvim auto-loads everything under pack/*/start by itself, so registering
" the plugins with minpac on every startup is wasted work.

function! s:init() abort
	packadd minpac
	call minpac#init()

	call minpac#add('airblade/vim-gitgutter')           " View git diff in gutter
	call minpac#add('artnez/vim-wipeout')               " Close all buffers & tabs
	call minpac#add('bling/vim-bufferline')             " View open buffers in cmd bar
	call minpac#add('brooth/far.vim')                   " Find and replace across multiple files with a preview window
	call minpac#add('christoomey/vim-tmux-navigator')   " Easier (tmux - vim) navigation
	call minpac#add('coder/claudecode.nvim')            " Claude Code integration for Neovim
	call minpac#add('cocopon/lightline-hybrid.vim')     " Hybrid theme for lightline
	call minpac#add('edkolev/tmuxline.vim')             " Create tmux line from lightline theme
	call minpac#add('ervandew/supertab')                " Complete with <Tab>
	call minpac#add('honza/vim-snippets')               " Default snippet definitions for vim-snipmate and UltiSnips
	call minpac#add('itchyny/lightline.vim')            " Light and configurable statusline/tabline plugin
	call minpac#add('Yggdroot/indentLine')              " Display thin vertical lines at each indentation level for code indented with spaces 
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
	call minpac#add('scrooloose/nerdtree', {'type': 'opt'}) " File tree sidebar — opt: lazy-loaded on first use (see plugin/nerdtree.vim)
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
endfunction

function! pack#update() abort
	call s:init()
	call minpac#update()
endfunction

function! pack#clean() abort
	call s:init()
	call minpac#clean()
endfunction
