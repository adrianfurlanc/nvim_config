-- fzf-lua: Lua pickers (files, grep, buffers, ...) driving the fzf binary
-- from the Homebrew install on PATH. Replaced fzf.vim, which needed the
-- ~/.fzf git install kept on the runtimepath in lua/config/lazy.lua.
return {
	'ibhagwan/fzf-lua',
	cmd = 'FzfLua',
	dependencies = { "nvim-tree/nvim-web-devicons" },
	keys = {
		{ '<leader>ff', '<cmd>FzfLua files<cr>', desc = 'Find files' },
		{ '<leader>fg', '<cmd>FzfLua live_grep<cr>', desc = 'Live grep (rg)' },
		{ '<leader>fh', '<cmd>FzfLua helptags<cr>', desc = 'Search help' },
		{ '<leader>f/', '<cmd>FzfLua lgrep_curbuf<cr>', desc = 'Live grep current buffer' },
		{ '<leader>fw', '<cmd>FzfLua grep_cword<cr>', desc = 'Grep word under cursor' },
		{ '<leader>fw', '<cmd>FzfLua grep_visual<cr>', mode = 'x', desc = 'Grep visual selection' },
		{ '<leader>fo', '<cmd>FzfLua oldfiles<cr>', desc = 'Recent files' },
		{ '<leader>fb', '<cmd>FzfLua buffers<cr>', desc = 'Find buffers' },
		{ '<leader>fk', '<cmd>FzfLua keymaps<cr>', desc = 'Keymaps' },
		{ '<leader>fr', '<cmd>FzfLua resume<cr>', desc = 'Resume last picker' },
		{ '<leader>fB', '<cmd>FzfLua builtin<cr>', desc = 'Builtin pickers' },
		{ '<leader><leader>', '<cmd>FzfLua buffers<cr>', desc = 'Find buffers' },
		{ '<leader>fm', '<cmd>FzfLua marks<cr>', desc = 'Marks' },
		{ '<leader>fR', '<cmd>FzfLua registers<cr>', desc = 'Registers' },
		{ '<leader>fs', '<cmd>FzfLua git_status<cr>', desc = 'Git status' },
		-- <leader>fp (recent projects) is in lua/plugins/project.lua: it
		-- reads project.nvim's history, so it belongs with that spec.
	},
	opts = {},
}
