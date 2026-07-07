" ============================================================
" General autocommands
" (plugin-specific ones live with their plugin's config file)
" ============================================================

augroup WincentAutocmds
	autocmd!
	" Rebalance splits when the terminal window is resized
	autocmd VimResized * execute "normal! \<c-w>="

	if exists('*matchaddpos')
      autocmd BufEnter,FocusGained,VimEnter,WinEnter * call autocmds#focus_window()
      autocmd FocusLost,WinLeave * call autocmds#blur_window()
    endif
augroup END

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
