return {
	{
		'sheerun/vim-polyglot', -- A collection of language packs for VIM
		init = function()
			-- Allow JSX syntax in plain .js files (vim-jsx / polyglot)
			vim.g.jsx_ext_required = 0
		end,
	},
	{ 'pangloss/vim-javascript' },  -- Vastly improved JavaScript indentation and syntax support
	{ 'posva/vim-vue' },            -- Syntax highlighting for Vue.js single-file components (.vue files)
	{ 'wuelnerdotexe/vim-astro' },  -- Astro filetype detection, syntax highlighting and indentation (.astro files)
	{ 'mattn/emmet-vim' },          -- Emmet for web development
	{ 'sgur/vim-editorconfig' },    -- Reads .editorconfig files and applies indent/style settings per project
}
