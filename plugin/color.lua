-- ============================================================
-- Highlight and cursor tweaks
-- (the startup colorscheme is set in init.lua, before this runs;
-- the per-filetype switch lives at the bottom of this file)
-- ============================================================

-- NOTE: highlights below go through vim.cmd on purpose — :highlight merges
-- attributes into the existing group, while nvim_set_hl() would replace the
-- whole group (wiping e.g. Normal's guifg).

-- Darker background for the active split, lighter for inactive ones
-- (Normal = current window, NormalNC = non-current windows).
-- Re-applied on ColorScheme so switching themes doesn't wipe it.
-- InactiveText is the overlay blur_window() (lua/autocmds.lua) paints across
-- inactive windows: gray text, guibg=NONE so the window's own background
-- shows through.
local function dim_inactive_windows()
	if (vim.g.colors_name or '') == 'OceanicNext' then
		-- OceanicNext palette: active darker than base00 (#1b2b34),
		-- inactive base00 itself; gray is base03.
		vim.cmd([[
			highlight Normal   guibg=#16232b
			highlight NormalNC guibg=#1b2b34
			highlight InactiveText gui=NONE cterm=NONE guifg=#65737e guibg=NONE ctermfg=243 ctermbg=NONE
		]])
	else
		vim.cmd([[
			highlight Normal   guibg=#1d2021
			highlight NormalNC guibg=#32302f
			highlight InactiveText gui=NONE cterm=NONE guifg=#928374 guibg=NONE ctermfg=245 ctermbg=NONE
		]])
	end
	-- Gruvbox gives the sign column (and its per-color sign groups) a bg1
	-- background, which shows as a differently-colored strip against the
	-- Normal/NormalNC backgrounds above. Drop those backgrounds so the
	-- gutter follows the window background instead.
	vim.cmd('highlight SignColumn guibg=NONE')
	for _, color in ipairs({ 'Red', 'Green', 'Yellow', 'Blue', 'Purple', 'Aqua', 'Orange' }) do
		vim.cmd('highlight Gruvbox' .. color .. 'Sign guibg=NONE')
	end
end

-- Syntax groups that link to Normal (gruvbox's Operator, vim's vimUserFunc,
-- ...) paint Normal's explicit guibg over NormalNC in non-current windows,
-- punching active-colored holes in the dimming. Break such links so those
-- tokens fall back to the window's own background.
local function clear_normal_links()
	for _, line in ipairs(vim.split(vim.fn.execute('silent highlight'), '\n')) do
		if line:find(' links to Normal$') then
			vim.cmd('highlight! link ' .. line:match('^%S+') .. ' NONE')
		end
	end
end

dim_inactive_windows()
clear_normal_links()
local active_bg = vim.api.nvim_create_augroup('ActiveWindowBackground', {})
vim.api.nvim_create_autocmd('ColorScheme', { group = active_bg, callback = dim_inactive_windows })
vim.api.nvim_create_autocmd({ 'ColorScheme', 'Syntax' }, { group = active_bg, callback = clear_normal_links })

-- Syntax highlighting
vim.cmd([[
	hi clear SignColumn
	hi DiffAdd ctermbg=White ctermfg=Green
	hi DiffDelete ctermbg=White ctermfg=Red
	hi DiffChange ctermbg=White ctermfg=Cyan
	hi Comment gui=italic cterm=italic
	hi ColorColumn ctermbg=237
]])

-- Search matches: the match under the cursor (CurSearch) keeps the scheme's
-- default reverse-video Search look; every other match is drawn as red
-- underlined text on the plain background. Re-applied on ColorScheme because
-- switching themes (gruvbox <-> OceanicNext) resets both groups.
local function search_colors()
	if (vim.g.colors_name or '') == 'OceanicNext' then
		vim.cmd([[
			highlight CurSearch gui=reverse cterm=reverse guifg=#fac863 guibg=#1b2b34 ctermfg=221 ctermbg=235
			highlight Search gui=underline cterm=underline guifg=#ec5f67 guibg=NONE ctermfg=203 ctermbg=NONE
		]])
	else
		vim.cmd([[
			highlight CurSearch gui=reverse cterm=reverse guifg=#fabd2f guibg=#282828 ctermfg=214 ctermbg=235
			highlight Search gui=underline cterm=underline guifg=#fb4934 guibg=NONE ctermfg=167 ctermbg=NONE
		]])
	end
end
search_colors()
vim.api.nvim_create_autocmd('ColorScheme', {
	group = vim.api.nvim_create_augroup('SearchColors', {}),
	callback = search_colors,
})

-- Bright cursor for contrast against the dark background, in every mode:
-- block in normal/visual, thin bar in insert, underline in replace and
-- operator-pending. All use the Cursor group below (nvim relays the color
-- to the terminal).
-- gui=NONE/cterm=NONE is required: gruvbox defines Cursor as `inverse`, and
-- :hi merges arguments, so without clearing that attribute the fg/bg here
-- get swapped at render time. Re-applied on ColorScheme because switching
-- themes restores the inverse version.
local function light_cursor()
	vim.cmd('hi Cursor gui=NONE cterm=NONE guifg=#282828 guibg=#ebdbb2 ctermfg=235 ctermbg=223')
end
light_cursor()
vim.api.nvim_create_autocmd('ColorScheme', {
	group = vim.api.nvim_create_augroup('CursorColors', {}),
	callback = light_cursor,
})
vim.opt.guicursor = 'n-v-c-sm:block-Cursor,i-ci-ve:ver25-Cursor,r-cr-o:hor20-Cursor'

-- ============================================================
-- Per-filetype colorscheme: OceanicNext for markdown, gruvbox
-- for everything else. A colorscheme is global, so this switches
-- on buffer entry; the g:colors_name guard keeps buffer moves
-- between same-scheme files from re-sourcing the theme (which
-- would also re-fire every ColorScheme autocmd above).
-- ============================================================
local function scheme_for_filetype()
	local want = vim.bo.filetype == 'markdown' and 'OceanicNext' or 'gruvbox'
	if (vim.g.colors_name or '') ~= want then
		vim.cmd.colorscheme(want)
	end
end

-- BufEnter covers moving into an already-loaded markdown buffer;
-- FileType covers the first load, when BufEnter fired before the
-- filetype was detected. 'nested' lets the :colorscheme fire the
-- ColorScheme autocmds above (dimming, cursor), which are otherwise
-- suppressed inside an autocmd.
vim.api.nvim_create_autocmd({ 'BufEnter', 'FileType' }, {
	group = vim.api.nvim_create_augroup('FiletypeColorscheme', {}),
	nested = true,
	callback = scheme_for_filetype,
})
