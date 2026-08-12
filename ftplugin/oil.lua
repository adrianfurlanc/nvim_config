-- The display settings the NERDTree buffer had: a listing is not code, so no
-- color column, no folding and no 'list' characters in it.
--
-- No '-' mapping here, unlike ftplugin/nerdtree.lua, which had to bind it to
-- g:NERDTreeMapUpdir: oil maps '-' to actions.parent inside its own buffers.
vim.opt_local.colorcolumn = ''
vim.opt_local.foldenable = false
vim.opt_local.list = false
