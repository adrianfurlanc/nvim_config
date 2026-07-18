-- ALE (currently disabled in the plugin list; config kept for when it returns)
vim.g.ale_linters = {
	javascript = { 'standard' },
	java = { 'javac' },
}

vim.g.ale_fixers = {
	javascript = { 'prettier' },
	['*'] = { 'remove_trailing_lines', 'trim_whitespace' },
}

vim.g.ale_lint_on_save = 1
vim.g.ale_lint_on_text_changed = 0
