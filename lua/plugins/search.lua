return {
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
	{ 'wincent/scalpel', event = 'VeryLazy' }, -- Rename the word under the cursor across the file (<Leader>s, see lua/config/keymaps.lua)
}
