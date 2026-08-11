-- ============================================================
-- Highlight and cursor tweaks
-- (the startup colorscheme is set in lua/plugins/colorscheme.lua,
-- before this runs; the per-filetype switch lives at the bottom
-- of this file)
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
-- punching active-colored holes in the dimming. Clear such groups so those
-- tokens fall back to the window's own foreground and background.
local function clear_normal_links()
	local group
	for _, line in ipairs(vim.split(vim.fn.execute('silent highlight'), '\n')) do
		-- :highlight wraps long entries onto continuation lines that start
		-- with whitespace, so a group's name and its `links to` clause can
		-- land on separate lines. Operator does exactly that -- it carries
		-- nvim's own default guifg alongside gruvbox's link -- and it is the
		-- one group that matters here, since @operator and jsOperator both
		-- reach Normal through it. Carrying the last name seen forward
		-- attributes the continuation to the group it belongs to.
		group = line:match('^(%S+)%s+xxx') or group
		if group and line:find(' links to Normal$') then
			-- Cleared outright rather than just unlinked: `highlight! link X
			-- NONE` drops the link but restores the group's built-in default
			-- (Operator's is guifg=NvimLightGrey2, a cooler gray than
			-- gruvbox's #ebdbb2), so ==, ===, .. and && would still read as a
			-- different color from the code around them. An empty group has
			-- nothing to draw with and falls through to the window's own
			-- Normal / NormalNC -- matching foreground, and no background to
			-- punch a hole with.
			vim.api.nvim_set_hl(0, group, {})
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

-- nvim 0.10+ draws the statusline with the StatusLine group's ATTRIBUTES
-- (gruvbox defines it as `reverse`) underneath lightline's color-only
-- highlight groups, so every segment rendered fg/bg-swapped — a beige bar
-- with dark text. Strip the attribute; lightline provides the real colors.
-- Re-applied on ColorScheme because both schemes define it with reverse.
local function unreverse_statusline()
	vim.cmd([[
		highlight StatusLine   gui=NONE cterm=NONE
		highlight StatusLineNC gui=NONE cterm=NONE
	]])
end
unreverse_statusline()
vim.api.nvim_create_autocmd('ColorScheme', {
	group = vim.api.nvim_create_augroup('StatuslineAttrs', {}),
	callback = unreverse_statusline,
})

-- Diagnostic gutter signs in the same four colors the statusline counters use,
-- so an E/W/I/H segment and the sign marking the line it counts read as one
-- thing. The values are gruvbox bright red/yellow/blue/aqua and must stay in
-- step with palette.normal.{error,warning,info,hint} in autoload/statusline.vim;
-- they don't follow the per-filetype colorscheme switch because the lightline
-- theme they match is pinned to gruvbox.
-- guibg=NONE keeps the gutter transparent, matching the SignColumn rule above,
-- and gui=NONE clears attributes inherited through coc's default links (:hi
-- merges rather than replaces).
--
-- The *VirtualText groups carry the message coc echoes past the end of the
-- line, and the *Highlight groups are the squiggle under the offending code
-- itself. All three surfaces share the four colors so severity reads the same
-- wherever it appears: gutter icon, message, and underline.
--
-- The squiggles set only gui/guisp, leaving guifg alone so the code keeps its
-- syntax colors and picks up just the colored undercurl. Terminals without
-- curly-underline support draw a straight underline in the same color.
--
-- CocUnusedHighlight is the exception. coc gives unused symbols their own
-- group, linked to CocFadeOut -> Conceal, and it outranks all four severity
-- groups (see :help coc-highlights-diagnostic), which is why `unusedTotal`
-- showed a gray underline rather than a hint-colored one. It keeps the faded
-- gray foreground that marks a symbol as dead, and gains the hint undercurl --
-- unused is reported as a Hint by lua_ls and tsserver alike.
local function diagnostic_colors()
	vim.cmd([[
		highlight CocErrorSign   gui=NONE cterm=NONE guifg=#fb4934 guibg=NONE ctermfg=167 ctermbg=NONE
		highlight CocWarningSign gui=NONE cterm=NONE guifg=#fabd2f guibg=NONE ctermfg=214 ctermbg=NONE
		highlight CocInfoSign    gui=NONE cterm=NONE guifg=#83a598 guibg=NONE ctermfg=109 ctermbg=NONE
		highlight CocHintSign    gui=NONE cterm=NONE guifg=#8ec07c guibg=NONE ctermfg=108 ctermbg=NONE

		highlight CocErrorVirtualText   gui=NONE cterm=NONE guifg=#fb4934 guibg=NONE ctermfg=167 ctermbg=NONE
		highlight CocWarningVirtualText gui=NONE cterm=NONE guifg=#fabd2f guibg=NONE ctermfg=214 ctermbg=NONE
		highlight CocInfoVirtualText    gui=NONE cterm=NONE guifg=#83a598 guibg=NONE ctermfg=109 ctermbg=NONE
		highlight CocHintVirtualText    gui=NONE cterm=NONE guifg=#8ec07c guibg=NONE ctermfg=108 ctermbg=NONE

		highlight CocErrorHighlight   gui=undercurl cterm=undercurl guisp=#fb4934
		highlight CocWarningHighlight gui=undercurl cterm=undercurl guisp=#fabd2f
		highlight CocInfoHighlight    gui=undercurl cterm=undercurl guisp=#83a598
		highlight CocHintHighlight    gui=undercurl cterm=undercurl guisp=#8ec07c

		highlight! CocUnusedHighlight gui=undercurl cterm=undercurl guisp=#8ec07c guifg=#928374 ctermfg=245
	]])
end
diagnostic_colors()
vim.api.nvim_create_autocmd('ColorScheme', {
	group = vim.api.nvim_create_augroup('DiagnosticColors', {}),
	callback = diagnostic_colors,
})

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

-- Quickfix window ($VIMRUNTIME/syntax/qf.vim), which the :Lint, :Eslint,
-- :Stylelint, :Typecheck and :AstroCheck commands fill (see
-- lua/functions.lua). Three of
-- its groups don't come from the colorscheme at all and look it:
--
--   - qfSeparator1/2 link to Delimiter, which neither scheme defines, so the
--     `|` bars fall back to nvim's built-in NvimLightGrey2.
--   - QuickFixLine isn't defined by either scheme either, so the entry under
--     the cursor is drawn in nvim's built-in NvimLightCyan.
--   - qfError links to Error, which gruvbox defines as bold,reverse — the
--     word "error" comes out as a filled red block on every line.
--
-- Defined outright below from each scheme's own palette: the path in blue,
-- the bars and the line/column in the muted grays, and the severity word in
-- flat colored text on the plain background — the same treatment Search gets
-- above, rather than reverse video. qfWarning/qfNote/qfInfo have no default
-- link at all (they render as plain message text); `astro check` reports
-- warnings and hints, so they get palette colors too.
--
-- guifg=NONE on QuickFixLine and gui=NONE on qfError are load-bearing:
-- :highlight merges, so without them the built-in cyan foreground and
-- gruvbox's reverse attribute survive underneath these values.
--
-- Re-applied on ColorScheme because :colorscheme runs `hi clear` first, and
-- because the two schemes need different palettes.
local function quickfix_colors()
	if (vim.g.colors_name or '') == 'OceanicNext' then
		vim.cmd([[
			highlight qfFileName   gui=NONE cterm=NONE guifg=#6699cc guibg=NONE ctermfg=68  ctermbg=NONE
			highlight qfSeparator1 gui=NONE cterm=NONE guifg=#4f5b66 guibg=NONE ctermfg=240 ctermbg=NONE
			highlight qfSeparator2 gui=NONE cterm=NONE guifg=#4f5b66 guibg=NONE ctermfg=240 ctermbg=NONE
			highlight qfLineNr     gui=NONE cterm=NONE guifg=#65737e guibg=NONE ctermfg=243 ctermbg=NONE
			highlight qfError      gui=NONE cterm=NONE guifg=#ec5f67 guibg=NONE ctermfg=203 ctermbg=NONE
			highlight qfWarning    gui=NONE cterm=NONE guifg=#fac863 guibg=NONE ctermfg=221 ctermbg=NONE
			highlight qfNote       gui=NONE cterm=NONE guifg=#5fb3b3 guibg=NONE ctermfg=73  ctermbg=NONE
			highlight qfInfo       gui=NONE cterm=NONE guifg=#99c794 guibg=NONE ctermfg=114 ctermbg=NONE
			highlight QuickFixLine gui=NONE cterm=NONE guifg=NONE    guibg=#4f5b66 ctermfg=NONE ctermbg=240
		]])
	else
		vim.cmd([[
			highlight qfFileName   gui=NONE cterm=NONE guifg=#83a598 guibg=NONE ctermfg=109 ctermbg=NONE
			highlight qfSeparator1 gui=NONE cterm=NONE guifg=#665c54 guibg=NONE ctermfg=241 ctermbg=NONE
			highlight qfSeparator2 gui=NONE cterm=NONE guifg=#665c54 guibg=NONE ctermfg=241 ctermbg=NONE
			highlight qfLineNr     gui=NONE cterm=NONE guifg=#928374 guibg=NONE ctermfg=245 ctermbg=NONE
			highlight qfError      gui=NONE cterm=NONE guifg=#fb4934 guibg=NONE ctermfg=167 ctermbg=NONE
			highlight qfWarning    gui=NONE cterm=NONE guifg=#fabd2f guibg=NONE ctermfg=214 ctermbg=NONE
			highlight qfNote       gui=NONE cterm=NONE guifg=#8ec07c guibg=NONE ctermfg=108 ctermbg=NONE
			highlight qfInfo       gui=NONE cterm=NONE guifg=#b8bb26 guibg=NONE ctermfg=142 ctermbg=NONE
			highlight QuickFixLine gui=NONE cterm=NONE guifg=NONE    guibg=#504945 ctermfg=NONE ctermbg=239
		]])
	end
end
quickfix_colors()
vim.api.nvim_create_autocmd('ColorScheme', {
	group = vim.api.nvim_create_augroup('QuickfixColors', {}),
	callback = quickfix_colors,
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
