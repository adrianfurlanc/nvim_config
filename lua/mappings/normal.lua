-- Move current line up and down
-- (formerly autoload/mappings/normal.vim; loaded on first use)

local function move(address, at_limit)
	if not at_limit then
		vim.cmd('move ' .. address)
		vim.cmd('normal! ==')
	end
end

local M = {}

function M.move_up()
	local at_top = vim.fn.line('.') == 1
	move('.-2', at_top)
end

function M.move_down()
	local at_bottom = vim.fn.line('.') == vim.fn.line('$')
	move('.+1', at_bottom)
end

return M
