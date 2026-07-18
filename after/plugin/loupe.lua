-- Prevents <Leader>n mapping to toggle hlsearch
vim.g.LoupeClearHighlightMap = 0

-- Remove unwanted 's' from 'shortmess'.
vim.opt.shortmess:remove('s')

-- forces Vim to respect your 'smartcase' and 'ignorecase
vim.g.LoupeCaseSettingsAlways = 0
