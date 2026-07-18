-- Colorschemes. priority = 1000 makes lazy load these before every other
-- start plugin, so the scheme is in place when the rest of the UI loads.
-- The italics flags must be set before the scheme is sourced (init runs
-- before the plugin is loaded), and 'background' before :colorscheme —
-- setting it afterwards makes Vim source the whole colorscheme a second
-- time. Gruvbox is the default; markdown buffers switch to OceanicNext
-- (see lua/config/colors.lua).
return {
	{
		'rafi/awesome-vim-colorschemes', -- Lots of Colorschemes
		lazy = false,
		priority = 1000,
		init = function()
			vim.g.gruvbox_italic = 1
		end,
		config = function()
			vim.opt.background = 'dark'
			vim.cmd.colorscheme('gruvbox')
		end,
	},
	{
		'mhartington/oceanic-next', -- Neovim color scheme inspired by Oceanic Next for Sublime — cool blue/teal palette, supports true color, italics, and terminal transparency
		lazy = false,
		priority = 1000,
		init = function()
			vim.g.oceanic_next_terminal_italic = 1
		end,
	},
}
