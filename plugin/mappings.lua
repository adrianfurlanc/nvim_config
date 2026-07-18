-- ============================================================
-- Keyboard mappings
-- (mapleader is set in init.lua, before this file is sourced)
-- ============================================================

local map = vim.keymap.set

-- NORMAL

-- Behave like vim-vinegar. Entering NERDTree on the parent folder.
-- NERDTree is an opt package, so load it first (no-op once loaded).
map('n', '-', function()
	require('functions').load_nerdtree()
	local target = vim.fn.expand('%') == '' and '.' or vim.fn.expand('%:p:h')
	vim.cmd('silent edit ' .. vim.fn.fnameescape(target))
end, { silent = true })

map('n', '<CR>', function()
	if vim.bo.buftype == '' and vim.fn.reg_recorded() ~= '' then
		return '@' .. vim.fn.reg_recorded()
	end
	return '<CR>'
end, { expr = true })

-- Use <Leader>s instead of default <Leader>e:
map('n', '<Leader>s', '<Plug>(Scalpel)', { remap = true })

-- Toggle show/hide invisible chars
map('n', '<leader>i', ':set list!<cr>')

-- Toggle FZF for fuzzy file search
-- map('n', '<C-p>', ':<C-u>FZF<CR>')

-- Easier split navigation
map('n', '<C-h>', '<C-w>h')
map('n', '<C-j>', '<C-w>j')
map('n', '<C-k>', '<C-w>k')
map('n', '<C-l>', '<C-w>l')

-- Move by visual row (not logical line), but store relative line number
-- jumps in the jumplist when they exceed a threshold.
map('n', 'j', function()
	local count = vim.v.count
	if count > 0 then
		return (count >= 5 and ("m'" .. count) or '') .. 'j'
	end
	return 'gj'
end, { expr = true })
map('n', 'k', function()
	local count = vim.v.count
	if count > 0 then
		return (count >= 5 and ("m'" .. count) or '') .. 'k'
	end
	return 'gk'
end, { expr = true })

-- Cycle through Quickfix list
map('n', '<Up>', ':cprevious<CR>', { silent = true })
map('n', '<Down>', ':cnext<CR>', { silent = true })
map('n', '<Left>', ':cpfile<CR>', { silent = true })
map('n', '<Right>', ':cnfile<CR>', { silent = true })

-- Switch between last two files
map('n', '<leader><leader>', '<c-^>')

-- :only mapped to leader+o
map('n', '<leader>o', ':only<cr>')

-- <leader>p -- Show the path of the current file (mnemonic: path; useful when
-- you have a lot of splits and the status line gets truncated).
map('n', '<Leader>p', ":echo expand('%:p:h') . '/'<CR>")

-- Edit vimrc in new buffer
map('n', '<leader>mv', ':edit $MYVIMRC<CR>')

-- Clears the search register
map('n', '<Leader>/', ':nohlsearch<CR>')

-- Dismiss whatever is in the message area: errors and :messages output, which
-- are the two things the 5s timer deliberately leaves on screen (see
-- plugin/autocmds.lua). <C-l> would do this in stock Vim, but is taken by
-- split navigation above.
map('n', '<Leader>L', function() require('functions').clear_message_area_now() end, { silent = true })

-- Zap trailing whitespace
map('n', '<Leader>zz', function() require('functions').zap() end, { silent = true })

-- Delete Trailing Whitespace
map('n', '_$', function() require('functions').preserve([[%s/\s\+$//e]]) end)

-- Use \+e to edit a file in the directory of the current file
map('n', '<LocalLeader>e', ":edit <C-R>=expand('%:p:h') . '/'<CR>")

-- Auto Indent File
map('n', '_=', function() require('functions').preserve('normal gg=G') end)

-- Yank entire line
map('n', 'yy', function() require('functions').preserve('normal 0y$') end)

-- Yank to end of line
map('n', 'Y', 'y$')

-- Find merge conflict markers
map('n', '<leader>fc', [[/\v^[<|=>]{7}( .*|$)<CR>]])

map('n', 'c*', '*Ncgn')

-- View changes in Gutter
map('n', '<leader>G', ':GitGutterToggle<CR>')

map('n', '<Leader>v', 'gv')

-- Mappings in the style of unimpaired-next
map('n', '[W', '<Plug>(ale_first)', { silent = true, remap = true })
map('n', '[w', '<Plug>(ale_previous)', { silent = true, remap = true })
map('n', ']w', '<Plug>(ale_next)', { silent = true, remap = true })
map('n', ']W', '<Plug>(ale_last)', { silent = true, remap = true })

-- Toggle Folds
-- map('n', '<Tab>', 'za')
-- map('n', '<F6>', '<C-i>')

-- Go to functions
map('n', '[[', '?{<CR>w99[{', { remap = true })
map('n', '][', '/}<CR>b99]}', { remap = true })
map('n', ']]', 'j0[[%/{<CR>', { remap = true })
map('n', '[]', 'k$][%?}<CR>', { remap = true })

-- Commenting
map('n', '<Leader>c', 'gcc', { remap = true })

-- Move lines around
map('n', '<C-Up>', function() require('mappings.normal').move_up() end, { silent = true })
map('n', '<C-Down>', function() require('mappings.normal').move_down() end, { silent = true })

-- Open files in same directory as current file
map('n', '<leader>ew', ':e %%', { remap = true })
map('n', '<leader>es', ':sp %%', { remap = true })
map('n', '<leader>ev', ':vsp %%', { remap = true })
map('n', '<leader>et', ':tabe %%', { remap = true })

-- Cycle through line numbering modes
map('n', '<Leader>r', function() require('functions').cycle_numbering() end, { silent = true })

-- Stop annoying paren match highlighting from flashing all over the screen,
-- or start it.
--
-- (mnemonic: [m]atch paren)
map('n', '<Leader>m', function()
	vim.cmd(vim.g.loaded_matchparen and 'NoMatchParen' or 'DoMatchParen')
end, { silent = true })

-- VISUAL

-- Visual shifting (does not exit Visual mode)
map('v', '<', '<gv')
map('v', '>', '>gv')

-- Make dot work over visual line selections
map('x', '.', ':norm.<CR>')

-- Execute a macro over visual line selections
map('x', 'Q', ":'<,'>:normal @q<CR>")

-- Split navigation from visual mode
map('x', '<C-h>', '<C-w>h')
map('x', '<C-j>', '<C-w>j')
map('x', '<C-k>', '<C-w>k')
map('x', '<C-l>', '<C-w>l')
map('x', '<C-]>', '<C-w>]')


-- COMMAND

-- w!! to write a file as sudo
map('c', 'w!!', 'w !sudo tee % >/dev/null')

-- Open files in same directory as current file
map('c', '%%', "<C-R>=fnameescape(expand('%:h')).'/'<cr>")

-- Change Working Directory to that of the current file
map('c', 'cd.', 'lcd %:p:h')

map('c', '<C-a>', '<Home>')
map('c', '<C-e>', '<End>')
