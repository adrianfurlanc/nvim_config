" Lightline configuration. The component functions live in
" autoload/statusline.vim so they are only loaded on first redraw.
"
" 'enable.tabline' is off because the tabline is rendered by
" autoload/tabline.vim instead (see plugin/tabline.vim); lightline defaults it
" to 1 and would otherwise clobber 'tabline' on init.
let g:lightline = {
			\ 'colorscheme': 'gruvbox',
			\ 'enable': { 'statusline': 1, 'tabline': 0 },
			\ 'active': {
			\   'left': [ [ 'mode', 'paste' ],
			\             [ 'fugitive', 'realpath', 'readonly', 'modified', ],
			\             [ 'bufferline' ] ],
			\ 'right': [ [ 'lineinfo' ],
			\              [ 'coc_errors', 'coc_warnings', 'coc_status' ],
			\              [ 'percent' ],
			\              [ 'fileformat', 'tagbar', 'filetype', ]]
			\},
			\
			\ 'component': {
			\         'tagbar': '%{tagbar#currenttag("%s", "", "f")}',
			\         'realpath': '%f',
			\         'bufferline': '%{bufferline#refresh_status()}%{g:bufferline_status_info.before . g:bufferline_status_info.current . g:bufferline_status_info.after}',
			\ },
			\
			\ 'component_function': {
			\   'fugitive': 'statusline#fugitive',
			\   'readonly': 'statusline#readonly',
			\   'filetype': 'statusline#filetype',
			\   'modified': 'statusline#modified',
			\   'fileformat': 'statusline#fileformat'
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

let g:lightline#coc#indicator_warnings = "•"
let g:lightline#coc#indicator_errors   = "×"

" Fills in the coc_* entries of component_expand/component_type used by the
" 'right' section above (the refresh autocmds live in the plugin itself).
" Must run after the indicator variables are set — they are read when the
" autoload file first loads.
call lightline#coc#register()

" Brighten the gray statusline text of the gruvbox lightline theme
" (see statusline#brighten for the full story).
augroup LightlineWhiteText
	autocmd!
	autocmd VimEnter * call statusline#brighten()
augroup END

" Keep the per-buffer git state used by the fugitive component fresh
augroup LightlineGitStatus
	autocmd!
	autocmd BufReadPost,BufWritePost,FocusGained * call statusline#update_git_status()
	autocmd User FugitiveChanged call statusline#update_git_status()
augroup END
