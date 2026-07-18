-- Plugin registry.
--
-- minpac (and this module) are only loaded when :PackUpdate / :PackClean run.
-- nvim auto-loads everything under pack/*/start by itself, so registering
-- the plugins with minpac on every startup is wasted work.

local function init()
	vim.cmd.packadd('minpac')
	vim.fn['minpac#init']()

	local add = vim.fn['minpac#add']
	add('airblade/vim-gitgutter')           -- View git diff in gutter
	add('artnez/vim-wipeout')               -- Close all buffers & tabs
	add('bling/vim-bufferline')             -- View open buffers in cmd bar
	add('brooth/far.vim')                   -- Find and replace across multiple files with a preview window
	add('christoomey/vim-tmux-navigator')   -- Easier (tmux - vim) navigation
	add('neoclide/coc.nvim', { branch = 'release' }) -- Nodejs extension host for vim & neovim, load extensions like VSCode and host language servers. The release branch ships prebuilt — master needs a yarn build.
	add('coder/claudecode.nvim')            -- Claude Code integration for Neovim
	add('cocopon/lightline-hybrid.vim')     -- Hybrid theme for lightline
	add('edkolev/tmuxline.vim')             -- Create tmux line from lightline theme
	add('honza/vim-snippets')               -- Default snippet definitions for vim-snipmate and UltiSnips
	add('itchyny/lightline.vim')            -- Light and configurable statusline/tabline plugin
	add('Yggdroot/indentLine')              -- Display thin vertical lines at each indentation level for code indented with spaces
	add('janko-m/vim-test')                 -- Run tests for multiple languages/frameworks directly from Vim
	add('junegunn/fzf.vim')                 -- Use FZF for searching buffers, Ex commands, etc
	add('junegunn/vim-peekaboo')            -- Extends " / @ / CTRL-R to peek into registers and marks before using them
	add('justinmk/vim-sneak')               -- Goto 2x characters
	add('kshenoy/vim-signature')            -- View marks in gutter
	add('lilydjwg/colorizer')               -- Colorizes hex color codes (#rrggbb / #rgb) inline in the buffer
	add('luochen1990/rainbow')              -- Rainbow parentheses — colors nested brackets by depth for easier reading
	add('machakann/vim-highlightedyank')    -- Preview selected yanked text
	add('majutsushi/tagbar')                -- A class outline viewer for Vim
	add('mattn/emmet-vim')                  -- Emmet for web development
	add('josa42/vim-lightline-coc')         -- coc.nvim diagnostic indicators (errors/warnings) for lightline statusbar
	add('mhartington/oceanic-next')         -- Neovim color scheme inspired by Oceanic Next for Sublime — cool blue/teal palette, supports true color, italics, and terminal transparency
	add('mhinz/vim-grepper')                -- Async grep across multiple tools (rg, ag, git grep, etc.) with quickfix integration
	add('nelstrom/vim-visual-star-search')  -- Use the star command with the visual mode selection and not the current word
	add('pangloss/vim-javascript')          -- Vastly improved JavaScript indentation and syntax support
	add('posva/vim-vue')                    -- Syntax highlighting for Vue.js single-file components (.vue files)
	add('qpkorr/vim-bufkill')               -- Unload/delete/wipe buffers without closing the window or split
	add('radenling/vim-dispatch-neovim')    -- Adds Neovim terminal support to vim-dispatch
	add('rafi/awesome-vim-colorschemes')    -- Lots of Colorschemes
	add('raimondi/delimitmate')             -- Autoclose brackets, parentheses, quotes, etc.
	add('rhysd/clever-f.vim')               -- Extends f, F, t, T to repeat with f/F instead of semicolon, with highlighting
	add('RRethy/vim-illuminate')            -- Auto-highlights other uses of the word under the cursor via LSP, Tree-sitter, or regex
	add('ryanoasis/vim-devicons')           -- Pretty Icons
	add('scrooloose/nerdtree', { type = 'opt' }) -- File tree sidebar — opt: lazy-loaded on first use (see plugin/nerdtree.lua)
	add('sgur/vim-editorconfig')            -- Reads .editorconfig files and applies indent/style settings per project
	add('sheerun/vim-polyglot')             -- A collection of language packs for VIM
	add('shinchu/lightline-gruvbox.vim')    -- Gruvbox theme for light-line
	add('tmux-plugins/vim-tmux-focus-events') -- Better tmux handling
	add('tommcdo/vim-lion')                 -- Aligns text to a character with the gl and gL operators
	add('tpope/vim-commentary')             -- Toggle comments in vim
	add('tpope/vim-dispatch', { type = 'opt' }) -- Asynchronous build and test dispatcher — runs jobs in the background
	add('tpope/vim-eunuch')                 -- Helpers for unix
	add('tpope/vim-fugitive')               -- Vim wrapper for git
	add('tpope/vim-rhubarb')                -- GitHub :GBrowse handler for vim-fugitive
	add('tpope/vim-repeat')                 -- Allow plugins to repeat
	add('tpope/vim-surround')               -- Add/Change surround characters
	add('tpope/vim-unimpaired')             -- Provides several pair
	add('mbbill/undotree')
	add('Valloric/ListToggle')              -- Toggles the quickfix list and location-list open/closed with simple keybindings
	add('wellle/targets.vim')               -- Better vim text objects
	-- add('w0rp/ale')                         -- Asynchronous linter
	add('wuelnerdotexe/vim-astro')          -- Astro filetype detection, syntax highlighting and indentation (.astro files)
	add('wincent/loupe')                    -- Enhanced in-file search with smarter highlighting and sane defaults
	add('wincent/pinnacle')                 -- Utility functions for tweaking and reading Vim highlight groups
	add('wincent/scalpel')
	add('wincent/terminus')                 -- Enhanced terminal integration — cursor shape, mouse support, bracketed paste
	add('wincent/vcs-jump')                 -- Jumps to changed/conflicted hunks in a Git or Mercurial repo
	add('xolox/vim-misc')                   -- Required for vim-session

	-- Packages to install
	-- vim-session
	-- ale linter
end

local M = {}

function M.update()
	init()
	vim.fn['minpac#update']()
end

function M.clean()
	init()
	vim.fn['minpac#clean']()
end

return M
