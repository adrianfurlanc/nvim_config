return {
	'coder/claudecode.nvim', -- Claude Code integration for Neovim
	-- VeryLazy keeps its require chain (which pulls in vim.lsp, ~5ms) off the
	-- startup path; the websocket server just starts a moment after the UI.
	event = 'VeryLazy',
	config = function()
		require('claudecode').setup({
			log_level = 'warn', -- INFO messages echo to the shell on exit
			terminal = {
				provider = 'none', -- we will use tmux splits instead of Neovim terminal UI
			},
		})
	end,
}
