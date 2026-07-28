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
}
