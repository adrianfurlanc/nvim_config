-- Hard-wrap prose at 90 columns as you type.
--
-- In after/ rather than ftplugin/markdown.lua: $VIMRUNTIME/ftplugin/markdown.vim
-- is sourced after that file and does `formatoptions+=tcqln`, which would put
-- 'l' straight back. This also overrides the textwidth=0 from
-- functions.plaintext().
vim.opt_local.textwidth = 90

-- 'l' leaves lines that were already longer than 'textwidth' alone. Without it,
-- typing past column 90 on an existing long line wraps that line too.
vim.opt_local.formatoptions:remove('l')

-- Keep the auto-wrap out of frontmatter, code, tables, HTML and headings.
vim.opt_local.formatexpr = "v:lua.require'functions'.markdown_formatexpr()"

-- Mark the limit, one column past 'textwidth'.
vim.opt_local.colorcolumn = '+1'
