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
			-- and gitcommit, and everything else worth skipping here -- NERDTree,
			-- tagbar, undotree, quickfix, terminals -- is a 'nofile' buffer,
			-- which the default buftype list excludes outright.
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
		'luochen1990/rainbow', -- Rainbow parentheses — colors nested brackets by depth for easier reading
		init = function()
			vim.g.rainbow_active = 1
		end,
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
				-- Sit the buffer tabs beside the NERDTree pane rather than
				-- running the full width across the top of it.
				offsets = { { filetype = 'nerdtree', text = 'File Explorer' } },
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
