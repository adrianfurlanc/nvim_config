-- ============================================================
-- init.lua — startup core only
--
-- Everything else lives in:
--   plugin/settings.lua    — options
--   plugin/mappings.lua    — key mappings
--   plugin/autocmds.lua    — general autocommands
--   plugin/color.lua       — highlight and cursor tweaks
--   plugin/<plugin>.lua    — per-plugin configuration
--   after/plugin/          — settings that override a plugin's defaults
--   lua/functions.lua      — helper functions, loaded on first require()
--   lua/pack.lua           — plugin list (minpac, loaded on demand)
--   autoload/statusline.vim— lightline components, loaded on first redraw
--                            (stays Vimscript: plugin/lightline.vim refers
--                            to them by autoload function name)
-- ============================================================

-- If FZF installed using git
vim.opt.runtimepath:append(vim.fn.expand("~/.fzf"))

vim.g.mapleader = " "

-- Plugins under pack/*/start are auto-loaded by nvim itself, so minpac and
-- the plugin registry are only loaded when actually managing packages.
vim.api.nvim_create_user_command("PackUpdate", function()
	require("pack").update()
end, {})
vim.api.nvim_create_user_command("PackClean", function()
	require("pack").clean()
end, {})

-- Colorscheme. The italics flags must be set before the scheme is sourced,
-- and 'background' before :colorscheme — setting it afterwards makes Vim
-- source the whole colorscheme a second time. Gruvbox is the default;
-- markdown buffers switch to OceanicNext (see plugin/color.vim).
vim.g.gruvbox_italic = 1
vim.g.oceanic_next_terminal_italic = 1
vim.opt.termguicolors = true
vim.opt.background = "dark"
vim.cmd.colorscheme("gruvbox")

vim.cmd.source(vim.env.VIMRUNTIME .. "/macros/matchit.vim")
