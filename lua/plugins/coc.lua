-- coc.nvim configuration.
--
-- Extensions listed in g:coc_global_extensions are installed automatically
-- the first time coc starts. Diagnostics display (virtual text, signs, etc.)
-- is configured in coc-settings.json next to init.lua.
return {
	-- Nodejs extension host for vim & neovim, load extensions like VSCode and
	-- host language servers. The release branch ships prebuilt — master needs
	-- a yarn build.
	'neoclide/coc.nvim',
	branch = 'release',
	-- Pinned 2026-08-07: the next release build (1245b4a7, built from
	-- master 2026-08-05) never finishes initializing when the plugin is
	-- sourced late, which the VeryLazy event below does. Its new
	-- coc#rpc#notify() drops every message until g:coc_enabled is 1, but on
	-- late sourcing the initial 'VimEnter' notify to the server is what's
	-- dropped -- and the server sets coc_enabled only after receiving it, so
	-- both sides wait forever and no diagnostics/completion ever arrive.
	-- Remove the pin once upstream fixes the deadlock (test: open a .ts file,
	-- :echo g:coc_service_initialized should be 1).
	commit = 'd1689a4876305e5fc6691910c8ee6f1eb5da2219',
	-- Loaded right after the UI paints instead of during startup: coc's
	-- plugin file starts the node server itself when sourced late (it only
	-- waits for VimEnter when loaded during startup), and the server attaches
	-- every already-open buffer when it initializes.
	event = 'VeryLazy',
	init = function()
		-- Options live in init so they apply during startup: 'signcolumn'
		-- reserved up front means no text shift when coc loads a moment later.
		-- Faster CursorHold so diagnostics and hover feel responsive (default 4000ms)
		vim.opt.updatetime = 300

		-- Always show the sign column so text doesn't shift when diagnostics appear
		vim.opt.signcolumn = 'yes'

		-- 'nobackup' is set in lua/config/options.lua, but 'writebackup' is on by
		-- default and some language servers mis-handle the write-time backup
		-- (coc.nvim #649)
		vim.opt.writebackup = false

		vim.g.coc_global_extensions = {
			'@yaegassy/coc-astro',
			'coc-tsserver',
			'coc-prettier',
			'coc-json',
			'coc-diagnostic',
			'coc-eslint',
			'coc-snippets',
		}

		-- Inside a snippet session coc maps these keys buffer-locally to jump
		-- between placeholders; they shadow the global <Tab>/<S-Tab> mappings
		-- in config until the session ends.
		vim.g.coc_snippet_next = '<Tab>'
		vim.g.coc_snippet_prev = '<S-Tab>'
	end,
	config = function()
		-- Global because the <Tab> mapping below is a Vimscript expression (coc's
		-- recommended lua setup) and reaches it through v:lua.
		function _G.coc_check_backspace()
			local col = vim.fn.col('.') - 1
			return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
		end

		-- <Tab>/<S-Tab> walk coc's completion menu, <CR> confirms the selection.
		-- Replaces supertab, which can't drive coc's custom popup. With the menu
		-- closed, <Tab> expands a snippet (or jumps) when the cursor is on one.
		local expr_opts = { silent = true, expr = true, replace_keycodes = false }
		vim.keymap.set('i', '<Tab>',
			[[coc#pum#visible() ? coc#pum#next(1) : coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" : v:lua.coc_check_backspace() ? "\<Tab>" : coc#refresh()]],
			expr_opts)
		vim.keymap.set('i', '<S-Tab>', [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], expr_opts)		vim.keymap.set('i', '<CR>',
			[[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<C-r>=coc#on_enter()\<CR>"]],
			expr_opts)

		-- Jump between diagnostics
		vim.keymap.set('n', '[g', '<Plug>(coc-diagnostic-prev)', { silent = true, remap = true })
		vim.keymap.set('n', ']g', '<Plug>(coc-diagnostic-next)', { silent = true, remap = true })

		-- Code navigation
		vim.keymap.set('n', 'gd', '<Plug>(coc-definition)', { silent = true, remap = true })
		vim.keymap.set('n', 'gy', '<Plug>(coc-type-definition)', { silent = true, remap = true })
		vim.keymap.set('n', 'gr', '<Plug>(coc-references)', { silent = true, remap = true })

		-- Documentation for the symbol under the cursor; falls back to native K
		-- ('keywordprg', i.e. :help) in buffers with no hover provider
		local function show_documentation()
			if vim.fn.CocAction('hasProvider', 'hover') then
				vim.fn.CocActionAsync('doHover')
			else
				vim.fn.feedkeys('K', 'in')
			end
		end
		vim.keymap.set('n', 'K', show_documentation, { silent = true })

		-- Rename symbol, code-action menu, and apply the preferred quickfix for the
		-- diagnostic on the current line
		vim.keymap.set('n', '<Leader>rn', '<Plug>(coc-rename)', { remap = true })
		vim.keymap.set('n', '<Leader>ca', '<Plug>(coc-codeaction-cursor)', { remap = true })
		vim.keymap.set('n', '<Leader>qf', '<Plug>(coc-fix-current)', { remap = true })

		-- Format the buffer / organize imports on demand
		vim.api.nvim_create_user_command('Format', function()
			vim.fn.CocActionAsync('format')
		end, {})
		vim.api.nvim_create_user_command('OR', function()
			vim.fn.CocActionAsync('runCommand', 'editor.action.organizeImport')
		end, {})
	end,
}
