require('functions').plaintext()

-- :Preview [file] — render the file in Marked, defaulting to this buffer's.
-- Buffer-local because it's only meaningful for markdown; defined here rather
-- than in lua/config/keymaps.lua (where :W lives) for that reason.
vim.api.nvim_buf_create_user_command(0, 'Preview', function(opts)
	require('functions').preview(opts.args)
end, { nargs = '?', complete = 'file', desc = 'Preview the file in Marked' })

-- With 'wrap', 'cursorline' highlights every screen row of the current
-- (paragraph-long) line; keep only the line-number highlight instead.
vim.opt_local.cursorlineopt = 'number'

-- Wrapped-line layout for prose. The global setting is "shift:2" (see
-- lua/config/options.lua), which indents the continuation *and* the '⤷ ' from
-- 'showbreak' along with it, so the arrow drifts right of the column the
-- paragraph starts in:
--
--     El micrófono dinámico convierte la presión sonora
--       ⤷ en una señal eléctrica mediante una bobina
--
-- "sbr" draws 'showbreak' before the added indent instead, pinning the arrow
-- to the paragraph's own column and shifting only the text, which makes the
-- continuation obvious at a glance in a wall of prose:
--
--     El micrófono dinámico convierte la presión sonora
--     ⤷   en una señal eléctrica mediante una bobina
--
-- "list:-1" adds to that for list items only, indenting the continuation by
-- the width of the bullet or number that 'formatlistpat' matched, so wrapped
-- text hangs under the item's text instead of under its marker:
--
--     - Dinámicos: robustos y sin alimentación externa,
--     ⤷     muy usados en directo
--
-- The pattern is read at redraw time, and $VIMRUNTIME/ftplugin/markdown.vim
-- (sourced right after this file) sets a markdown-aware one covering -/*/+,
-- numbered items and footnote definitions — so this needs nothing from us.
--
-- Read off 'shiftwidth' rather than hard-coded so it tracks the buffer if
-- editorconfig sets a different width for a given project's markdown.
vim.opt_local.breakindentopt = 'sbr,shift:' .. vim.bo.shiftwidth .. ',list:-1'

-- Fold by heading instead of by indent. The global 'foldmethod' is "indent",
-- which is meaningless in prose (paragraphs aren't indented), so markdown
-- buffers effectively had no folds at all; treesitter gives one fold per
-- section, nested by heading level.
--
-- No guard needed around either line: 'foldexpr' is a core nvim function (the
-- nvim-treesitter plugin only supplies the parser), and it returns 0 — i.e.
-- "no fold" — rather than erroring if the markdown parser isn't installed yet.
-- The parser itself is already started by $VIMRUNTIME/ftplugin/markdown.lua,
-- which runs right after this file.
--
-- 'foldlevelstart' is 99 (see lua/config/options.lua), so files still open
-- with every section expanded; zc/za close them on demand.
vim.opt_local.foldmethod = 'expr'
vim.opt_local.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
