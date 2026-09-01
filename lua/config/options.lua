-- ============================================================
-- Options ('set' settings)
-- ============================================================

vim.opt.clipboard = 'unnamed'                       -- Yank and paste with the system clipboard
vim.opt.confirm = true                              -- Prompt to save instead of failing :q on unsaved changes
vim.opt.copyindent = true                           -- Reuse existing indent characters on autoindent
vim.opt.cursorline = true                           -- Highlight the current line
-- 'append', not '=': '=' would drop nvim's own diff defaults, and 'filler'
-- among them is what keeps the two panes of a diff aligned.
vim.opt.diffopt:append({ 'vertical', 'iwhite' })    -- Open diffs in vertical splits; ignore whitespace changes
-- Gated by the trust list, not by 'secure' (removed in nvim): nvim prompts the
-- first time it finds one of these and remembers the answer. The search covers
-- the cwd AND every parent directory, and project.nvim moves the cwd as you
-- open files. :trust manages the list; see :help vim.secure.read().
vim.opt.exrc = true                                 -- Read project-local .nvim.lua/.nvimrc/.exrc
vim.opt.fileformats = { 'unix', 'dos' }             -- Prefer unix (LF) line endings, then dos (CRLF)
vim.opt.fillchars:append({ eob = ' ' })             -- Blank instead of ~ past the end of the buffer
vim.opt.formatoptions:append('n')                   -- Recognize numbered lists when formatting
vim.opt.formatoptions:append('j')                   -- Remove comment leader when joining lines
vim.opt.gdefault = true                             -- Substitute all matches per line by default
vim.opt.guifont = 'Sauce Code Pro Medium Nerd Font Complete:h14' -- Font for GUI clients
vim.opt.ignorecase = true                           -- Case-insensitive searching...
vim.opt.inccommand = 'split'                        -- Live preview of :substitute, with match window
vim.opt.infercase = true                            -- Match case of typed text in completion
vim.opt.linebreak = true                            -- Wrap lines at word boundaries
vim.opt.listchars = { tab = '▸ ', eol = '¬', trail = '·' } -- Symbols for tab, eol and trailing spaces
vim.opt.modelines = 2                               -- Look for modelines in first/last 2 lines
vim.opt.backup = false                              -- No backup files
vim.opt.showmode = false                            -- Hide mode message (lightline shows it)
vim.opt.startofline = false                         -- Keep cursor column on jumps
vim.opt.swapfile = false                            -- No swap files
vim.opt.nrformats = {}                              -- Treat all numbers as decimal for CTRL-A/X
vim.opt.number = true                               -- Show line numbers
vim.opt.report = 0                                  -- Always report how many lines changed
vim.opt.scrolloff = 40                              -- Keep 40 lines visible around the cursor
vim.opt.shiftwidth = 4                              -- Indent with 4 spaces
vim.opt.tabstop = 4                                 -- Display tabs as 4 spaces
vim.opt.shortmess:append('A')                       -- No swapfile-exists warning
vim.opt.shortmess:append('I')                       -- No intro screen on startup
vim.opt.showmatch = true                            -- Briefly jump to the matching bracket
vim.opt.sidescrolloff = 3                           -- Same as scrolloff, but for columns
vim.opt.smartcase = true                            -- ...unless the pattern has uppercase
vim.opt.splitbelow = true                           -- Open horizontal splits below
vim.opt.splitright = true                           -- Open vertical splits to the right
vim.opt.switchbuf = 'usetab'                        -- Reuse windows/tabs already showing the buffer
vim.opt.synmaxcol = 200                             -- Only syntax-highlight the first 200 columns
vim.opt.termguicolors = true                        -- 24-bit color in the terminal
vim.opt.tildeop = true                              -- Make ~ (toggle case) work as an operator
vim.opt.title = true                                -- Set the terminal window title
-- 'ttimeoutlen' is 10, not nvim's default of 50, and is deliberately not set in
-- this file: wincent/terminus runs `if &ttimeoutlen > 10 | set ttimeoutlen=10`
-- unconditionally and after this file, so any larger value set here is
-- overwritten a moment later -- which is silently what the old `= 50` line got.
-- A value of 10 or less would survive that guard. See lua/plugins/ui.lua.
vim.opt.undodir = vim.fn.expand('~/.config/nvim/undodir') -- Where undo history is stored
vim.opt.undofile = true                             -- Persist undo history across sessions
vim.opt.virtualedit = 'block'                       -- Free cursor movement in visual block mode
vim.opt.whichwrap = 'b,s,h,l,<,>,[,]'               -- Let these keys move across line breaks
vim.opt.wildignore = '*.swp,*.bak,*.pyc,*.class,*.pdf,*.zip,*.mkv,*.mp4,*.mp3' -- Files to ignore in completion
vim.opt.wildmode = 'list:full'                      -- List all matches, complete first match
vim.opt.wrap = true                                 -- Soft-wrap long lines
vim.opt.keywordprg = ':help'                        -- K looks up the word under cursor with :help

-- Wrapped-line indentation and prefix
vim.opt.breakindent = true                          -- Indent wrapped lines to match line start
vim.opt.showbreak = '⤷ '                            -- ARROW POINTING DOWNWARDS THEN CURVING RIGHTWARDS (U+2937)
vim.opt.breakindentopt = 'shift:2'                  -- Emphasize broken lines by indenting them

-- Folding
vim.opt.foldmethod = 'indent'
vim.opt.foldlevelstart = 99                         -- Start with all folds open
vim.opt.foldtext = [[v:lua.require'functions'.foldtext()]] -- Custom fold summary line

-- Skip nvim's clipboard-provider auto-detection (probing $PATH and the
-- environment at first use); on macOS we know it's pbcopy/pbpaste.
vim.g.clipboard = {
	name = 'pbcopy',
	copy = { ['+'] = 'pbcopy', ['*'] = 'pbcopy' },
	paste = { ['+'] = 'pbpaste', ['*'] = 'pbpaste' },
	cache_enabled = 0,
}
