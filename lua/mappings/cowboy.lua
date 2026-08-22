-- "Hold it Cowboy!" -- a nudge away from holding down h/j/k/l. Ten unbroken
-- presses of the same key inside a two-second window start swallowing it with
-- a warning; two seconds of not pressing it resets the count. A count prefix
-- (5j) resets it too: counted movement is exactly the habit this is nudging
-- toward, along with flash's jumps (lua/plugins/editing.lua).
--
-- Adapted from craftzdog/dotfiles (lua/craftzdog/discipline.lua), with one
-- structural change: his version maps each key to a bare `return map`, which
-- would replace the j/k visual-row mappings in lua/config/keymaps.lua. This
-- one captures whatever the key is mapped to at setup() time and reproduces
-- it, so j still moves by screen row and h/l fall through to the builtins.
--
-- craftzdog's +/- (line up/down) are deliberately not guarded: '-' is oil's
-- parent-directory mapping here (lua/plugins/oil.lua), and neither key is a
-- key anyone holds down.

local M = {}

function M.setup()
	for _, key in ipairs({ 'h', 'j', 'k', 'l' }) do
		local count = 0
		local timer = assert(vim.uv.new_timer())
		-- {} for an unmapped key (h/l), a dict with a callback for j/k.
		-- Captured once, which is why setup() must run after the mappings it
		-- wraps are defined (see the call site in lua/config/keymaps.lua).
		local existing = vim.fn.maparg(key, 'n', false, true)
		vim.keymap.set('n', key, function()
			if vim.v.count > 0 then
				count = 0
			end
			-- 'nofile' buffers (quickfix, undotree, which-key's own panels...)
			-- are exempt: scrolling a listing is not the habit being broken.
			if count >= 10 and vim.bo.buftype ~= 'nofile' then
				-- Scheduled rather than called directly: this runs during
				-- expr-mapping evaluation, where textlock forbids most UI work
				-- (craftzdog pcalls around the same problem). The default
				-- vim.notify lands in the message area, where the 5s timer in
				-- lua/config/autocmds.lua deliberately leaves warnings alone.
				vim.schedule(function()
					vim.notify('Hold it Cowboy! 🤠', vim.log.levels.WARN)
				end)
				-- Swallow the key. The timer keeps running from the tenth
				-- press, so this amounts to a 2s cooldown rather than a wall.
				return ''
			end
			count = count + 1
			timer:start(2000, 0, function()
				count = 0
			end)
			-- The mapping is noremap (vim.keymap.set's default), so a returned
			-- 'gj' or bare 'h' executes the builtin rather than re-entering
			-- this mapping.
			if existing.callback then
				return existing.callback()
			end
			return key
		end, { expr = true, silent = true })
	end
end

return M
