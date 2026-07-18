return {
	{
		'mhinz/vim-grepper', -- Async grep across multiple tools (rg, ag, git grep, etc.) with quickfix integration
		init = function()
			vim.g.grepper = {
				tools = { 'rg', 'grep', 'git' },
				rg = { grepprg = 'rg -H --no-heading --vimgrep' },
			}
		end,
		config = function()
			vim.keymap.set('n', '<Leader>g', ':Grepper -tool rg<CR>')

			-- Alias :grep to :GrepperGrep
			require('functions').setup_command_alias('grep', 'GrepperGrep')
		end,
	},
	{ 'brooth/far.vim' }, -- Find and replace across multiple files with a preview window
	{
		'wincent/loupe', -- Enhanced in-file search with smarter highlighting and sane defaults
		init = function()
			-- Prevents <Leader>n mapping to toggle hlsearch
			vim.g.LoupeClearHighlightMap = 0

			-- forces Vim to respect your 'smartcase' and 'ignorecase
			vim.g.LoupeCaseSettingsAlways = 0
		end,
		config = function()
			-- Remove the unwanted 's' loupe adds to 'shortmess'.
			vim.opt.shortmess:remove('s')
		end,
	},
	{ 'wincent/scalpel' }, -- Rename the word under the cursor across the file (<Leader>s, see lua/config/keymaps.lua)
}
