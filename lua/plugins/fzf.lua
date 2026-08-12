-- fzf-lua: Lua pickers (files, grep, buffers, ...) driving the fzf binary
-- from the Homebrew install on PATH. Replaced fzf.vim, which needed the
-- ~/.fzf git install kept on the runtimepath in lua/config/lazy.lua.
return {
	'ibhagwan/fzf-lua',
	cmd = { 'FzfLua', 'FzfDirectories' },
	dependencies = { "nvim-tree/nvim-web-devicons" },
	keys = {
		{ '<leader>ff', '<cmd>FzfLua files<cr>', desc = 'Find files' },
		{ '<leader>fd', '<cmd>FzfDirectories<cr>', desc = 'Find directories (oil)' },
		{ '<leader>fg', '<cmd>FzfLua live_grep<cr>', desc = 'Live grep (rg)' },
		{ '<leader>fh', '<cmd>FzfLua helptags<cr>', desc = 'Search help' },
		{ '<leader>f/', '<cmd>FzfLua lgrep_curbuf<cr>', desc = 'Live grep current buffer' },
		{ '<leader>fw', '<cmd>FzfLua grep_cword<cr>', desc = 'Grep word under cursor' },
		{ '<leader>fw', '<cmd>FzfLua grep_visual<cr>', mode = 'x', desc = 'Grep visual selection' },
		{ '<leader>fo', '<cmd>FzfLua oldfiles<cr>', desc = 'Recent files' },
		{ '<leader>fb', '<cmd>FzfLua buffers<cr>', desc = 'Find buffers' },
		{ '<leader>fk', '<cmd>FzfLua keymaps<cr>', desc = 'Keymaps' },
		{ '<leader>fr', '<cmd>FzfLua resume<cr>', desc = 'Resume last picker' },
		{ '<leader>fB', '<cmd>FzfLua builtin<cr>', desc = 'Builtin pickers' },
		{ '<leader><leader>', '<cmd>FzfLua buffers<cr>', desc = 'Find buffers' },
		{ '<leader>fm', '<cmd>FzfLua marks<cr>', desc = 'Marks' },
		{ '<leader>fR', '<cmd>FzfLua registers<cr>', desc = 'Registers' },
		{ '<leader>fs', '<cmd>FzfLua git_status<cr>', desc = 'Git status' },
		-- <leader>fp (recent projects) is in lua/plugins/project.lua: it
		-- reads project.nvim's history, so it belongs with that spec.
	},
	-- A function so requiring fzf-lua.actions happens when the plugin loads
	-- rather than when this spec is read, which would defeat the lazy loading
	-- set up by 'cmd' and 'keys' above.
	opts = function()
		local actions = require('fzf-lua.actions')
		local defaults = require('fzf-lua.defaults').defaults
		return {
			-- fzf-lua sends selections to the quickfix/location list on alt-q and
			-- alt-Q, but macOS composes Option+key into a character (Option+q is
			-- œ) unless the terminal is told to send Esc+ instead, so those never
			-- reach fzf. Duplicate them onto ctrl- keys, which arrive intact.
			--
			-- Merged over the defaults on purpose: setting actions.files replaces
			-- that table wholesale rather than merging into it, so assigning just
			-- the two new keys would drop <CR> and the split bindings with it.
			actions = {
				files = vim.tbl_extend('force', defaults.actions.files, {
					['ctrl-q'] = actions.file_sel_to_qf,
					['ctrl-l'] = actions.file_sel_to_ll,
				}),
			},
		}
	end,
	-- setup() plus the one picker fzf-lua has no builtin for: directories.
	-- The <leader>f* family finds files, buffers and text, but nothing jumps
	-- to a directory by name; this lists them with fd and hands the pick to
	-- oil, landing in the same directory buffer '-' would.
	config = function(_, opts)
		require('fzf-lua').setup(opts)
		vim.api.nvim_create_user_command('FzfDirectories', function()
			-- The listing comes from fd; without it fzf_exec would open an
			-- empty picker with no indication why.
			if vim.fn.executable('fd') ~= 1 then
				return vim.notify('fd is not installed; :FzfDirectories needs it', vim.log.levels.WARN)
			end
			local cwd = vim.fn.getcwd()
			require('fzf-lua').fzf_exec('fd --type d', {
				prompt = require('fzf-lua.path').shorten(cwd) .. '> ',
				cwd = cwd,
				actions = {
					['default'] = function(selected)
						if selected and selected[1] then
							require('oil').open(cwd .. '/' .. selected[1])
						end
					end,
				},
			})
		end, { desc = 'Fuzzy-find directories, open the pick in oil' })
	end,
}
