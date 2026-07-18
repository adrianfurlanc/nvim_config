-- Bufferline
-- Don't echo the buffer list to the command bar: its CursorHold echo
-- (firing after 'updatetime', which polyglot silently lowers to 300ms)
-- overwrites any command-line output, e.g. :messages.
vim.g.bufferline_echo = 0
