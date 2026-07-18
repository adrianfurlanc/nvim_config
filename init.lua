-- ============================================================
-- init.lua — startup core only
--
-- Everything else lives in:
--   lua/config/options.lua  — options
--   lua/config/keymaps.lua  — key mappings
--   lua/config/autocmds.lua — general autocommands
--   lua/config/colors.lua   — highlight and cursor tweaks
--   lua/config/lazy.lua     — lazy.nvim bootstrap and setup
--   lua/plugins/*.lua       — plugin specs, grouped by area, with each
--                             plugin's configuration in its spec
--   lua/functions.lua       — helper functions, loaded on first require()
--   autoload/statusline.vim — lightline components, loaded on first redraw
--                             (stays Vimscript: the lightline config refers
--                             to them by autoload function name)
-- ============================================================

vim.g.mapleader = " "

-- Options, mappings and autocommands load before the plugins so everything
-- keeps the pre-lazy.nvim source order: a plugin that defines the same
-- mapping (e.g. vim-tmux-navigator's <C-h/j/k/l>) still wins over ours.
require("config.options")
require("config.keymaps")
require("config.autocmds")

-- Bootstraps lazy.nvim, loads every spec under lua/plugins/, and applies
-- the colorscheme (see lua/plugins/colorscheme.lua).
require("config.lazy")

-- Highlight tweaks that must run after the colorscheme is applied.
require("config.colors")

vim.cmd.source(vim.env.VIMRUNTIME .. "/macros/matchit.vim")
