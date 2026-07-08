" ============================================================
" init.vim — startup core only
"
" Everything else lives in:
"   plugin/settings.vim    — options ('set' commands)
"   plugin/mappings.vim    — key mappings
"   plugin/autocmds.vim    — general autocommands
"   plugin/color.vim       — highlight and cursor tweaks
"   plugin/<plugin>.vim    — per-plugin configuration
"   after/plugin/          — settings that override a plugin's defaults
"   autoload/functions.vim — helper functions, loaded on first use
"   autoload/statusline.vim— lightline components, loaded on first redraw
"   autoload/pack.vim      — plugin list (minpac, loaded on demand)
" ============================================================

" If FZF installed using git
set rtp+=~/.fzf

let mapleader = "\<Space>"

" Plugins under pack/*/start are auto-loaded by nvim itself, so minpac and
" the plugin registry are only loaded when actually managing packages.
command! PackUpdate call pack#update()
command! PackClean  call pack#clean()

" Colorscheme. The italics flags must be set before the scheme is sourced,
" and 'background' before :colorscheme — setting it afterwards makes Vim
" source the whole colorscheme a second time. Gruvbox is the default;
" markdown buffers switch to OceanicNext (see plugin/color.vim).
let g:gruvbox_italic = 1
let g:oceanic_next_terminal_italic = 1
set termguicolors
set background=dark
colorscheme gruvbox


source $VIMRUNTIME/macros/matchit.vim
