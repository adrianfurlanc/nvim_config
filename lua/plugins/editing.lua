-- Editing helpers. Almost everything here is mappings, text objects or
-- commands with nothing to draw at startup, so it loads on VeryLazy (right
-- after the first screen paint) instead of during startup. Plugins whose
-- work starts in insert mode wait for InsertEnter instead.
return {
	{
		'raimondi/delimitmate', -- Autoclose brackets, parentheses, quotes, etc.
		event = 'InsertEnter',
		init = function()
			-- Closetag / DelimitMate
			-- vim.g.closetag_filenames = '*.html,*.xhtml,*.phtml'
			-- vim.g.closetag_xhtml_filenames = '*.xhtml,*.jsx'
			vim.g.delimitMate_matchpairs = '(:),[:],{:}'
		end,
	},
	{
		-- Replaces vim-sneak (s + 2 chars) and clever-f (f/F/t/T repeat with
		-- f/F). Both behaviours survive: 'char' mode re-maps f/F/t/T so that
		-- pressing the same key again advances to the next match, and 's'
		-- still takes two characters — but every match now gets a label, so
		-- you press the label instead of hammering 's' to cycle.
		'folke/flash.nvim',
		event = 'VeryLazy',
		opts = {
			-- The default style is "overlay", which paints the label over the
			-- character following the match: `const` renders as `conbt`, so
			-- the labels read as typos in the code. "inline" inserts them
			-- instead, hiding nothing -- the line shifts right while the
			-- labels are up. Colors for FlashLabel and friends are in
			-- lua/config/colors.lua.
			label = { style = 'inline' },
			modes = {
				-- Labelled '/' search is left off: wincent/loupe (see
				-- lua/plugins/search.lua) already owns search highlighting
				-- and 'shortmess', and flash's search mode also drives
				-- hlsearch. Flip this to true to try them together; <C-s>
				-- toggles flash on mid-search either way.
				search = { enabled = false },
			},
		},
		keys = {
			{ 's', mode = { 'n', 'x', 'o' }, function() require('flash').jump() end, desc = 'Flash' },
			-- Deliberately not mapped in visual mode: vim-surround owns
			-- visual 'S' (surround the selection).
			{ 'S', mode = { 'n', 'o' }, function() require('flash').treesitter() end, desc = 'Flash treesitter' },
			-- Operator-pending only, so normal-mode 'r' (replace char) is
			-- untouched. `yr` + label yanks a text object elsewhere on
			-- screen without moving the cursor.
			{ 'r', mode = 'o', function() require('flash').remote() end, desc = 'Remote flash' },
			{ 'R', mode = { 'o', 'x' }, function() require('flash').treesitter_search() end, desc = 'Treesitter search' },
			{ '<C-s>', mode = 'c', function() require('flash').toggle() end, desc = 'Toggle flash search' },
		},
	},
	{
		-- Extends <C-a>/<C-x> past vim's built-in "increment the integer under
		-- the cursor". Same keys, same count prefix (3<C-a>), same dot-repeat --
		-- but the thing under the cursor no longer has to be a number: dates,
		-- booleans, semver strings, hex colors and the operator pairs below all
		-- become steppable. g<C-a>/g<C-x> keep vim's meaning too: over a visual
		-- selection they step each line by an increasing multiple, which is what
		-- renumbers a pasted list 1,1,1 into 1,2,3.
		--
		-- Worth knowing in this setup: the tmux prefix is C-a (~/.tmux.conf),
		-- so inside tmux every C-a is swallowed and arrives as a literal one
		-- only on the second press, through the `bind C-a send-prefix` there.
		-- That catches g<C-a> as well -- the leading g reaches nvim, then the
		-- C-a half is taken exactly as it would be on its own -- so both
		-- increment keys are a double-tap while the <C-x> pair is untouched.
		-- None of it is introduced by this plugin: vim's own <C-a> has always
		-- been behind the same double-tap here.
		--
		-- Deliberately left on the default keys rather than moved somewhere
		-- tmux ignores, because `.` repeats an increment: the double-tap is
		-- paid once and every repeat after it is a single unshifted key. The
		-- count carries with it -- 3<C-a> then `.` adds three again -- and a
		-- fresh count on the dot (3.) overrides it.
		'monaqa/dial.nvim',
		-- Every mapping is listed with its mode because normal and visual take
		-- different manipulate() modes rather than the same function in both,
		-- and because the visual ones must not exist in normal mode.
		keys = {
			{ '<C-a>', mode = 'n', function() require('dial.map').manipulate('increment', 'normal') end, desc = 'Increment' },
			{ '<C-x>', mode = 'n', function() require('dial.map').manipulate('decrement', 'normal') end, desc = 'Decrement' },
			{ 'g<C-a>', mode = 'n', function() require('dial.map').manipulate('increment', 'gnormal') end, desc = 'Increment (sequential)' },
			{ 'g<C-x>', mode = 'n', function() require('dial.map').manipulate('decrement', 'gnormal') end, desc = 'Decrement (sequential)' },
			{ '<C-a>', mode = 'x', function() require('dial.map').manipulate('increment', 'visual') end, desc = 'Increment' },
			{ '<C-x>', mode = 'x', function() require('dial.map').manipulate('decrement', 'visual') end, desc = 'Decrement' },
			{ 'g<C-a>', mode = 'x', function() require('dial.map').manipulate('increment', 'gvisual') end, desc = 'Increment (sequential)' },
			{ 'g<C-x>', mode = 'x', function() require('dial.map').manipulate('decrement', 'gvisual') end, desc = 'Decrement (sequential)' },
		},
		config = function()
			local augend = require('dial.augend')

			-- Several of these overlap -- 1.2.3 is a semver but also the
			-- integer 1, #ff8800 is a hex color but also the integer 8800 --
			-- and dial settles that by match span, not by position in this
			-- list: the augend covering the most text around the cursor wins,
			-- so semver still beats decimal even when decimal is registered
			-- first (measured, not assumed). The most-specific-first order
			-- below is therefore for reading, not for behaviour.
			local common = {
				augend.semver.alias.semver,                    -- 1.2.3 -> 1.2.4
				augend.hexcolor.new({ case = 'prefer_lower' }), -- #ff8800 (keeps the case it finds)
				augend.date.alias['%Y-%m-%d'],                 -- 2026-08-14
				augend.date.alias['%H:%M'],                    -- 09:30
				augend.constant.alias.bool,                    -- true <-> false
				augend.integer.alias.hex,                      -- 0x1f
				augend.integer.alias.decimal_int,              -- 5, and -5 (decimal_int, not
				                                               -- decimal, so a leading minus is
				                                               -- part of the number rather than
				                                               -- a floor at zero)
			}

			-- on_filetype REPLACES the default group for that filetype rather
			-- than adding to it (see command.lua: it is an elseif over
			-- default), so every list below has to carry `common` itself.
			local function extend(...)
				local out = {}
				for _, list in ipairs({ ... }) do
					vim.list_extend(out, list)
				end
				return out
			end

			local script = {
				augend.constant.new({ elements = { 'let', 'const' }, cyclic = true }),
				-- word = false: these are punctuation, so the default
				-- word-boundary match would never find them.
				augend.constant.new({ elements = { '&&', '||' }, word = false, cyclic = true }),
			}

			require('dial.config').augends:register_group({ default = common })

			require('dial.config').augends:on_filetype({
				-- markdown_header steps the # level of the heading the cursor
				-- is on, so <C-a> promotes ## to ###.
				markdown = extend(common, { augend.misc.alias.markdown_header }),
				astro = extend(common, script),
				javascript = extend(common, script),
				javascriptreact = extend(common, script),
				svelte = extend(common, script),
				typescript = extend(common, script),
				typescriptreact = extend(common, script),
				vue = extend(common, script),
				-- css/scss deliberately absent: they want the hex colors and
				-- integers that `common` already carries, and adding an entry
				-- here would only restate it.
			})
		end,
	},
	{
		-- Splits a one-line block across lines and joins it back again. An
		-- object, array, argument list, JSX prop list, lua table or import list
		-- goes from one line to one item per line and back, with the trailing
		-- comma and the indentation fixed up on the way.
		--
		-- Treesitter-based rather than punctuation-based: it takes the node
		-- under the cursor and walks up until it finds one it has a preset for,
		-- so a comma inside a nested call or a string is not a split point. It
		-- needs no dependency on the nvim-treesitter plugin for the same reason
		-- rainbow-delimiters does not (lua/plugins/ui.lua) -- it calls core
		-- vim.treesitter, and the README names nvim-treesitter only as the thing
		-- that installs the parsers, which lua/plugins/treesitter.lua already
		-- does.
		'Wansmer/treesj',
		-- All three capitalised, and none of them are the plugin's own defaults
		-- of <leader>m/s/j. Two of those three are taken here: <Leader>m is the
		-- matchparen toggle and <Leader>s is scalpel (both lua/config/keymaps.lua,
		-- both spelled with a capital L, which is what hid them from a first
		-- look). Capitalising all three keeps them together as one family rather
		-- than taking the two free lowercase keys and leaving the odd one out.
		keys = {
			{ '<leader>M', function() require('treesj').toggle() end, desc = 'Split/join block' },
			{ '<leader>S', function() require('treesj').split() end, desc = 'Split block' },
			{ '<leader>J', function() require('treesj').join() end, desc = 'Join block' },
		},
		-- A config function rather than an opts table, because the astro entry
		-- below has to require() a module out of treesj itself. An opts table is
		-- built while this spec file is read, at startup, when treesj is not yet
		-- on the runtimepath and that require would fail; a config function runs
		-- after the plugin is loaded.
		config = function()
			local lang_utils = require('treesj.langs.utils')

			-- True when a tag node carries at least one attribute. Every astro
			-- attribute form is a plain `attribute` node -- quoted values,
			-- shorthand expressions (href={url}), spreads ({...props}),
			-- directives (client:load, class:list, is:raw) and bare booleans --
			-- so this is the whole question, not a heuristic. Plain html has
			-- only the quoted and bare forms, and both are that same node.
			local has_attribute = lang_utils.helpers.contains({ 'attribute' })

			-- html's own preset rebuilt, with `enable` added to the two tag
			-- nodes. That is what keeps a tag carrying no attributes from being
			-- split into `<ul` and a lone `>`. It is not a refusal: a false
			-- answer sends format.lua back up to the parent to look again
			-- (start_node = node:parent()), and the parent of a tag is the
			-- element, which has a preset of its own. So <Leader>M on `<ul>`
			-- splits and joins the element -- its children one to a line --
			-- while on `<div class="a">` it still splits the attributes, which
			-- is the one thing a tag with attributes is worth splitting for.
			--
			-- format_empty_node = false was the other candidate. It reads more
			-- directly, but it returns outright rather than climbing, so `<ul>`
			-- would do nothing at all.
			--
			-- A function returning a fresh table per language, rather than one
			-- table under two keys, and rebuilt rather than merged onto
			-- require('treesj.langs.html') -- both for the same reason.
			-- _prepare_presets() mutates preset tables in place at setup,
			-- flattening `both` into `split` and `join`. One object shared by
			-- two languages is premerged twice and stamped with whichever
			-- pairs() reached last, and a `both` override merged onto a table
			-- that has already been flattened loses to the `split` it was meant
			-- to feed -- silently, since the merge succeeds and only the value
			-- is wrong.
			local function tag_presets()
				return {
					start_tag = lang_utils.set_default_preset({
						both = {
							omit = { 'tag_name' },
							enable = has_attribute,
						},
					}),
					self_closing_tag = lang_utils.set_default_preset({
						both = {
							omit = { 'tag_name' },
							no_format_with = {},
							enable = has_attribute,
						},
					}),
					element = lang_utils.set_default_preset({
						join = { space_separator = false },
					}),
				}
			end

			require('treesj').setup({
				-- The plugin's own keys are <leader>m/s/j, and <leader>m is
				-- already the matchparen toggle in lua/config/keymaps.lua --
				-- which is the whole reason matchparen is kept off the
				-- disabled_plugins list in lua/config/lazy.lua. Taking two of
				-- the three and quietly losing the third would be worse than
				-- declaring all three in `keys` above, so the plugin's own set
				-- is off and toggle moves to <leader>M. s and j were unmapped.
				use_default_keymaps = false,
				-- Default is 120. Neither astro project sets printWidth in its
				-- .prettierrc, so prettier is formatting at its own default of
				-- 80; joining past that produces a line the next format would
				-- split again.
				max_join_length = 80,
				langs = {
					-- treesj ships no astro preset, so the template half of an
					-- .astro file answers `Language "astro" is not configured`
					-- and does nothing. The frontmatter works regardless --
					-- treesj resolves the language from the node rather than
					-- from 'filetype', and the frontmatter is injected
					-- typescript, which it does have a preset for.
					--
					-- Astro's grammar is html's with expressions added, and the
					-- three nodes html's preset keys on -- start_tag,
					-- self_closing_tag, element -- are all named the same in it
					-- (the same node names lua/plugins/ui.lua's rainbow queries
					-- match), so one preset serves both.
					astro = tag_presets(),
					-- html is given the same treatment because the lone `>` is
					-- treesj's shipped behaviour rather than anything astro
					-- introduced -- a bare `<ul>` in a .html file split the same
					-- way. vue and svelte build their own copies of the html
					-- preset with merge_preset, so they are untouched by this
					-- and would each need a line of their own.
					html = tag_presets(),
				},
			})
		end,
	},
	{ 'machakann/vim-highlightedyank', event = 'VeryLazy' },   -- Preview selected yanked text
	{ 'tommcdo/vim-lion', event = 'VeryLazy' },                -- Aligns text to a character with the gl and gL operators
	-- Commenting (gc/gcc) is built into Neovim 0.10+, so vim-commentary is
	-- gone. ts-comments extends the native operator with treesitter-aware
	-- comment strings, so markup inside .astro/JSX files gets <!-- --> or
	-- {/* */} while the script parts keep //.
	{ 'folke/ts-comments.nvim', opts = {}, event = 'VeryLazy' },
	{ 'tpope/vim-eunuch', event = 'VeryLazy' },                -- Helpers for unix
	{ 'tpope/vim-repeat', event = 'VeryLazy' },                -- Allow plugins to repeat
	{ 'tpope/vim-surround', event = 'VeryLazy' },              -- Add/Change surround characters
	{ 'tpope/vim-unimpaired', event = 'VeryLazy' },            -- Provides several pair
	{ 'wellle/targets.vim', event = 'VeryLazy' },              -- Better vim text objects
	{ 'nelstrom/vim-visual-star-search', event = 'VeryLazy' }, -- Use the star command with the visual mode selection and not the current word
	{
		'artnez/vim-wipeout', -- Close all buffers & tabs
		cmd = 'Wipeout',
	},
	{ 'qpkorr/vim-bufkill', event = 'VeryLazy' },              -- Unload/delete/wipe buffers without closing the window or split
	{
		'Valloric/ListToggle', -- Toggles the quickfix list and location-list open/closed with simple keybindings
		event = 'VeryLazy',
		init = function()
			-- The default quickfix map is <leader>q, which keymaps.lua already
			-- uses to pre-fill :q. Move it to <leader>c (mnemonic: :copen); the
			-- location list keeps the default <leader>l.
			--
			-- The plugin only maps with <unique> when both keys are left at
			-- their defaults; customizing one makes it map unconditionally, at
			-- VeryLazy — after keymaps.lua — so it would silently clobber any
			-- startup mapping on the same key. <leader>c is therefore kept free
			-- in keymaps.lua on purpose.
			vim.g.lt_quickfix_list_toggle_map = '<leader>c'
		end,
	},
	{
		'kshenoy/vim-signature', -- View marks in gutter
		event = 'VeryLazy',
		config = function()
			-- Loaded after VimEnter/ColorScheme have already fired, so run the
			-- setup those autocmds would have done: highlight groups, then a
			-- forced refresh to place signs for the already-open buffer.
			vim.fn['signature#utils#SetupHighlightGroups']()
			vim.fn['signature#sign#Refresh'](1)
		end,
	},
	{
		'mbbill/undotree', -- Visualize the undo history as a tree
		cmd = { 'UndotreeToggle', 'UndotreeShow' },
	},
}
