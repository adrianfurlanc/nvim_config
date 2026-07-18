-- Move lines up and down
-- (formerly autoload/mappings/visual.vim; loaded on first use)

local function is_visual_line()
	return vim.fn.visualmode() == 'V'
end

local function move(address, at_limit)
	if is_visual_line() and not at_limit then
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
