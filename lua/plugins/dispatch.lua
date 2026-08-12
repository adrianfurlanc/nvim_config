-- vim-dispatch, which owns the quickfix list while an external tool runs.
-- Everything that fills that list asynchronously goes through it: :Lint,
-- :Eslint, :Stylelint, :Typecheck and :AstroCheck all end up in
-- functions.lint(), which sets 'compiler' and then hands the target to :Make
-- (see lua/functions.lua, and after/compiler/ for the compiler plugins).
--
-- Lazy-loaded on its own commands, so it costs nothing until the first check
-- is run. That is also how it gets pulled in: :Make is what loads it.
--
-- Named for the plugin rather than for testing, which is what this file was
-- called until vim-test was dropped from it. vim-test held the five
-- :Test* commands and was never mapped or called from anywhere in this
-- config, so the filename advertised the unused half of the file and hid the
-- half five commands depend on.
return {
	{
		'tpope/vim-dispatch', -- Asynchronous build and test dispatcher — runs jobs in the background
		cmd = { 'Dispatch', 'Make', 'Focus', 'Start' },
		dependencies = {
			'radenling/vim-dispatch-neovim', -- Adds Neovim terminal support to vim-dispatch
		},
	},
}
