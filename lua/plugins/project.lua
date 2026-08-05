-- project.nvim: sets the CWD to the root of whatever file you enter, and
-- remembers the roots it has seen. Entry points:
--   :ProjectRoot  -- re-run detection for the current buffer
--   :AddProject   -- add the current file's directory to the history by hand
--   require('project_nvim').get_recent_projects()
--
-- Detection is pattern-only. Upstream also offers "lsp", which asks the
-- native LSP client for its root_dir, but this config uses coc.nvim, so
-- there is never a native client to ask -- and the lsp path goes through
-- vim.lsp.buf_get_clients()/vim.lsp.start_client(), both deprecated in
-- nvim 0.12 (still present, but on the way out).
--
-- Note the overlap with NERDTreeChDirMode = 2 (lua/plugins/nerdtree.lua):
-- making a directory the tree root still chdirs there, but entering a file
-- buffer afterwards puts the CWD back at that file's project root.

-- The recent-project picker behind <leader>fp. project.nvim ships a
-- telescope extension, which is no use here, so the history is rendered
-- through fzf-lua instead: <cr> switches to the project and opens its file
-- picker, <c-g> just switches.
local function recent_projects()
	local fzf = require('fzf-lua')
	local projects = require('project_nvim').get_recent_projects()

	-- get_recent_projects() returns oldest first; show the other way round
	local entries = {}
	for i = #projects, 1, -1 do
		entries[#entries + 1] = projects[i]
	end

	if #entries == 0 then
		vim.notify('No projects visited yet', vim.log.levels.INFO)
		return
	end

	-- set_pwd() rather than a plain :cd, so the pick goes through the same
	-- path as automatic detection (records the project, honours scope_chdir)
	local function switch_to(selected)
		if not selected or not selected[1] then
			return false
		end
		return require('project_nvim.project').set_pwd(selected[1], 'fzf-lua')
	end

	fzf.fzf_exec(entries, {
		prompt = 'Projects> ',
		actions = {
			['default'] = function(selected)
				if switch_to(selected) then
					fzf.files({ cwd = selected[1] })
				end
			end,
			['ctrl-g'] = switch_to,
		},
	})
end

return {
	'ahmedkhalf/project.nvim',
	event = 'VeryLazy',
	keys = {
		{ '<leader>fp', recent_projects, desc = 'Find projects' },
	},
	opts = {
		detection_methods = { 'pattern' },
		-- Upstream's defaults, spelled out so they are easy to extend
		patterns = { '.git', '_darcs', '.hg', '.bzr', '.svn', 'Makefile', 'package.json' },
	},
	config = function(_, opts)
		require('project_nvim').setup(opts)

		-- Detection runs on VimEnter and BufEnter, both of which have
		-- already fired by the time VeryLazy loads the plugin, so the
		-- first file of the session needs one manual pass.
		require('project_nvim.project').on_buf_enter()
	end,
}
