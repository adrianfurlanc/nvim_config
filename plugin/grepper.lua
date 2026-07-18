-- Grepper
vim.g.grepper = {
	tools = { 'rg', 'grep', 'git' },
	rg = { grepprg = 'rg -H --no-heading --vimgrep' },
}

vim.keymap.set('n', '<Leader>g', ':Grepper -tool rg<CR>')

-- Alias :grep to :GrepperGrep
require('functions').setup_command_alias('grep', 'GrepperGrep')
