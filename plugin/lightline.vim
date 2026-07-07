" Lightline configuration. The component functions live in
" autoload/statusline.vim so they are only loaded on first redraw.
let g:lightline = {
			\ 'colorscheme': 'gruvbox',
			\ 'active': {
			\   'left': [ [ 'mode', 'paste' ],
			\             [ 'fugitive', 'realpath', 'readonly', 'modified', ],
			\             [ 'bufferline' ] ],
			\ 'right': [ [ 'linter_checking', 'linter_errors', 'linter_warnings', 'lineinfo' ],
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

let g:lightline.separator    = { 'left': '', 'right': '' }
let g:lightline.subseparator = { 'left': '', 'right': '' }
" let g:lightline.colorscheme  = 'gruvbox'

let g:lightline#ale#indicator_checking = "  "
let g:lightline#ale#indicator_warnings = " "
let g:lightline#ale#indicator_errors   = " "

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
