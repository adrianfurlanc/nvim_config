-- Editing helpers. Almost everything here is mappings, text objects or
-- commands with nothing to draw at startup, so it loads on VeryLazy (right
-- after the first screen paint) instead of during startup. Plugins whose
-- work starts in insert mode wait for InsertEnter instead.
return {
	{
		'raimondi/delimitmate', -- Autoclose brackets, parentheses, quotes, etc.
		event = 'InsertEnter',
		init = function()
			-- Closetag / DelimitMate
			-- vim.g.closetag_filenames = '*.html,*.xhtml,*.phtml'
			-- vim.g.closetag_xhtml_filenames = '*.xhtml,*.jsx'
			vim.g.delimitMate_matchpairs = '(:),[:],{:}'
		end,
	},
	{
		'justinmk/vim-sneak', -- Goto 2x characters
		event = 'VeryLazy',
		init = function()
			vim.g['sneak#s_next'] = 1
		end,
	},
	{ 'rhysd/clever-f.vim', event = 'VeryLazy' },              -- Extends f, F, t, T to repeat with f/F instead of semicolon, with highlighting
	{ 'machakann/vim-highlightedyank', event = 'VeryLazy' },   -- Preview selected yanked text
	{ 'tommcdo/vim-lion', event = 'VeryLazy' },                -- Aligns text to a character with the gl and gL operators
	{ 'tpope/vim-commentary', event = 'VeryLazy' },            -- Toggle comments in vim
	{ 'tpope/vim-eunuch', event = 'VeryLazy' },                -- Helpers for unix
	{ 'tpope/vim-repeat', event = 'VeryLazy' },                -- Allow plugins to repeat
	{ 'tpope/vim-surround', event = 'VeryLazy' },              -- Add/Change surround characters
	{ 'tpope/vim-unimpaired', event = 'VeryLazy' },            -- Provides several pair
	{ 'wellle/targets.vim', event = 'VeryLazy' },              -- Better vim text objects
	{ 'nelstrom/vim-visual-star-search', event = 'VeryLazy' }, -- Use the star command with the visual mode selection and not the current word
	{
		'artnez/vim-wipeout', -- Close all buffers & tabs
		cmd = 'Wipeout',
	},
	{ 'qpkorr/vim-bufkill', event = 'VeryLazy' },              -- Unload/delete/wipe buffers without closing the window or split
	{
		'Valloric/ListToggle', -- Toggles the quickfix list and location-list open/closed with simple keybindings
		event = 'VeryLazy',
		init = function()
			-- The default quickfix map is <leader>q, which keymaps.lua already
			-- uses to pre-fill :q. The plugin maps with <unique>, so the clash
			-- aborts its entire plugin file (E227). Move it to <leader>c
			-- (mnemonic: :copen); the location list keeps the default <leader>l.
			vim.g.lt_quickfix_list_toggle_map = '<leader>c'
		end,
	},
	{
		'kshenoy/vim-signature', -- View marks in gutter
		event = 'VeryLazy',
		config = function()
			-- Loaded after VimEnter/ColorScheme have already fired, so run the
			-- setup those autocmds would have done: highlight groups, then a
			-- forced refresh to place signs for the already-open buffer.
			vim.fn['signature#utils#SetupHighlightGroups']()
			vim.fn['signature#sign#Refresh'](1)
		end,
	},
	{
		'mbbill/undotree', -- Visualize the undo history as a tree
		cmd = { 'UndotreeToggle', 'UndotreeShow' },
	},
}
