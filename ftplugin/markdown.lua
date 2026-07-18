require('functions').plaintext()

-- With 'wrap', 'cursorline' highlights every screen row of the current
-- (paragraph-long) line; keep only the line-number highlight instead.
vim.opt_local.cursorlineopt = 'number'
