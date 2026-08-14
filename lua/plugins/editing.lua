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
		-- Replaces vim-sneak (s + 2 chars) and clever-f (f/F/t/T repeat with
		-- f/F). Both behaviours survive: 'char' mode re-maps f/F/t/T so that
		-- pressing the same key again advances to the next match, and 's'
		-- still takes two characters — but every match now gets a label, so
		-- you press the label instead of hammering 's' to cycle.
		'folke/flash.nvim',
		event = 'VeryLazy',
		opts = {
			-- The default style is "overlay", which paints the label over the
			-- character following the match: `const` renders as `conbt`, so
			-- the labels read as typos in the code. "inline" inserts them
			-- instead, hiding nothing -- the line shifts right while the
			-- labels are up. Colors for FlashLabel and friends are in
			-- lua/config/colors.lua.
			label = { style = 'inline' },
			modes = {
				-- Labelled '/' search is left off: wincent/loupe (see
				-- lua/plugins/search.lua) already owns search highlighting
				-- and 'shortmess', and flash's search mode also drives
				-- hlsearch. Flip this to true to try them together; <C-s>
				-- toggles flash on mid-search either way.
				search = { enabled = false },
			},
		},
		keys = {
			{ 's', mode = { 'n', 'x', 'o' }, function() require('flash').jump() end, desc = 'Flash' },
			-- Deliberately not mapped in visual mode: vim-surround owns
			-- visual 'S' (surround the selection).
			{ 'S', mode = { 'n', 'o' }, function() require('flash').treesitter() end, desc = 'Flash treesitter' },
			-- Operator-pending only, so normal-mode 'r' (replace char) is
			-- untouched. `yr` + label yanks a text object elsewhere on
			-- screen without moving the cursor.
			{ 'r', mode = 'o', function() require('flash').remote() end, desc = 'Remote flash' },
			{ 'R', mode = { 'o', 'x' }, function() require('flash').treesitter_search() end, desc = 'Treesitter search' },
			{ '<C-s>', mode = 'c', function() require('flash').toggle() end, desc = 'Toggle flash search' },
		},
	},
	{ 'machakann/vim-highlightedyank', event = 'VeryLazy' },   -- Preview selected yanked text
	{ 'tommcdo/vim-lion', event = 'VeryLazy' },                -- Aligns text to a character with the gl and gL operators
	-- Commenting (gc/gcc) is built into Neovim 0.10+, so vim-commentary is
	-- gone. ts-comments extends the native operator with treesitter-aware
	-- comment strings, so markup inside .astro/JSX files gets <!-- --> or
	-- {/* */} while the script parts keep //.
	{ 'folke/ts-comments.nvim', opts = {}, event = 'VeryLazy' },
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
