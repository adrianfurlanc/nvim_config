-- Treesitter highlighting only (main branch, nvim 0.11+ API).
-- Indentation still comes from the regex plugins in lang.lua; treesitter
-- indent is experimental on the main branch and, measured on a 2k-line tsx
-- file, costs ~8.8ms per <CR> against ~0.7ms for the regex indent (it scales
-- with buffer size, the regex one doesn't) for byte-identical output.
-- Needs the tree-sitter CLI (brew install tree-sitter-cli) and a C compiler
-- to build parsers.
return {
	{
		'nvim-treesitter/nvim-treesitter',
		branch = 'main',
		lazy = false, -- upstream: do not lazy-load
		build = ':TSUpdate',
		config = function()
			-- Parsers to keep installed; install() is async and skips
			-- anything already present. Beyond the languages we edit
			-- directly, this covers the ones injected into them: scss for
			-- <style lang="scss"> in vue/svelte/astro, bash for shell code
			-- fences in markdown, luadoc/luap/printf for this config's own
			-- lua, and diff/gitcommit/git_rebase for fugitive's buffers.
			local parsers = {
				'astro', 'bash', 'css', 'diff', 'git_rebase', 'gitcommit',
				'html', 'javascript', 'jsdoc', 'json', 'lua', 'luadoc',
				'luap', 'markdown', 'markdown_inline', 'printf', 'scss',
				'svelte', 'tsx', 'typescript', 'vim', 'vimdoc', 'vue',
				'yaml',
			}
			require('nvim-treesitter').install(parsers)

			-- vim.treesitter.start() clears 'syntax' (highlighter.new does
			-- `vim.bo[buf].syntax = ''`), but the indent scripts in lang.lua
			-- are built on syntax groups: yats' GetJsxIndent() is all
			-- synstack(), and the typescript/javascript/svelte/astro ones use
			-- synID() to skip matches inside strings and comments. With
			-- 'syntax' empty synID() returns 0 and synstack() returns {}, so
			-- every one of those checks silently takes its false branch and
			-- JSX stops indenting entirely.
			--
			-- Re-enabling regex syntax underneath treesitter gives them their
			-- state back. Treesitter's extmarks still win on priority, so
			-- nothing changes visually; the cost is ~0.13ms per keystroke and
			-- a one-time reload of the syntax file per buffer (~21ms for
			-- tsx, ~75ms for astro) that lands after the first paint, inside
			-- the schedule() below.
			--
			-- vue is absent on purpose: its indent script doesn't touch
			-- synID/synstack, so it doesn't need the regex syntax.
			--
			-- markdown.mdx is here for a different reason: highlighting, not
			-- indent. There is no mdx parser upstream, so .mdx files run the
			-- plain markdown one, which covers the prose but leaves the JSX
			-- unhighlighted -- treesitter only reaches a tag when markdown
			-- happens to classify it as an HTML block, so a component with a
			-- {} attribute (<Chart data={[1, 2]} />) is just paragraph text.
			-- vim-mdx-js's after/syntax fills exactly that gap: on a
			-- representative file it highlights 9% more of the buffer (tag
			-- names, attributes, string and brace expressions) and regresses
			-- nothing, since treesitter's extmarks still win where it has an
			-- opinion. Keyed on the compound filetype so plain markdown --
			-- which has nothing to gain -- doesn't pay the reload.
			local needs_regex_syntax = {
				astro = true,
				javascript = true,
				javascriptreact = true,
				['markdown.mdx'] = true,
				svelte = true,
				typescript = true,
				typescriptreact = true,
			}

			-- Filetypes covered by the parsers above (ft name differs
			-- from parser name for the react/help/jsonc ones).
			vim.api.nvim_create_autocmd('FileType', {
				group = vim.api.nvim_create_augroup('treesitter_highlight', {}),
				-- 'markdown.mdx' is listed separately on purpose: autocmd
				-- patterns are matched against the whole 'filetype' string, so
				-- 'markdown' does not fire for a compound one (unlike ftplugin
				-- loading, which does split on the dot -- that is how nvim's
				-- own ftplugin/markdown.lua ends up starting treesitter, and
				-- clearing 'syntax', on .mdx files in the first place).
				pattern = {
					'astro', 'css', 'html', 'javascript', 'javascriptreact',
					'json', 'jsonc', 'lua', 'markdown', 'markdown.mdx',
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
						if not vim.api.nvim_buf_is_loaded(args.buf) then
							return
						end

						local ft = vim.bo[args.buf].filetype

						-- Start at most once per buffer. This runs twice
						-- otherwise: nvim's own ftplugins already call start()
						-- for lua, markdown and help, and yats.vim's ftdetect
						-- uses `setlocal filetype=` (not setf), which re-fires
						-- FileType on every .ts/.tsx/.mts/.cts. Each extra call
						-- builds a second highlighter that stays registered on
						-- the same LanguageTree and keeps running
						-- on_changedtree on every edit.
						--
						-- Checked rather than returned on, because a buffer
						-- nvim started for us (markdown, for .mdx) still needs
						-- the syntax restore below.
						local started = vim.b[args.buf].ts_highlight
							or pcall(vim.treesitter.start, args.buf)

						-- The `~= ft` guard makes this idempotent too, so the
						-- second FileType on a .ts/.tsx buffer doesn't pay for
						-- a second reload of the syntax file.
						if started and needs_regex_syntax[ft] and vim.bo[args.buf].syntax ~= ft then
							vim.bo[args.buf].syntax = ft
						end
					end)
				end,
			})
		end,
	},
	{
		-- Semantic text objects (function, class) and function motions.
		-- Complements targets.vim rather than replacing it: targets is
		-- syntax-agnostic (pairs, quotes, separators, arguments) and works in
		-- buffers with no parser, so it keeps ia/aa; this one supplies the
		-- objects that need a syntax tree to exist at all.
		--
		-- branch = 'main' is mandatory: the master branch drives the removed
		-- require('nvim-treesitter.configs') API and errors against the main
		-- branch pinned above. There is no runtime dependency on
		-- nvim-treesitter's lua modules -- the plugin only calls core
		-- vim.treesitter -- so all it needs from the spec above is the
		-- installed parsers, plus its own queries/<lang>/textobjects.scm being
		-- on the runtimepath.
		'nvim-treesitter/nvim-treesitter-textobjects',
		branch = 'main',
		-- Every mapping is listed with its modes because the select objects
		-- only exist in visual and operator-pending; a default normal-mode
		-- stub would never fire from `daf`.
		keys = {
			{ 'af', mode = { 'x', 'o' } },
			{ 'if', mode = { 'x', 'o' } },
			{ 'ac', mode = { 'x', 'o' } },
			{ 'ic', mode = { 'x', 'o' } },
			{ 'ai', mode = { 'x', 'o' } },
			{ 'ii', mode = { 'x', 'o' } },
			{ 'al', mode = { 'x', 'o' } },
			{ 'il', mode = { 'x', 'o' } },
			{ ']m', mode = { 'n', 'x', 'o' } },
			{ '[m', mode = { 'n', 'x', 'o' } },
			{ ']M', mode = { 'n', 'x', 'o' } },
			{ '[M', mode = { 'n', 'x', 'o' } },
			{ '<leader>a', mode = 'n' },
			{ '<leader>A', mode = 'n' },
		},
		config = function()
			require('nvim-treesitter-textobjects').setup({
				select = {
					-- Jump forward to the next match when the cursor is not
					-- inside one, so `vaf` from the blank line above a function
					-- still selects it.
					lookahead = true,
					-- Outer objects linewise: charwise `daf` leaves the
					-- function's own blank line behind. Inner stays charwise.
					-- Safe for conditionals because ecma only captures
					-- if_statement/switch_statement as @conditional.outer --
					-- no ternaries, which would be wrong to take linewise.
					selection_modes = {
						['@function.outer'] = 'V',
						['@class.outer'] = 'V',
						['@conditional.outer'] = 'V',
						['@loop.outer'] = 'V',
					},
				},
				move = { set_jumps = true }, -- <C-o> comes back
			})

			local select = require('nvim-treesitter-textobjects.select')
			local move = require('nvim-treesitter-textobjects.move')
			local swap = require('nvim-treesitter-textobjects.swap')

			-- The main branch creates no mappings of its own; the
			-- `keymaps = { ['af'] = '@function.outer' }` table in most configs
			-- online is master-branch syntax and is silently ignored here.
			local function map(mode, lhs, fn, desc)
				vim.keymap.set(mode, lhs, fn, { silent = true, desc = desc })
			end

			map({ 'x', 'o' }, 'af', function()
				select.select_textobject('@function.outer')
			end, 'Select outer function')
			map({ 'x', 'o' }, 'if', function()
				select.select_textobject('@function.inner')
			end, 'Select inner function')
			map({ 'x', 'o' }, 'ac', function()
				select.select_textobject('@class.outer')
			end, 'Select outer class')
			map({ 'x', 'o' }, 'ic', function()
				select.select_textobject('@class.inner')
			end, 'Select inner class')
			-- ai/ii and al/il are the keys vim-indent-object would want, but
			-- that plugin is not installed here and all four are unmapped.
			map({ 'x', 'o' }, 'ai', function()
				select.select_textobject('@conditional.outer')
			end, 'Select outer conditional')
			map({ 'x', 'o' }, 'ii', function()
				select.select_textobject('@conditional.inner')
			end, 'Select inner conditional')
			map({ 'x', 'o' }, 'al', function()
				select.select_textobject('@loop.outer')
			end, 'Select outer loop')
			map({ 'x', 'o' }, 'il', function()
				select.select_textobject('@loop.inner')
			end, 'Select inner loop')

			-- ]m/[m/]M/[M rather than the ]f/]c the README suggests: ]f/[f are
			-- unimpaired's next/previous file in the directory, and ]c/[c are
			-- gitgutter's hunk motions -- mapped <buffer> from its BufEnter
			-- and guarded by `maparg(']c', 'n') ==# ''`, so taking them here
			-- would not clash loudly, it would just stop gitgutter from ever
			-- installing them. ]m/[m are vim's own "method start" motions,
			-- unmapped in this config and already the right mnemonic.
			map({ 'n', 'x', 'o' }, ']m', function()
				move.goto_next_start('@function.outer')
			end, 'Next function start')
			map({ 'n', 'x', 'o' }, '[m', function()
				move.goto_previous_start('@function.outer')
			end, 'Previous function start')
			map({ 'n', 'x', 'o' }, ']M', function()
				move.goto_next_end('@function.outer')
			end, 'Next function end')
			map({ 'n', 'x', 'o' }, '[M', function()
				move.goto_previous_end('@function.outer')
			end, 'Previous function end')

			-- The one thing targets.vim cannot do: reorder arguments in place.
			-- Dot-repeatable (the plugin routes it through 'opfunc').
			map('n', '<leader>a', function()
				swap.swap_next('@parameter.inner')
			end, 'Swap parameter with next')
			map('n', '<leader>A', function()
				swap.swap_previous('@parameter.inner')
			end, 'Swap parameter with previous')

			-- ;/, are deliberately not mapped to repeatable_move: vim-sneak
			-- owns them, and ]m/[m already repeat themselves.
		end,
	},
}
