-- Move lines up and down
-- (formerly autoload/mappings/visual.vim; loaded on first use)

-- Operates on the whole lines the selection covers, so charwise and
-- blockwise selections move too. :move keeps the '< and '> marks on the
-- text it moved, so gv reselects it afterwards.
local function move(address, at_limit)
	if not at_limit then
		vim.cmd("'<,'>move " .. address)
		vim.fn.feedkeys('gv=', 'n')
	end
	vim.fn.feedkeys('gv', 'n')
end

local M = {}

function M.move_up()
	local at_top = vim.fn.line("'<") == 1
	move("'<-2", at_top)
end

function M.move_down()
	local at_bottom = vim.fn.line("'>") == vim.fn.line('$')
	move("'>+1", at_bottom)
end

return M
