-- Closing a buffer from the bufferline -- clicking its × or right-clicking the
-- tab -- would otherwise run vim's :bdelete, which closes every window showing
-- that buffer, tearing down a split you never asked it to touch. vim-bufkill's
-- :BD deletes the buffer and leaves the window sitting on something else, which
-- is the whole reason that plugin is in lua/plugins/editing.lua.
--
-- The two do not speak the same language: :BD takes no argument and acts on the
-- current buffer, while bufferline hands over a bufnr. Hence this -- focus the
-- window showing it, kill, come back.
--
-- The bang matters twice. It skips bufkill's "displayed in multiple windows"
-- confirm(), which would otherwise stop a mouse click dead on a prompt, and it
-- discards unsaved changes -- no worse than the bdelete! it replaces, but the ×
-- is not a safe gesture on a modified buffer.
--
-- Known wart: with one buffer open in two windows, bufkill leaves one of them
-- on a nameless empty buffer. Still the better trade -- :bdelete took three
-- windows down to one in that same case.
--
-- Buffers that are not on screen skip all of it: no window can be destroyed, so
-- plain :bdelete is already the right thing.
local function bufkill_close(bufnr)
	local win = vim.fn.win_findbuf(bufnr)[1]
	if not win then return vim.cmd('bdelete! ' .. bufnr) end
	-- vim-bufkill loads on VeryLazy, so :BD may not exist yet; pull it in
	-- rather than error, and fall back if it cannot be had at all.
	if vim.fn.exists(':BD') ~= 2 then
		pcall(function() require('lazy').load({ plugins = { 'vim-bufkill' } }) end)
	end
	if vim.fn.exists(':BD') ~= 2 then return vim.cmd('bdelete! ' .. bufnr) end
	local back = vim.api.nvim_get_current_win()
	vim.api.nvim_set_current_win(win)
	-- bufkill tracks each window's buffer history in w:BufKillList, built by
	-- autocmds from the moment it loads, and errors outright on a window that
	-- predates it. Never let that turn a click on × into a stack trace: fall
	-- back to the behaviour we were replacing.
	local killed = pcall(vim.cmd, 'BD!')
	if vim.api.nvim_win_is_valid(back) then
		vim.api.nvim_set_current_win(back)
	end
	if not killed then vim.cmd('bdelete! ' .. bufnr) end
end

return {
	{
		-- Replaced Yggdroot/indentLine, which drew its guides through 'conceal':
		-- it set conceallevel/concealcursor on every buffer, the same mechanism
		-- markdown and json syntax use to hide their own punctuation, so the two
		-- fought over quotes and link brackets. This one draws with extmark
		-- virtual text and sets no options at all.
		'lukas-reineke/indent-blankline.nvim', -- Thin vertical line at each indentation level
		event = { 'BufReadPost', 'BufNewFile' },
		opts = {
			indent = {
				-- The default is ▎, a half-width block that reads as a bar of
				-- color at every level; │ is the thin rule indentLine drew and
				-- stays further back behind the code.
				char = '│',
				-- tab_char is left unset, so the same │ stands in for tab
				-- indentation -- which is most of it here, since 'expandtab' is
				-- off unless vim-sleuth says otherwise for a given file.
				--
				-- ibl reads 'listchars' for tab_char only if 'list' is already on
				-- when setup() runs, and it is off at startup, so the guide stays
				-- │ afterwards either way. That includes while <leader>i has
				-- 'list' on: the guide is overlaid virtual text and covers the ▸
				-- listchars would have drawn in the indent. Trailing · and the ¬
				-- at end of line are unaffected.
			},
			scope = {
				-- Drawing the guide for the scope under the cursor in a brighter
				-- color is the thing indentLine could not do, and most of the
				-- reason for the swap -- it comes from treesitter, so it follows
				-- the real block rather than counting columns.
				--
				-- The underlines it also wants to draw are off: they land on the
				-- first and last line of the scope, one of which is usually the
				-- line 'cursorline' is already marking.
				show_start = false,
				show_end = false,
			},
			-- The scope color is not set here but in the HIGHLIGHT_SETUP hook
			-- below; see the note there for why it has to be.
			--
			-- No exclude list on purpose. The defaults already cover help, man
			-- and gitcommit, and everything else worth skipping here -- tagbar,
			-- undotree, quickfix, terminals -- is a 'nofile' buffer, which the
			-- default buftype list excludes outright. oil is the one thing that
			-- slips through: its buffers are 'acwrite', so no buftype rule
			-- catches them. It needs no entry anyway -- a listing carries no
			-- leading whitespace, so there is no indent for a guide to mark.
			--
			-- If one is ever needed: the merge is a per-index tbl_deep_extend, so
			-- `filetypes = { 'foo' }` does not append to the defaults, it replaces
			-- the first of them ('lspinfo') and silently keeps the other eight.
		},
		-- A config function rather than `main = 'ibl'` plus opts, because the
		-- highlight hook has to be registered before setup() runs.
		config = function(_, opts)
			local hooks = require('ibl.hooks')

			-- Left alone, ibl takes IblScope from LineNr -- gruvbox bg4,
			-- #7c6f64 -- only one step up from the #504945 the inactive guides
			-- inherit from Whitespace, so the block you are in barely reads as
			-- different from the ones around it. #928374 is the next stop on
			-- gruvbox's own neutral ramp (its `gray`, already carrying
			-- InactiveText and unused symbols in lua/config/colors.lua):
			-- clearly the brighter of the two at a glance, and still a gray
			-- rather than a color, so it marks the block without pulling the
			-- eye off the code.
			--
			-- A hook rather than a plain :highlight, because ibl copies IblScope
			-- into the group it really draws with (@ibl.scope.char.1) while
			-- setting itself up, and redoes that on every ColorScheme -- which
			-- this config fires on each switch in and out of a markdown buffer.
			-- The hook is what it re-runs each time; a highlight set anywhere
			-- else is either read too late or wiped by the next `hi clear`.
			hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
				vim.api.nvim_set_hl(0, 'IblScope', { fg = '#928374' })
			end)

			require('ibl').setup(opts)
		end,
	},
	{
		'folke/todo-comments.nvim', -- Highlight TODO/FIX/NOTE keywords, and collect them into a list
		dependencies = { 'nvim-lua/plenary.nvim' },
		-- The highlighting has to be up when the file appears, so this loads
		-- with the buffer rather than waiting for the mapping below.
		event = { 'BufReadPost', 'BufNewFile' },
		keys = {
			-- Joins the <leader>f* finder family in lua/plugins/fzf.lua: the
			-- plugin ships an fzf-lua picker of its own, so the hits land in the
			-- same window every other search here uses. :TodoQuickFix puts the
			-- same list in the quickfix instead, which <Up>/<Down> step through.
			{ '<leader>ft', '<cmd>TodoFzfLua<cr>', desc = 'Find TODOs' },
			-- No ]t/[t to walk between them: vim-unimpaired already owns that
			-- pair for :tnext/:tprevious (MapNextFamily('t', ...)).
		},
		opts = {
			-- No gutter icons. The sign column is one column wide and coc's (see
			-- lua/plugins/coc.lua); coc's diagnostic priority of 10 beats this
			-- plugin's 8, so these would be the icons dropped -- and on a line
			-- carrying both, the diagnostic is the one worth the space. The
			-- keyword is highlighted in the text itself regardless.
			signs = false,
			highlight = {
				-- 'wide', the default, paints the background of the keyword and
				-- the characters around it, so `-- NOTE:` comes out as a filled
				-- block starting back at the comment leader. 'bg' keeps the block
				-- on the word.
				keyword = 'bg',
				-- Nothing after the keyword, a deliberate departure from the
				-- default 'fg'. This config annotates with NOTE: constantly and
				-- those notes run for paragraphs -- and with 'multiline' on (also
				-- a default) colouring what follows the keyword would tint whole
				-- explanations rather than a phrase. The keyword marks the line;
				-- the prose stays comment-coloured.
				after = '',
			},
			-- Every one of these is pinned to a gruvbox bright value, and all six
			-- have to be. The first four are the severity colors the coc signs
			-- and the lightline counters already use (lua/config/colors.lua):
			-- left alone they resolve through DiagnosticError/Warn/Info/Hint,
			-- which nvim defines itself in its own palette, so a FIX: would come
			-- out a red belonging to no colorscheme here.
			--
			-- 'default' (what PERF/OPTIM fall back to, having no color of their
			-- own) and 'test' are the ones that actually bite. Both ship as
			-- { 'Identifier', <hex> }, and the hex -- purple, magenta -- is only
			-- reached when Identifier is undefined, which it never is. gruvbox
			-- defines Identifier as #83a598, so PERF, TEST and TODO all came out
			-- the same blue. Purple and green are the two bright values the four
			-- above leave free.
			colors = {
				error = { '#fb4934' },
				warning = { '#fabd2f' },
				info = { '#83a598' },
				hint = { '#8ec07c' },
				default = { '#d3869b' },
				test = { '#b8bb26' },
			},
		},
	},
	{
		-- Rainbow parentheses — colors nested brackets by depth so a closing one
		-- can be matched to its opener by color.
		--
		-- Replaced luochen1990/rainbow, which did this with syntax regions: it
		-- counted every literal bracket character in the text, so a `<` in a
		-- comparison, or a brace inside a JSX string or a comment, opened a
		-- level and shifted the colors of everything after it. This one reads
		-- the syntax tree the highlighting already comes from, so only real
		-- delimiters count -- and its astro/vue/svelte/html queries color
		-- matching tag pairs too, not just brackets.
		--
		-- No dependency on the nvim-treesitter plugin: it calls core
		-- vim.treesitter directly and ships its own
		-- queries/<lang>/rainbow-delimiters.scm, so it is unaffected by the
		-- main-branch pin in lua/plugins/treesitter.lua and by that file's
		-- removal of the module system. All it wants is a parser, and the
		-- parser list there covers every filetype it has a query for.
		--
		-- It also attaches independently of the scheduled vim.treesitter.start()
		-- in treesitter.lua -- its own FileType autocmd builds the parser it
		-- needs -- so a buffer gets rainbow delimiters even for a filetype that
		-- file does not start treesitter highlighting for.
		--
		-- Colors are pinned in lua/config/colors.lua.
		'HiPhish/rainbow-delimiters.nvim',
		-- The repo's git submodules are test fixtures (other grammars, pulled in
		-- to run its test suite); the README asks installers to skip them.
		submodules = false,
		-- Eager, and it has to be. Everything the plugin does hangs off the
		-- FileType autocmd in its plugin/ file, and lazy.nvim re-fires only the
		-- event that loaded a plugin -- so loading on BufReadPost would register
		-- that autocmd just after FileType had already fired for the file being
		-- opened, leaving the first buffer of the session uncolored until it was
		-- reloaded. Cheap enough not to matter: the plugin file only registers
		-- three autocmds and defines seven highlight groups, ~0.05ms of startup.
		-- Every module that does real work (lib, the strategy, the queries) is
		-- required from inside the FileType callback, so that cost lands on the
		-- first file opened rather than on startup.
		--
		-- That per-file cost, measured against this same config with the plugin
		-- disabled: +3.6ms to open a 534-line .astro file, +7.9ms at 405 lines,
		-- +5.6ms at 45, and +3.3ms for this config's own 449-line functions.lua.
		--
		-- It scales with the number of delimiters, not with lines, which is the
		-- only way to get a frightening number out of it: a synthetic tsx file
		-- carrying nested brackets and JSX on every line runs 11.6 delimiters
		-- per line against ~0.9 for real .astro, and costs +307ms at 500 lines
		-- -- roughly 80x the real figure at that size. Nothing either project
		-- contains is remotely that dense, and across 246 .astro files from
		-- astrowind, astro-paper and astro.build the median file is 43-53 lines
		-- with exactly one over 500. Benchmark on real files, not generated ones.
		lazy = false,
		-- No setup() call and no opts: the defaults are the wanted behaviour
		-- (global strategy, the bundled queries, and a highlight priority
		-- between treesitter's and semantic tokens').
	},
	{
		'RRethy/vim-illuminate', -- Auto-highlights other uses of the word under the cursor via LSP, Tree-sitter, or regex
		event = 'VeryLazy', -- first highlight happens on cursor movement anyway
		config = function()
			-- Disabled for markdown (prose repeats words constantly, so the
			-- underlines are noise there); the first three entries are the
			-- plugin's defaults.
			require('illuminate').configure({
				filetypes_denylist = {
					'dirbuf',
					'dirvish',
					'fugitive',
					'markdown',
				},
			})
		end,
	},
	{
		-- Stays eager: the lightline tagbar component calls tagbar#currenttag()
		-- on every redraw, which errors if the plugin isn't on the runtimepath.
		'majutsushi/tagbar', -- A class outline viewer for Vim
		init = function()
			vim.g.tagbar_compact = 1
		end,
	},
	{
		-- Stays eager: statusline#filetype/fileformat call WebDevIcons*
		-- functions on the first redraw.
		'ryanoasis/vim-devicons', -- Pretty Icons
		init = function()
			-- Add Unicode folder icons (📁-style glyphs from a Nerd Font) to
			-- directory nodes in NERDTree, so folders are visually
			-- distinguishable from files.
			vim.g.WebDevIconsUnicodeDecorateFolderNodes = 1
		end,
	},
	{
		-- Owns 'tabline'. Lightline is told to keep its hands off it in
		-- lua/plugins/lightline.lua (g:lightline.enable.tabline), and this
		-- replaced the buffer list bling/vim-bufferline used to render inside
		-- the statusline. Open tab pages still show, as numbered indicators on
		-- the right-hand end of the bar.
		'akinsho/bufferline.nvim', -- Open buffers as clickable tabs along the top
		dependencies = { 'nvim-tree/nvim-web-devicons' },
		-- 'keys' would otherwise defer the plugin until one of them is pressed,
		-- leaving 'tabline' unset until then; it has to be up before the first
		-- redraw.
		lazy = false,
		keys = {
			-- Reorder, not navigate: these move the current buffer along the
			-- bar. The order holds for the session but is not written to a
			-- session file -- bufferline stores it in a global, and
			-- 'sessionoptions' does not include globals.
			{ '<leader>b<', '<cmd>BufferLineMovePrev<cr>', desc = 'Move buffer left' },
			{ '<leader>b>', '<cmd>BufferLineMoveNext<cr>', desc = 'Move buffer right' },
			-- Overrides unimpaired's ]b/[b, which are :bnext/:bprevious and so
			-- walk buffers in buffer-number order. Once b< or b> has moved a
			-- tab, that order no longer matches the bar and ]b lands somewhere
			-- other than the tab to the right. Cycling through bufferline
			-- instead follows what is on screen.
			{ ']b', '<cmd>BufferLineCycleNext<cr>', desc = 'Next buffer' },
			{ '[b', '<cmd>BufferLineCyclePrev<cr>', desc = 'Previous buffer' },
			-- Same reasoning for unimpaired's ]B/[B (:blast/:bfirst): the ends
			-- of the bar, not the highest and lowest buffer numbers.
			{ ']B', '<cmd>BufferLineGoToBuffer -1<cr>', desc = 'Last buffer' },
			{ '[B', '<cmd>BufferLineGoToBuffer 1<cr>', desc = 'First buffer' },
			-- Letters every visible tab and jumps to the one you type. Covers
			-- the case <leader><leader> (fzf-lua buffers) is clumsy at: the
			-- buffer is already on screen, so searching for it by name is more
			-- work than looking at it. gb is free -- coc takes gd and gy.
			{ 'gb', '<cmd>BufferLinePick<cr>', desc = 'Pick buffer' },
		},
		opts = {
			options = {
				close_command = bufkill_close,
				right_mouse_command = bufkill_close,
				-- Inert while separator_style is a slant: bufferline draws the
				-- indicator as blank padding under slant/slope, so the current
				-- buffer is marked by the tab shape and its lighter background
				-- instead. Kept because it takes effect again the moment the
				-- slant is dropped.
				--
				-- The ▎ glyph, not the 'underline' indicator style. An underline
				-- is a text attribute, and bufferline changes attributes several
				-- times across a single tab (the name is bold and italic, the
				-- icon and close button are forced plain), which this terminal
				-- renders as a line under some runs and not others -- three
				-- fragments with the name unmarked between them. Flattening the
				-- attributes did not fix it. A printed glyph has none of that
				-- to go wrong.
				indicator = { style = 'icon', icon = '▎' },
				-- Triangular separators, so the tabs read as tabs rather than
				-- as names divided by a rule. Needs the patched font that is
				-- already drawing the devicons and lightline's own powerline
				-- separators. If the glyphs come out clipped or overlapped,
				-- 'padded_slant' is the same shape with the padding some
				-- terminals need.
				separator_style = 'slant',
				-- No diagnostic counts up here: the gutter signs and the
				-- lightline coc_* components already report them.
				diagnostics = false,
				-- No offsets. They exist to hold the tabline clear of a
				-- sidebar pane, and there is no sidebar here: oil opens in
				-- the window you ran '-' from, the same as NERDTree did
				-- under the vinegar mapping this replaced.
			},
			highlights = {
				-- gruvbox leaves the indicator at bg1 (#3c3836), near-invisible
				-- against the selected tab's own #282828, so the default ▎ marks
				-- nothing. Bright green is what the scheme already uses for
				-- TabLineSel's text. Pinned rather than read back from the
				-- scheme, matching the lightline theme and the diagnostic colors
				-- in lua/config/colors.lua: markdown buffers switch to
				-- OceanicNext, and the bar should not change color with them.
				indicator_selected = { fg = '#b8bb26' },
			},
		},
	},
	{
		'folke/which-key.nvim', -- Pops up a panel of available mappings after a pending prefix key
		event = 'VeryLazy',
		opts = {},
	},
	{ 'lilydjwg/colorizer' },  -- Colorizes hex color codes (#rrggbb / #rgb) inline in the buffer
	{ 'wincent/pinnacle' },    -- Utility functions for tweaking and reading Vim highlight groups
	{ 'wincent/terminus' },    -- Enhanced terminal integration — cursor shape, mouse support, bracketed paste
}
