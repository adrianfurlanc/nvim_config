-- fzf-lua: Lua pickers (files, grep, buffers, ...) driving the fzf binary
-- from the Homebrew install on PATH. Replaced fzf.vim, which needed the
-- ~/.fzf git install kept on the runtimepath in lua/config/lazy.lua.
return {
	'ibhagwan/fzf-lua',
	cmd = 'FzfLua',
	dependencies = { "nvim-tree/nvim-web-devicons" },
	keys = {
		{ '<C-p>', '<cmd>FzfLua files<cr>', desc = 'Find files' },
		{ '<leader>fb', '<cmd>FzfLua buffers<cr>', desc = 'Find buffers' },
		{ '<leader>fg', '<cmd>FzfLua live_grep<cr>', desc = 'Live grep (rg)' },
		{ '<leader>fh', '<cmd>FzfLua helptags<cr>', desc = 'Search help' },
	},
	opts = {},
}
