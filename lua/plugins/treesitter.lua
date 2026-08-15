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

			local shared = require('nvim-treesitter-textobjects.shared')
			local select = require('nvim-treesitter-textobjects.select')
			local move = require('nvim-treesitter-textobjects.move')
			local swap = require('nvim-treesitter-textobjects.swap')

			-- The plugin resolves textobjects two different ways and only one
			-- of them descends into injected languages. `select` goes through
			-- shared.textobject_at_point, which walks every tree with
			-- LanguageTree:for_each_tree -- so `vaf` already works on the
			-- typescript inside an astro frontmatter. `move` and `swap` go
			-- through shared.find_best_range, which queries `parser:trees()[1]`
			-- under `parser:lang()` and nothing else. In an astro buffer that
			-- is the astro tree, and astro's textobjects.scm is `; inherits:
			-- html` -- no @parameter capture exists at all, and @function only
			-- matches on the html side. So <leader>a/<leader>A silently do
			-- nothing there, and ]m/[m are worse than inert: they jump to
			-- whatever the html query matched (measured: past the frontmatter,
			-- onto the first tag) instead of the next function. Same in vue,
			-- svelte, and any injected code block.
			--
			-- Reimplemented over every tree instead. Upstream main is identical
			-- as of 2026-08-15, so there is nothing to pull and no reason to
			-- wait -- this makes the motions wrong, not just missing, in the
			-- filetype this config edits most.
			--
			-- Faithful to the original for these queries: same first-wins-on-
			-- ties scoring, and it merges the multi-node captures the
			-- @parameter.outer patterns depend on. The one thing it drops is
			-- #set!/#make-range! metadata, which none of the ecma, typescript
			-- or tsx queries use.
			--
			-- Memoized on the same key upstream uses (buffer, tree root, query
			-- group), which a re-parse invalidates on its own. That is not
			-- optional: one uncached pass over a 2k-line tsx buffer is 14.4ms,
			-- and ]m would pay it on every press. Cached it is 0.02ms, so only
			-- the first motion after an edit costs anything. Values are weak,
			-- so the cache cannot pin a closed buffer's ranges in memory.
			--
			-- Startup is untouched (the plugin is still lazy on its keys, and
			-- this only runs when it loads), but the first ]m of a session in
			-- an astro buffer goes from 96ms to 134ms. The whole difference is
			-- one compile of the typescript textobjects query -- 37ms, since
			-- typescript inherits all of ecma -- which upstream never paid here
			-- only because it never consulted that query. A .ts buffer paid it
			-- on its first motion all along. It is cached per session
			-- afterwards (0.001ms), and both versions pay the 93ms parse(true)
			-- underneath it, which is the real cost of that first press.
			local range_cache = setmetatable({}, { __mode = 'v' })

			---@return table<string, Range6[]> ranges by capture name
			local function capture_ranges(bufnr, root, lang, query_group)
				local key = string.format('%d-%s-%s', bufnr, root:id(), query_group)
				if range_cache[key] then
					return range_cache[key]
				end

				local ranges = {} ---@type table<string, Range6[]>
				local query = vim.treesitter.query.get(lang, query_group)

				if query then
					for _, match in query:iter_matches(root, bufnr) do
						for id, nodes in pairs(match) do
							local name = query.captures[id]
							local srow, scol, sbyte = nodes[1]:range(true)
							local _, _, _, erow, ecol, ebyte = nodes[#nodes]:range(true)

							ranges[name] = ranges[name] or {}
							table.insert(ranges[name], { srow, scol, sbyte, erow, ecol, ebyte })
						end
					end
				end

				range_cache[key] = ranges
				return ranges
			end

			shared.find_best_range = function(bufnr, capture_string, query_group, filter, score)
				local capture = capture_string:gsub('^@', '')
				local parser = vim.treesitter.get_parser(bufnr, nil, { error = false })
				if not parser then
					return nil
				end
				parser:parse(true)

				local best, best_score ---@type Range6?, number?
				parser:for_each_tree(function(tree, ltree)
					local found = capture_ranges(bufnr, tree:root(), ltree:lang(), query_group)

					for _, range in ipairs(found[capture] or {}) do
						if filter(range) then
							local current = score(range)
							if not best or current > best_score then
								best, best_score = range, current
							end
						end
					end
				end)

				return best
			end

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
			-- vim's own next/previous change in a diff -- which is exactly what
			-- you want them to be in :Gdiffsplit. (They were also vim-gitgutter's
			-- hunk motions until that plugin was dropped; see
			-- lua/plugins/git.lua.) ]m/[m are vim's own "method start" motions,
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
			--
			-- Guarded, because upstream picks its swap target by byte position
			-- alone -- swap.lua's next_textobject filters on `start >=
			-- search_start` and nothing else. On the last parameter of a
			-- function that reaches into the next one and swaps across the
			-- boundary: `first(a, b)` + `second(x, y)` becomes `first(b, x)` +
			-- `second(y, a)`, moving `a` into a function it was never in. Same
			-- in a plain .ts file, so it is upstream's behaviour rather than a
			-- side effect of the find_best_range override above.
			--
			-- Scoping it properly would mean reimplementing swap_textobject and
			-- swap_nodes, both file-locals. This instead re-runs the candidate
			-- search upstream is about to run and declines to start the swap
			-- unless the winner is a sibling in the same parameter list, which
			-- also rules out the `x => g(y)` case a range-containment test
			-- would wave through. A capture that cannot be resolved back to a
			-- node declines too: the fallback worth having is the one that does
			-- nothing, not the one that reinstates the bug being guarded.
			--
			-- ignore_injections is the whole ballgame here -- it defaults to
			-- *true*, so without it get_node stops at astro's
			-- frontmatter_js_block, never matches the parameter's byte range,
			-- and every astro swap takes the unresolved path.
			local function node_at_range(buf, range)
				local node = vim.treesitter.get_node({
					bufnr = buf,
					pos = { range[1], range[2] },
					ignore_injections = false,
				})

				while node do
					local _, _, sbyte, _, _, ebyte = node:range(true)
					if sbyte == range[3] and ebyte == range[6] then
						return node
					end
					node = node:parent()
				end
			end

			local function swap_parameter(forward)
				local buf = vim.api.nvim_get_current_buf()
				local range = shared.textobject_at_point('@parameter.inner', 'textobjects', buf)
				local node = range and node_at_range(buf, range)
				local list = node and node:parent()

				if not list then
					return
				end

				-- Upstream's next_textobject/previous_textobject filter and
				-- score, so the candidate tested here is the one it would take.
				local filter, score
				if forward then
					filter = function(r)
						return r[3] >= range[6] and r[6] >= range[6] and not (r[3] == range[3] and r[6] == range[6])
					end
					score = function(r)
						return -r[3]
					end
				else
					filter = function(r)
						return r[6] <= range[3] and r[3] < range[3]
					end
					score = function(r)
						return r[6]
					end
				end

				local target = shared.find_best_range(buf, '@parameter.inner', 'textobjects', filter, score)
				local sibling = target and node_at_range(buf, target)

				if sibling and sibling:parent() and sibling:parent():equal(list) then
					local run = forward and swap.swap_next or swap.swap_previous
					run('@parameter.inner')
				end
			end

			map('n', '<leader>a', function()
				swap_parameter(true)
			end, 'Swap parameter with next')
			map('n', '<leader>A', function()
				swap_parameter(false)
			end, 'Swap parameter with previous')

			-- ;/, are deliberately not mapped to repeatable_move: flash.nvim
			-- owns them, and ]m/[m already repeat themselves.
		end,
	},
}
