return {
	{ 'pangloss/vim-javascript' },  -- Vastly improved JavaScript indentation and syntax support
	{ 'HerringtonDarkholme/yats.vim' }, -- TypeScript and TSX syntax highlighting and indentation
	{ 'maxmellon/vim-jsx-pretty' }, -- JSX/React syntax highlighting, incl. JSX in plain .js files
	{ 'posva/vim-vue' },            -- Syntax highlighting for Vue.js single-file components (.vue files)
	{ 'evanleck/vim-svelte' },      -- Svelte component syntax and indentation (.svelte files)
	{ 'wuelnerdotexe/vim-astro' },  -- Astro filetype detection, syntax highlighting and indentation (.astro files)
	{ 'jxnblk/vim-mdx-js' },        -- MDX filetype detection and highlighting (markdown + JSX, .mdx files)
	{ 'mattn/emmet-vim', event = 'InsertEnter' }, -- Emmet for web development; all its work starts in insert mode

	-- sgur/vim-editorconfig was dropped: nvim 0.9+ ships builtin .editorconfig
	-- support (enabled by default; opt out with vim.g.editorconfig = false)

	{
		-- Set 'shiftwidth', 'expandtab', 'tabstop' and 'softtabstop' per buffer
		-- from the file being edited, so a 2-space project doesn't get the
		-- 4-space tabs from lua/config/options.lua forced on it.
		--
		-- Order of authority, highest first: a modeline, then .editorconfig,
		-- then a heuristic vote over the buffer's own lines, then sibling files
		-- of the same type in the directory (and upwards), then the global
		-- defaults. It only guesses when nothing has declared an answer, so it
		-- doesn't fight the builtin .editorconfig support noted above — both
		-- read the same file and land on the same values.
		--
		-- Loading on BufReadPre/BufNewFile rather than at startup: sleuth acts
		-- from BufNewFile/BufReadPost, which still fire after lazy.nvim has
		-- pulled it in on BufReadPre, so the first file opened is covered.
		'tpope/vim-sleuth',
		event = { 'BufReadPre', 'BufNewFile' },
		init = function()
			-- No heuristics for prose. List indentation in markdown is too
			-- irregular to vote on — it read CLAUDE.md and INSTALL.md as
			-- 3-space — and a wrong 'shiftwidth' there also feeds the
			-- 'breakindentopt' built in ftplugin/markdown.lua. A modeline or
			-- .editorconfig still wins; only the guessing is off.
			--
			-- This covers .mdx as well: vim-mdx-js above sets filetype to
			-- "markdown.mdx" and sleuth keys off the part before the dot.
			vim.g.sleuth_markdown_heuristics = 0
		end,
	},
}
