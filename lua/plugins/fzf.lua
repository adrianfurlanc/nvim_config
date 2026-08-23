-- fzf-lua: Lua pickers (files, grep, buffers, ...) driving the fzf binary
-- from the Homebrew install on PATH. Replaced fzf.vim, which needed the
-- ~/.fzf git install kept on the runtimepath in lua/config/lazy.lua.

-- The <Leader>fo picker: this project's recent files, most recently closed
-- first.
--
-- Not FzfLua oldfiles, which is neither. That reads v:oldfiles, so it spans
-- every project at once -- 99 entries here, 5 of them in adrianfurlan.com --
-- and ranks them by what the shada file recorded at the last exit, which never
-- changes while nvim is running. lua/mru.lua supplies this session's real
-- close order, and the cwd filter does the scoping: project.nvim has already
-- set the cwd to the project root (lua/plugins/project.lua).
--
-- :FzfLua oldfiles still gives the unfiltered global list when that is wanted.
local function recent_files()
	local cwd = vim.fn.getcwd()
	local paths = require('mru').recent(cwd)

	if #paths == 0 then
		return vim.notify('No recent files under ' .. vim.fn.fnamemodify(cwd, ':~'),
			vim.log.levels.INFO)
	end

	-- Normalized against the 'oldfiles' defaults, the same trick the coc
	-- location pickers use (lua/plugins/coc.lua): it inherits the builtin
	-- previewer, the file icons and the standard file actions, including the
	-- ctrl-q/ctrl-l quickfix bindings merged in below. Its '--tiebreak=index'
	-- is what stops fzf resorting the list into its own order on an empty
	-- query, which would throw the ordering away at the last step.
	local opts = require('fzf-lua.config').normalize_opts({
		cwd = cwd,
		prompt = 'Recent> ',
		winopts = { title = ' Recent Files ' },
	}, 'oldfiles')

	local make_entry = require('fzf-lua.make_entry')
	require('fzf-lua').fzf_exec(vim.tbl_map(function(path)
		return make_entry.file(path, opts)
	end, paths), opts)
end

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
		{ '<leader>fo', recent_files, desc = 'Recent files (this project)' },
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
			-- <CR> opens the help page in a full-height vertical split beside the
			-- code, instead of the wide, short horizontal one :help gives.
			--
			-- Not actions.help_vert on its own -- that is what the shipped ctrl-v
			-- binding already is, and it only works while no help window is open.
			-- :vert help REUSES an existing help window and ignores the modifier:
			-- measured, with help already open the layout is
			-- file(120x16) | HELP(120x20) both before and after, so a second
			-- lookup lands back in the horizontal window the first one made.
			--
			-- wincmd L is what actually moves it, the same trick the fugitive
			-- status window uses in lua/plugins/git.lua: it turns the reused
			-- horizontal window into a rightmost full-height vertical one
			-- (120x20 -> 60x37), and does nothing on the fresh case, where
			-- 'splitright' has already put :vert help exactly there.
			--
			-- The buftype guard stops a failed lookup from moving whatever window
			-- we happen to be standing in instead.
			--
			-- A per-picker actions table MERGES into that picker's defaults,
			-- unlike globals.actions.files above, which replaces wholesale -- so
			-- ctrl-s, ctrl-v and ctrl-t survive untouched (verified).
			helptags = {
				actions = {
					['enter'] = function(selected, opts)
						if not selected[1] then
							return
						end
						actions.help_vert(selected, opts)
						if vim.bo.buftype == 'help' then
							vim.cmd.wincmd('L')
						end
					end,
				},
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
