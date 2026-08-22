-- Times every autocmd callback and reports the slowest into the quickfix
-- list, behind :DebugAutocmds.
--
-- Ported from folke/dot (lua/util/debug.lua, M.autocmds), with three changes:
--
--   * Gated behind an environment variable instead of wrapping the API
--     unconditionally. The wrapper has to be installed before anything
--     registers an autocmd to see the whole config, and that is too early to
--     be paying for a debug tool on every startup.
--   * Reports into the quickfix list rather than dumping to a notification.
--     Every row carries the callback's own source location, so <CR> opens the
--     autocmd that spent the time -- which is the question being asked.
--   * The :DebugAutocmds command is created once, in setup(). Upstream builds
--     it inside the wrapper, so it is redefined on every autocmd registered.
--
-- Enable for one session:
--
--     NVIM_AUTOCMD_PROFILE=1 nvim
--
-- exercise whatever felt slow, then :DebugAutocmds. With the variable unset,
-- nothing here loads and nvim_create_autocmd is untouched.
--
-- Only callbacks are timed. An autocmd declared with `command = '...'` never
-- passes through a lua function, so it cannot be measured and will not appear
-- -- lua/config/autocmds.lua has a few of those (VimResized, the FileType
-- soft-wrap rule).

local M = {}

---@class AutocmdStat
---@field event string|string[]
---@field group string|integer|nil
---@field file string
---@field lnum integer
---@field count integer
---@field time number  milliseconds, cumulative

---@type table<function, AutocmdStat>
local stats = {}

-- Group ids are resolved to names lazily, at report time: nvim_create_autocmd
-- is handed whatever the caller had (often a raw id from augroup()), and the
-- id -> name mapping is only worth building once, for the handful that ran.
local function group_names()
	local names = {}
	for _, au in ipairs(vim.api.nvim_get_autocmds({})) do
		if au.group and au.group_name then
			names[au.group] = au.group_name
		end
	end
	return names
end

function M.report()
	local rows = vim.tbl_values(stats)
	if #rows == 0 then
		vim.notify(
			'No autocmd callbacks have run yet. Was NVIM_AUTOCMD_PROFILE set at startup?',
			vim.log.levels.WARN
		)
		return
	end

	table.sort(rows, function(a, b) return a.time > b.time end)

	local names = group_names()
	local items = {}
	for _, e in ipairs(rows) do
		local event = type(e.event) == 'table' and table.concat(e.event, ',') or tostring(e.event)
		local group = e.group and (names[e.group] or tostring(e.group)) or '-'
		items[#items + 1] = {
			filename = e.file,
			lnum = e.lnum,
			col = 1,
			text = ('%8.2fms %6dx %8.3fms avg  %s  [%s]')
				:format(e.time, e.count, e.time / e.count, event, group),
		}
	end

	vim.fn.setqflist({}, ' ', { title = 'Autocmd profile', items = items })
	vim.cmd('copen')
end

function M.setup()
	local create = vim.api.nvim_create_autocmd

	---@diagnostic disable-next-line: duplicate-set-field
	vim.api.nvim_create_autocmd = function(event, opts)
		local cb = opts and opts.callback
		if type(cb) == 'function' then
			-- Captured here rather than in the wrapper: debug.getinfo on the
			-- original function is what names the config line, and doing it
			-- once per registration keeps it off the hot path.
			local info = debug.getinfo(cb, 'S')
			local file = info.source:sub(2)
			local lnum = info.linedefined

			opts.callback = function(...)
				local entry = stats[cb]
				if not entry then
					entry = {
						event = event,
						group = opts.group,
						file = file,
						lnum = lnum,
						count = 0,
						time = 0,
					}
					stats[cb] = entry
				end

				local start = vim.uv.hrtime()
				local ok, res = pcall(cb, ...)
				entry.time = entry.time + (vim.uv.hrtime() - start) / 1e6
				entry.count = entry.count + 1

				-- Re-raised, not swallowed: the wrapper must not change
				-- whether a broken autocmd is noticed. Level 0 keeps the
				-- original message rather than prefixing this file's line.
				if not ok then
					error(res, 0)
				end
				-- A callback returning true deletes its own autocmd, so the
				-- return value has to be handed back untouched.
				return res
			end
		end
		return create(event, opts)
	end

	vim.api.nvim_create_user_command('DebugAutocmds', function()
		M.report()
	end, { desc = 'Autocmd callbacks by time spent (quickfix)' })
end

return M
