-- Treesitter highlighting only (main branch, nvim 0.11+ API).
-- Indentation still comes from the regex plugins in lang.lua; treesitter
-- indent is experimental on the main branch. Needs the tree-sitter CLI
-- (brew install tree-sitter-cli) and a C compiler to build parsers.
return {
	{
		'nvim-treesitter/nvim-treesitter',
		branch = 'main',
		lazy = false, -- upstream: do not lazy-load
		build = ':TSUpdate',
		config = function()
			-- Parsers to keep installed; install() is async and skips
			-- anything already present.
			local parsers = {
				'astro', 'css', 'html', 'javascript', 'jsdoc',
				'json', 'lua', 'markdown', 'markdown_inline',
				'svelte', 'tsx', 'typescript', 'vim', 'vimdoc',
				'vue', 'yaml',
			}
			require('nvim-treesitter').install(parsers)

			-- Filetypes covered by the parsers above (ft name differs
			-- from parser name for the react/help ones).
			vim.api.nvim_create_autocmd('FileType', {
				group = vim.api.nvim_create_augroup('treesitter_highlight', {}),
				pattern = {
					'astro', 'css', 'html', 'javascript', 'javascriptreact',
					'json', 'lua', 'markdown',
					'svelte', 'typescript', 'typescriptreact', 'vim', 'help',
					'vue', 'yaml',
				},
				callback = function(args)
					-- Scheduled so the first frame paints before the (one-time
					-- per language) query compile runs: starting synchronously
					-- blocked the first screen ~100ms when opening the first
					-- ts/tsx file. pcall: don't error while a parser is still
					-- installing.
					vim.schedule(function()
						if vim.api.nvim_buf_is_loaded(args.buf) then
							pcall(vim.treesitter.start, args.buf)
						end
					end)
				end,
			})
		end,
	},
}
