return {
	'coder/claudecode.nvim', -- Claude Code integration for Neovim
	config = function()
		require('claudecode').setup({
			log_level = 'warn', -- INFO messages echo to the shell on exit
			terminal = {
				provider = 'none', -- we will use tmux splits instead of Neovim terminal UI
			},
		})
	end,
}
