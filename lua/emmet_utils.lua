-- Shadows emmet-vim's own lua/emmet_utils.lua.
--
-- emmet#getFileType() asks this module which language the cursor is in
-- whenever the buffer's 'filetype' isn't one emmet knows natively (astro,
-- svelte and vue all qualify). It takes the treesitter path rather than the
-- syntax one because nvim-treesitter sets g:loaded_nvim_treesitter.
--
-- The upstream version calls vim.treesitter.get_node(), which defaults to
-- ignore_injections = true. Inside a component's <style> block that returns
-- the raw_text of the <style> element, whose first named ancestor is an
-- `element` -- so it answers "html" and `m10` expands to <m10></m10> instead
-- of margin: 10px. That is most of the CSS in an Astro site, where the styles
-- live in scoped <style> blocks rather than standalone sheets.
--
-- Asking the parser which language actually owns the cursor's range gets the
-- injected css/scss/less tree, which is the question emmet meant to ask. The
-- ancestor walk below is upstream's, kept as the fallback for buffers with no
-- parser or no injection.
--
-- Returned names are matched by emmet#getFileType() against '^css' and
-- '^html', so 'css' is the right answer for an scss or less injection too --
-- 'scss' would fall through that chain into the filetype-splitting branch.

local M = {}

M.get_node_at_cursor = function()
	local pos = vim.api.nvim_win_get_cursor(0)
	local row = pos[1] - 1
	-- Expansion runs from insert mode, where the cursor sits one past the
	-- abbreviation; clamp so the range stays inside the line.
	local col = math.max(pos[2] - 1, 0)

	local ok, parser = pcall(vim.treesitter.get_parser, 0)
	if ok and parser then
		-- language_for_range reads the trees as they were last parsed, and an
		-- earlier expansion in the same buffer leaves the injection ranges
		-- stale -- which reports the <style> block as html again. Reparsing
		-- just the cursor's line refreshes the injections that matter without
		-- walking the whole buffer.
		pcall(parser.parse, parser, { row, row + 1 })

		local got, tree = pcall(parser.language_for_range, parser, { row, col, row, col })
		if got and tree then
			local lang = tree:lang()
			if lang == 'css' or lang == 'scss' or lang == 'less' then
				return 'css'
			end
		end
	end

	local node = vim.treesitter.get_node()
	if not node then
		return nil
	end

	while node do
		local node_type = node:type()

		if node_type == 'element' then
			return 'html'
		elseif node_type == 'stylesheet' then
			return 'css'
		end

		node = node:parent()
	end

	return ''
end

return M
