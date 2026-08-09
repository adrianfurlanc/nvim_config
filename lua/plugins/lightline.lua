-- Lightline and the plugins feeding its components. The component functions
-- live in autoload/statusline.vim so they are only loaded on first redraw.
--
-- 'enable.tabline' is off because the tabline is rendered by lua/tabline.lua
-- instead (see the bottom of lua/config/options.lua); lightline defaults it
-- to 1 and would otherwise clobber 'tabline' on init.
return {
	{
		'itchyny/lightline.vim', -- Light and configurable statusline/tabline plugin
		dependencies = {
			'cocopon/lightline-hybrid.vim',  -- Hybrid theme for lightline
			'shinchu/lightline-gruvbox.vim', -- Gruvbox theme for light-line
			'josa42/vim-lightline-coc',      -- coc.nvim diagnostic indicators (errors/warnings) for lightline statusbar
		},
		config = function()
			vim.g.lightline = {
				colorscheme = 'gruvbox',
				enable = { statusline = 1, tabline = 0 },
				active = {
					left = {
						{ 'mode', 'paste' },
						{ 'fugitive', 'realpath', 'readonly', 'modified' },
						{ 'bufferline' },
					},
					right = {
						{ 'lineinfo' },
						{ 'coc_errors', 'coc_warnings', 'coc_info', 'coc_hints', 'coc_status' },
						{ 'percent' },
						{ 'fileformat', 'tagbar', 'filetype' },
					},
				},
				component = {
					tagbar = '%{tagbar#currenttag("%s", "", "f")}',
					realpath = '%f',
					bufferline = '%{bufferline#refresh_status()}%{g:bufferline_status_info.before . g:bufferline_status_info.current . g:bufferline_status_info.after}',
				},
				component_function = {
					fugitive = 'statusline#fugitive',
					readonly = 'statusline#readonly',
					filetype = 'statusline#filetype',
					modified = 'statusline#modified',
					fileformat = 'statusline#fileformat',
				},
				mode_map = {
					['n'] = ' N ',
					['i'] = ' I ',
					['R'] = ' R ',
					['v'] = ' V ',
					['V'] = 'V-L',
					['c'] = ' C ',
					['\22'] = 'V-B', -- CTRL-V
					['s'] = ' S ',
					['S'] = 'S-L',
					['\19'] = 'S-B', -- CTRL-S
				},
				-- Powerline glyphs U+E0B4-U+E0B7 (rounded separators), written as
				-- byte escapes so no editor/tooling can mangle them
				separator = { left = '\238\130\180', right = '\238\130\182' },
				subseparator = { left = '\238\130\181', right = '\238\130\183' },
			}

			vim.g['lightline#coc#indicator_warnings'] = 'W'
			vim.g['lightline#coc#indicator_errors'] = 'E'
			-- Info and hints alongside them: lua_ls reports unused-local as a Hint
			-- and plenty of servers use Information, so without these the status
			-- line stays empty for diagnostics the sign column is already showing.
			vim.g['lightline#coc#indicator_info'] = 'I'
			vim.g['lightline#coc#indicator_hints'] = 'H'

			-- Fills in the coc_* entries of component_expand/component_type used by
			-- the 'right' section above (the refresh autocmds live in the plugin
			-- itself). Must run after the indicator variables are set — they are
			-- read when the autoload file first loads.
			vim.fn['lightline#coc#register']()

			-- Brighten the gray statusline text of the gruvbox lightline theme
			-- (see statusline#brighten for the full story).
			vim.api.nvim_create_autocmd('VimEnter', {
				group = vim.api.nvim_create_augroup('LightlineWhiteText', {}),
				callback = function() vim.fn['statusline#brighten']() end,
			})

			-- Keep the per-buffer git state used by the fugitive component fresh
			local git_status = vim.api.nvim_create_augroup('LightlineGitStatus', {})
			vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufWritePost', 'FocusGained' }, {
				group = git_status,
				callback = function() vim.fn['statusline#update_git_status']() end,
			})
			vim.api.nvim_create_autocmd('User', {
				group = git_status,
				pattern = 'FugitiveChanged',
				callback = function() vim.fn['statusline#update_git_status']() end,
			})
		end,
	},
	{
		'bling/vim-bufferline', -- View open buffers in cmd bar
		init = function()
			-- Don't echo the buffer list to the command bar: its CursorHold echo
			-- (firing after 'updatetime', which coc lowers to 300ms) overwrites
			-- any command-line output, e.g. :messages.
			vim.g.bufferline_echo = 0
		end,
	},
}
