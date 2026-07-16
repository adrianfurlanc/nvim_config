-- claudecode.nvim
require("claudecode").setup({
	log_level = "warn", -- INFO messages echo to the shell on exit
	terminal = {
		provider = "none", -- we will use tmux splits instead of Neovim terminal UI
	},
})
