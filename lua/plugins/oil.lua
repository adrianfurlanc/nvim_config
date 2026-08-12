-- oil.nvim, in place of NERDTree. The workflow it replaces is unchanged: '-'
-- opens the current file's directory with the cursor on the file you came
-- from, '-' again goes up, <CR> opens. What changes is everything underneath.
-- A directory is a normal, modifiable buffer, so renaming, moving, creating
-- and deleting are ordinary edits -- staged as you type, applied on :w, undone
-- with u, and several at once. NERDTree's equivalent was the 'm' menu, one
-- entry at a time and immediate.
--
-- Not lazy-loaded, unlike NERDTree. NERDTree cost ~40ms at startup (probing
-- the clipboard provider and $PATH) and was worth deferring; oil costs a
-- fraction of that, and loading it up front is what lets it claim netrw's
-- FileExplorer autocmds before the first buffer is read. Deferring it is what
-- forced functions.load_nerdtree() to exist: NERDTree only dropped those
-- autocmds at VimEnter, so a directory buffer entered before then had to be
-- handed to the hijack by hand.
return {
	{
		'stevearc/oil.nvim',
		dependencies = { 'nvim-tree/nvim-web-devicons' },
		lazy = false,
		keys = {
			-- Behave like vim-vinegar. open() with no argument opens the
			-- parent of the current buffer and places the cursor on the entry
			-- you came from, which is the job autocmds.attempt_select_last_file()
			-- did for NERDTree by searching the buffer for the filename.
			{ '-', function() require('oil').open() end, desc = 'Open parent directory' },
		},
		opts = {
			-- Take netrw's place, as NERDTreeHijackNetrw did, so that `nvim .`
			-- and `:edit <dir>` land in oil.
			default_file_explorer = true,
			-- No confirmation prompt for a lone rename, create or move; a
			-- delete, or any batch touching more than one file, still asks.
			skip_confirm_for_simple_edits = true,
			-- A delete stays recoverable from Finder. oil does not shell out
			-- to a trash utility on macOS: lua/oil/adapters/trash/mac.lua
			-- moves the entry into $HOME/.Trash itself, appending a timestamp
			-- to the name if something is already there under it. NERDTree's
			-- 'm' menu deleted outright.
			delete_to_trash = true,
			view_options = {
				-- Matches NERDTree here, whose NERDTreeShowHidden default of 0
				-- this config never changed. 'g.' toggles them, as 'I' did in
				-- the tree.
				show_hidden = false,
			},
		},
	},
}
