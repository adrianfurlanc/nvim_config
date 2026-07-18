-- Cleaner/simpler clone of the built-in tabline, but without the window
-- counts, the modified flag, or the close widget.
-- (Formerly autoload/tabline.vim; only loaded on the first tabline redraw,
-- when the 'tabline' expression first require()s it.)

local M = {}

function M.line()
	local line = ''
	local current = vim.fn.tabpagenr()
	for i = 1, vim.fn.tabpagenr('$') do
		if i == current then
			line = line .. '%#TabLineSel#'
		else
			line = line .. '%#TabLine#'
		end
		line = line .. '%' .. i .. 'T' -- Starts mouse click target region.
		line = line .. " %{v:lua.require'tabline'.label(" .. i .. ')} '
	end
	line = line .. '%#TabLineFill#'
	line = line .. '%T' -- Ends mouse click target region(s).
	return line
end

function M.label(n)
	local buflist = vim.fn.tabpagebuflist(n)
	local winnr = vim.fn.tabpagewinnr(n)
	local name = vim.fn.bufname(buflist[winnr])
	if name == '' then
		return '[No Name]'
	end
	return vim.fn.pathshorten(vim.fn.fnamemodify(name, ':~:.'))
end

return M
