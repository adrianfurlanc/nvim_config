-- ============================================================
-- Filetype detection overrides
--
-- Only for cases nvim's builtin detection gets wrong or doesn't cover.
-- Most things people used to write ftdetect rules for are handled natively
-- now (*.mts/*.cts, .prettierignore, .npmignore, .dockerignore, ...), so
-- check with `:set filetype?` on a real file before adding anything here.
-- ============================================================

vim.filetype.add({
	filename = {
		-- coc reads its config as JSON-with-comments, and documents it that
		-- way, but the name says plain .json so nvim detects 'json' and the
		-- linter flags every // as a syntax error. tsconfig.json already
		-- gets 'jsonc' natively for the same reason.
		--
		-- Nothing is lost by the switch: nvim maps the jsonc filetype to the
		-- json treesitter parser, ships a syntax/jsonc.vim for the regex
		-- fallback, and coc-json activates on 'jsonc' as well as 'json'.
		['coc-settings.json'] = 'jsonc',
	},
})
