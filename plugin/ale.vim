" ALE (currently disabled in the plugin list; config kept for when it returns)
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
