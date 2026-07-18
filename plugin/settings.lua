-- ============================================================
-- Options ('set' settings)
-- ============================================================

vim.opt.autoindent = true
vim.opt.backspace = { 'indent', 'eol', 'start' }    -- Backspace over indent, line breaks and insert start
vim.opt.clipboard = 'unnamed'                       -- Yank and paste with the system clipboard
vim.opt.copyindent = true                           -- Reuse existing indent characters on autoindent
vim.opt.cursorline = true                           -- Highlight the current line
vim.opt.diffopt = { 'vertical', 'iwhite' }          -- Open diffs in vertical splits; ignore whitespace changes
vim.opt.encoding = 'utf-8'                          -- UTF-8...
vim.opt.bomb = false                                -- ...without a byte order mark
vim.opt.exrc = true                                 -- Read project-local .nvimrc/.exrc (restricted by 'secure')
vim.opt.fileformats = { 'unix', 'dos' }             -- Prefer unix (LF) line endings, then dos (CRLF)
vim.opt.formatoptions:append('n')                   -- Recognize numbered lists when formatting
vim.opt.formatoptions:append('j')                   -- Remove comment leader when joining lines
vim.opt.gdefault = true                             -- Substitute all matches per line by default
vim.opt.guifont = 'Sauce Code Pro Medium Nerd Font Complete:h14' -- Font for GUI clients
vim.opt.hidden = true                               -- Switch buffers without saving first
vim.opt.history = 1000                              -- Remember 1000 command-line entries
vim.opt.hlsearch = true                             -- Highlight search matches
vim.opt.ignorecase = true                           -- Case-insensitive searching...
vim.opt.incsearch = true                            -- Show matches while typing a search
vim.opt.infercase = true                            -- Match case of typed text in completion
vim.opt.laststatus = 2                              -- Always show the statusline
vim.opt.lazyredraw = true                           -- Don't redraw mid-macro
vim.opt.linebreak = true                            -- Wrap lines at word boundaries
vim.opt.listchars = { tab = '▸ ', eol = '¬', trail = '·' } -- Symbols for tab, eol and trailing spaces
vim.opt.magic = true                                -- Standard regex special characters
vim.opt.modeline = true                             -- Honor modelines in files
vim.opt.modelines = 2                               -- Look for modelines in first/last 2 lines
vim.opt.backup = false                              -- No backup files
vim.opt.endofline = false                           -- Don't force a trailing newline on write
vim.opt.errorbells = false                          -- No beep on errors
vim.opt.showmode = false                            -- Hide mode message (lightline shows it)
vim.opt.startofline = false                         -- Keep cursor column on jumps
vim.opt.swapfile = false                            -- No swap files
vim.opt.nrformats = {}                              -- Treat all numbers as decimal for CTRL-A/X
vim.opt.number = true                               -- Show line numbers
vim.opt.report = 0                                  -- Always report how many lines changed
vim.opt.ruler = true                                -- Show cursor position in the statusline
vim.opt.scrolloff = 40                              -- Keep 40 lines visible around the cursor
vim.opt.secure = true                               -- Restrict unsafe commands in exrc files
vim.opt.shiftwidth = 4                              -- Indent with 4 spaces
vim.opt.tabstop = 4                                 -- Display tabs as 4 spaces
vim.opt.shortmess:append('A')                       -- No swapfile-exists warning
vim.opt.shortmess:append('I')                       -- No intro screen on startup
vim.opt.showcmd = true                              -- Show pending command keys
vim.opt.showmatch = true                            -- Briefly jump to the matching bracket
vim.opt.sidescrolloff = 3                           -- Same as scrolloff, but for columns
vim.opt.smartcase = true                            -- ...unless the pattern has uppercase
vim.opt.splitbelow = true                           -- Open horizontal splits below
vim.opt.splitright = true                           -- Open vertical splits to the right
vim.opt.switchbuf = 'usetab'                        -- Reuse windows/tabs already showing the buffer
vim.opt.synmaxcol = 200                             -- Only syntax-highlight the first 200 columns
vim.opt.tildeop = true                              -- Make ~ (toggle case) work as an operator
vim.opt.title = true                                -- Set the terminal window title
vim.opt.ttimeoutlen = 50                            -- 50ms key-code timeout (fast Esc)
vim.opt.undodir = vim.fn.expand('~/.config/nvim/undodir') -- Where undo history is stored
vim.opt.undofile = true                             -- Persist undo history across sessions
vim.opt.undolevels = 1000                           -- Keep 1000 undo levels
vim.opt.virtualedit = 'block'                       -- Free cursor movement in visual block mode
vim.opt.visualbell = true                           -- Flash instead of beeping
vim.opt.whichwrap = 'b,s,h,l,<,>,[,]'               -- Let these keys move across line breaks
vim.opt.wildignore = '*.swp,*.bak,*.pyc,*.class,*.pdf,*.zip,*.mkv,*.mp4,*.mp3' -- Files to ignore in completion
vim.opt.wildmenu = true                             -- Command-line completion menu
vim.opt.wildmode = 'list:full'                      -- List all matches, complete first match
vim.opt.wrap = true                                 -- Soft-wrap long lines
vim.opt_local.keywordprg = ':help'                  -- K looks up the word under cursor with :help

vim.opt.belloff = 'all'                             -- Never ring the bell, for any reason

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

-- Commented out settings
-- vim.opt.guifont = 'Sauce Code Pro Medium Nerd Font Complete:h14' -- GUI font
