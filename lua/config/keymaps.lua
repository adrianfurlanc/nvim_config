-- ============================================================
-- Keyboard mappings
-- (mapleader is set in init.lua, before this file is loaded)
-- ============================================================

local map = vim.keymap.set

-- NORMAL

-- '-' opens the parent directory (vim-vinegar style); it lives with the
-- plugin that answers it, in lua/plugins/oil.lua.

map('n', '<CR>', function()
	if vim.bo.buftype == '' and vim.fn.reg_recorded() ~= '' then
		return '@' .. vim.fn.reg_recorded()
	end
	return '<CR>'
end, { expr = true })

-- Use <Leader>s instead of default <Leader>e:
map('n', '<Leader>s', '<Plug>(Scalpel)', { remap = true, desc = 'Substitute word' })

-- Toggle show/hide invisible chars
map('n', '<leader>i', ':set list!<cr>', { desc = 'Toggle invisible chars' })

-- Fuzzy-finder mappings (<C-p>, <leader>f*) live in lua/plugins/fzf.lua

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

-- :only mapped to leader+o
map('n', '<leader>o', ':only<cr>', { desc = 'Close other windows' })

-- Pre-fill the cmdline with :q (no <CR>: press Enter yourself, or add ! / a
-- count first)
map('n', '<leader>q', ':q', { desc = 'Prefill :q' })

-- <leader>p -- Show the path of the current file (mnemonic: path; useful when
-- you have a lot of splits and the status line gets truncated).
map('n', '<Leader>p', ":echo expand('%:p:h') . '/'<CR>", { desc = 'Show file path' })

-- Edit vimrc in new buffer
map('n', '<leader>mv', ':edit $MYVIMRC<CR>', { desc = 'Edit init.lua' })

-- Clears the search register
map('n', '<Leader>/', ':nohlsearch<CR>', { desc = 'Clear search highlight' })

-- Dismiss whatever is in the message area: errors and :messages output, which
-- are the two things the 5s timer deliberately leaves on screen (see
-- lua/config/autocmds.lua). <C-l> would do this in stock Vim, but is taken by
-- split navigation above.
map('n', '<Leader>L', function() require('functions').clear_message_area_now() end,
	{ silent = true, desc = 'Clear message area' })

-- Zap trailing whitespace
map('n', '<Leader>zz', function() require('functions').zap() end,
	{ silent = true, desc = 'Zap trailing whitespace' })

-- Delete Trailing Whitespace
map('n', '_$', function() require('functions').preserve([[%s/\s\+$//e]]) end,
	{ desc = 'Trim trailing whitespace' })

-- Use \+e to edit a file in the directory of the current file
map('n', '<LocalLeader>e', ":edit <C-R>=expand('%:p:h') . '/'<CR>", { desc = 'Edit file in this dir' })

-- Auto Indent File
map('n', '_=', function() require('functions').preserve('normal gg=G') end,
	{ desc = 'Auto-indent file' })

-- Yank the line's CONTENT: charwise, without the trailing newline, so p
-- pastes the text inline instead of opening a line below. That is the whole
-- point of the remap -- "yank entire line" is what it deliberately isn't.
--
-- A count is handed straight back to vim (3yy stays linewise, three whole
-- lines with their newlines), rather than given a charwise meaning of its
-- own: multi-line charwise is what visual mode is for -- select and press y.
-- Without this branch a count is silently swallowed and 3yy yanks one line.
--
-- "%s is v:register, which a callback mapping would otherwise drop, sending
-- "ayy to the unnamed register.
map('n', 'yy', function()
	if vim.v.count > 0 then
		return vim.cmd(('normal! %d"%syy'):format(vim.v.count, vim.v.register))
	end
	-- y$ leaves the cursor at column 0, where the 0 put it; native yy doesn't
	-- move at all.
	local pos = vim.fn.getcurpos()
	vim.cmd(('normal! 0"%sy$'):format(vim.v.register))
	vim.fn.setpos('.', pos)
end, { desc = 'Yank line (charwise, no newline)' })

-- Y (yank to end of line) needs no mapping: nvim maps it to y$ by default,
-- unlike vim, where it was a synonym for yy.

-- Find merge conflict markers
map('n', '<leader>fc', [[/\v^[<|=>]{7}( .*|$)<CR>]], { desc = 'Find merge conflicts' })

map('n', 'c*', '*Ncgn')

-- <leader>G is free: it toggled vim-gitgutter's signs, and there is no gutter
-- diff plugin any more (see lua/plugins/git.lua).

map('n', '<Leader>v', 'gv', { desc = 'Reselect last selection' })

-- [w/]w and [W/]W are free: they walked ALE's issues, and ALE is disabled
-- (its spec is kept, unloaded, in lua/plugins/misc.lua). The <Plug> targets
-- never existed, so the keys sat there timing out and advertising themselves
-- in which-key. Diagnostics are coc's now, on [g/]g (see lua/plugins/coc.lua).

-- Toggle Folds
-- map('n', '<Tab>', 'za')
-- map('n', '<F6>', '<C-i>')

-- Go to functions
map('n', '[[', '?{<CR>w99[{', { remap = true, desc = 'Previous function start' })
map('n', '][', '/}<CR>b99]}', { remap = true, desc = 'Next function end' })
map('n', ']]', 'j0[[%/{<CR>', { remap = true, desc = 'Next function start' })
map('n', '[]', 'k$][%?}<CR>', { remap = true, desc = 'Previous function end' })

-- <Leader>c is ListToggle's quickfix toggle (see lua/plugins/editing.lua).
-- It used to double as a comment-line alias for gcc, but ListToggle maps
-- over it when it loads at VeryLazy; native gcc/gc cover commenting.

-- Move lines around
map('n', '<C-Up>', function() require('mappings.normal').move_up() end, { silent = true })
map('n', '<C-Down>', function() require('mappings.normal').move_down() end, { silent = true })

-- Open files in same directory as current file
map('n', '<leader>ew', ':e %%', { remap = true, desc = 'Edit in this dir' })
map('n', '<leader>es', ':sp %%', { remap = true, desc = 'Split in this dir' })
map('n', '<leader>ev', ':vsp %%', { remap = true, desc = 'Vsplit in this dir' })
map('n', '<leader>et', ':tabe %%', { remap = true, desc = 'Tab in this dir' })

-- Cycle through line numbering modes
map('n', '<Leader>r', function() require('functions').cycle_numbering() end,
	{ silent = true, desc = 'Cycle line numbering' })

-- Stop annoying paren match highlighting from flashing all over the screen,
-- or start it.
--
-- (mnemonic: [m]atch paren)
map('n', '<Leader>m', function()
	vim.cmd(vim.g.loaded_matchparen and 'NoMatchParen' or 'DoMatchParen')
end, { silent = true, desc = 'Toggle paren match' })

-- VISUAL

-- Visual shifting (does not exit Visual mode)
map('v', '<', '<gv')
map('v', '>', '>gv')

-- Make dot work over visual line selections
map('x', '.', ':norm.<CR>')

-- Execute a macro over visual line selections
map('x', 'Q', ":'<,'>:normal @q<CR>")

-- Move lines around. The leading ':' (rather than <Cmd>) is deliberate: it
-- leaves Visual mode, which is what sets '< and '> to the current selection.
map('x', '<C-Up>', ":<C-u>lua require('mappings.visual').move_up()<CR>", { silent = true })
map('x', '<C-Down>', ":<C-u>lua require('mappings.visual').move_down()<CR>", { silent = true })

-- Split navigation from visual mode
map('x', '<C-h>', '<C-w>h')
map('x', '<C-j>', '<C-w>j')
map('x', '<C-k>', '<C-w>k')
map('x', '<C-l>', '<C-w>l')
map('x', '<C-]>', '<C-w>]')


-- COMMAND

-- :W writes the current file as root, :W! re-prompts for the password.
-- Replaces the old `w!!` cmdline abbreviation (`w !sudo tee %`), which asked
-- for the password on every write; lua/sudo/write.lua feeds it to sudo via
-- SUDO_ASKPASS instead and caches it for 5 minutes.
vim.api.nvim_create_user_command('W', function(opts)
	require('sudo.write')(opts.bang and '!' or '')
end, { bang = true, desc = 'Write the current file as root' })

-- Lint the whole project into the quickfix list, asynchronously via
-- vim-dispatch. The compilers these use are configured in after/compiler/.
--
-- :Lint runs every check that fits the current buffer's filetype and merges
-- them into one list — .ts/.tsx get tsc and ESLint together, .astro gets
-- astro check (the table lives in lua/functions.lua). It reports what it found
-- when it finishes, including a tool that failed to run at all. The four below
-- name a single check outright and hand the quickfix list to vim-dispatch.
vim.api.nvim_create_user_command('Lint', function()
	require('functions').lint_filetype()
end, { desc = "Check the project with this filetype's tools (quickfix)" })

vim.api.nvim_create_user_command('Eslint', function()
	require('functions').lint('eslint')
end, { desc = 'Lint the project with ESLint (quickfix)' })

vim.api.nvim_create_user_command('Stylelint', function()
	require('functions').lint('stylelint')
end, { desc = 'Lint the project stylesheets with Stylelint (quickfix)' })

-- Type-checks .ts/.tsx only — tsc skips .astro files as an unknown
-- extension. Use :AstroCheck in an Astro project; this stays for plain
-- TypeScript, and for when astro check is unavailable.
vim.api.nvim_create_user_command('Typecheck', function()
	require('functions').lint('tsc')
end, { desc = 'Type-check the project with tsc (quickfix)' })

-- Type-checks .astro components as well as .ts/.tsx.
vim.api.nvim_create_user_command('AstroCheck', function()
	require('functions').lint('astro')
end, { desc = 'Type-check the project with astro check (quickfix)' })

-- Open files in same directory as current file
map('c', '%%', "<C-R>=fnameescape(expand('%:h')).'/'<cr>")

-- Change Working Directory to that of the current file
map('c', 'cd.', 'cd %:p:h')

map('c', '<C-a>', '<Home>')
map('c', '<C-e>', '<End>')
