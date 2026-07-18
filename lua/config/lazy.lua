-- lazy.nvim bootstrap and setup (https://lazy.folke.io/installation).
-- Plugins are installed under stdpath('data')/lazy and pinned by
-- lazy-lock.json next to init.lua; manage them with :Lazy.

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
	local out = vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
			{ out, 'WarningMsg' },
			{ '\nPress any key to exit...' },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
	spec = {
		{ import = 'plugins' },
	},
	-- Colorscheme used while plugins are still being installed
	install = { colorscheme = { 'gruvbox' } },
	-- No background polling for updates; check by hand with :Lazy check
	checker = { enabled = false },
	performance = {
		rtp = {
			-- lazy.nvim resets 'runtimepath' on startup; keep the base fzf
			-- plugin from the git install (provides the :FZF command that
			-- fzf.vim builds on)
			paths = { vim.fn.expand('~/.fzf') },
		},
	},
})
