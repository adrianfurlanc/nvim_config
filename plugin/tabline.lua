-- Custom tabline. The rendering functions live in lua/tabline.lua so they
-- are only loaded on first redraw.
--
-- Note: lightline would otherwise take over 'tabline' itself; it is told to
-- leave it alone in plugin/lightline.vim (g:lightline.enable.tabline).
vim.opt.tabline = [[%!v:lua.require'tabline'.line()]]
