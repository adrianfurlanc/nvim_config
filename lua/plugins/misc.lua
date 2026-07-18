return {
	{
		'honza/vim-snippets', -- Default snippet definitions for vim-snipmate and UltiSnips
		-- Disabled: nothing reads these — no UltiSnips/snipmate, and
		-- coc-snippets is not among the coc extensions. Re-enable if a
		-- snippet engine arrives.
		enabled = false,
	},
	{
		'xolox/vim-misc', -- Required for vim-session
		-- Disabled until vim-session is actually installed (add
		-- xolox/vim-session here when it is, and restore the init below)
		enabled = false,
		init = function()
			vim.g.session_autosave = 'no'
			vim.g.session_autoload = 'no'
			vim.g.session_command_aliases = 1
			vim.g.session_directory = '~/.config/nvim/sessions'
		end,
	},
	{
		'w0rp/ale', -- Asynchronous linter (currently disabled; config kept for when it returns)
		enabled = false,
		init = function()
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
		end,
	},

	-- Ultisnips (not installed)
	-- vim.g.UltiSnipsExpandTrigger = '<tab>'
	-- vim.g.UltiSnipsJumpForwardTrigger = '<tab>'
	-- vim.g.UltiSnipsJumpBackwardTrigger = '<s-tab>'
}
