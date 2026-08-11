return {
	{
		'Yggdroot/indentLine', -- Display thin vertical lines at each indentation level for code indented with spaces
		init = function()
			vim.g.indentLine_fileTypeExclude = { 'help' }
			vim.g.indentLine_bufNameExclude = { 'NERD_tree.*' }
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
		opts = {
			options = {
				-- No diagnostic counts up here: the gutter signs and the
				-- lightline coc_* components already report them.
				diagnostics = false,
				-- Sit the buffer tabs beside the NERDTree pane rather than
				-- running the full width across the top of it.
				offsets = { { filetype = 'nerdtree', text = 'File Explorer' } },
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
