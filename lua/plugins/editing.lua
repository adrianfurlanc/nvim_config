return {
	{
		'raimondi/delimitmate', -- Autoclose brackets, parentheses, quotes, etc.
		init = function()
			-- Closetag / DelimitMate
			-- vim.g.closetag_filenames = '*.html,*.xhtml,*.phtml'
			-- vim.g.closetag_xhtml_filenames = '*.xhtml,*.jsx'
			vim.g.delimitMate_matchpairs = '(:),[:],{:}'
		end,
	},
	{
		'justinmk/vim-sneak', -- Goto 2x characters
		init = function()
			vim.g['sneak#s_next'] = 1
		end,
	},
	{ 'rhysd/clever-f.vim' },              -- Extends f, F, t, T to repeat with f/F instead of semicolon, with highlighting
	{ 'machakann/vim-highlightedyank' },   -- Preview selected yanked text
	{ 'tommcdo/vim-lion' },                -- Aligns text to a character with the gl and gL operators
	{ 'tpope/vim-commentary' },            -- Toggle comments in vim
	{ 'tpope/vim-eunuch' },                -- Helpers for unix
	{ 'tpope/vim-repeat' },                -- Allow plugins to repeat
	{ 'tpope/vim-surround' },              -- Add/Change surround characters
	{ 'tpope/vim-unimpaired' },            -- Provides several pair
	{ 'wellle/targets.vim' },              -- Better vim text objects
	{ 'nelstrom/vim-visual-star-search' }, -- Use the star command with the visual mode selection and not the current word
	{
		'artnez/vim-wipeout', -- Close all buffers & tabs
		cmd = 'Wipeout',
	},
	{ 'qpkorr/vim-bufkill' },              -- Unload/delete/wipe buffers without closing the window or split
	{ 'Valloric/ListToggle' },             -- Toggles the quickfix list and location-list open/closed with simple keybindings
	{ 'junegunn/vim-peekaboo' },           -- Extends " / @ / CTRL-R to peek into registers and marks before using them
	{ 'kshenoy/vim-signature' },           -- View marks in gutter
	{
		'mbbill/undotree', -- Visualize the undo history as a tree
		cmd = { 'UndotreeToggle', 'UndotreeShow' },
	},
}
