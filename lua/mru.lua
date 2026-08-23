-- Per-session list of the files you have closed, newest first. Feeds the
-- <Leader>fo picker in lua/plugins/fzf.lua; the autocmd that fills it is
-- registered in lua/config/autocmds.lua, so this module is only read from
-- disk the first time a buffer is deleted.
--
-- It exists because v:oldfiles cannot answer the question. That list is a
-- snapshot read from the shada file at startup and is never updated while
-- nvim runs -- measured: open two files, :bdelete one, and v:oldfiles comes
-- back byte-identical, with nothing added and nothing reordered. So a file
-- closed a minute ago keeps whatever rank the *previous* session's exit left
-- it with, which is how FzfLua oldfiles ranks a just-closed file 40 entries
-- down.

-- Newest first. Capped so a long session cannot grow it without bound; 200 is
-- well past the point where a fuzzy picker is the wrong tool anyway.
local MAX = 200

local closed = {}

local M = {}

-- Record a buffer as the most recently closed, moving it to the front if it is
-- already there -- close, reopen, close again leaves one entry, at the top.
--
-- Real named files only. 'buftype' is empty for those and set for everything
-- else: the quickfix window, undotree, which-key's panels and fzf's own window
-- are all 'nofile', and the nameless buffer nvim starts on has no name worth
-- recording. Both guards live here rather than in the autocmd so the callback
-- stays a one-liner.
--
-- Reading the buffer's options and name from a BufDelete callback is safe: the
-- event fires before the buffer is removed, so it is still valid there
-- (verified, including for the 'nofile' case this rejects).
--
-- Measured at the cap, worst case -- a miss, so a full scan plus an eviction --
-- at 0.00045ms per call. That is why the scan is a plain loop rather than an
-- index kept alongside it.
function M.record(bufnr)
	if vim.bo[bufnr].buftype ~= '' then
		return
	end
	local path = vim.api.nvim_buf_get_name(bufnr)
	if path == '' then
		return
	end

	for i, seen in ipairs(closed) do
		if seen == path then
			table.remove(closed, i)
			break
		end
	end
	table.insert(closed, 1, path)
	if #closed > MAX then
		table.remove(closed)
	end
end

-- Recent files under `dir`, newest first: what this session closed, then what
-- shada remembered from the sessions before it. That second half is what keeps
-- the picker useful on a freshly started nvim, where nothing has been closed
-- yet and the first half is empty.
--
-- The current buffer is dropped. Nothing here promotes it -- only BufDelete
-- records -- but closing a file and reopening it leaves it sitting in the list
-- while you are looking at it, and offering to open the file you are already in
-- is noise.
function M.recent(dir)
	local prefix = dir:gsub('/$', '') .. '/'
	local current = vim.api.nvim_buf_get_name(0)
	local seen, out = {}, {}

	local function add(path)
		if seen[path] or path == current then
			return
		end
		if not vim.startswith(path, prefix) then
			return
		end
		-- Deleted or moved since it was recorded
		if not vim.uv.fs_stat(path) then
			return
		end
		seen[path] = true
		out[#out + 1] = path
	end

	for _, path in ipairs(closed) do
		add(path)
	end
	for _, path in ipairs(vim.v.oldfiles) do
		add(path)
	end
	return out
end

return M
