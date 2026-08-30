-- ============================================================
-- Filetype detection overrides
--
-- Only for cases nvim's builtin detection gets wrong or doesn't cover.
-- Most things people used to write ftdetect rules for are handled natively
-- now (*.mts/*.cts, .prettierignore, .npmignore, .dockerignore, ...), so
-- check with `:set filetype?` on a real file before adding anything here.
-- ============================================================

vim.filetype.add({
	filename = {
		-- coc reads its config as JSON-with-comments, and documents it that
		-- way, but the name says plain .json so nvim detects 'json' and the
		-- linter flags every // as a syntax error. tsconfig.json already
		-- gets 'jsonc' natively for the same reason.
		--
		-- Nothing is lost by the switch: nvim maps the jsonc filetype to the
		-- json treesitter parser, ships a syntax/jsonc.vim for the regex
		-- fallback, and coc-json activates on 'jsonc' as well as 'json'.
		['coc-settings.json'] = 'jsonc',
	},
})

-- ============================================================
-- Big files
--
-- Nothing here guarded against one before. Measured against this config:
-- opening a 1MB .js blocked for 2973ms and a 1.4MB one for 3401ms, and a
-- 900KB .json opened fast but then burned 27.6s of deferred CPU. The same
-- files under `nvim --clean` take 7-11ms, so the cost is entirely ours.
--
-- It is almost all rainbow-delimiters: with its two autocmds gone the open is
-- a flat ~154ms at every size (256KB 812 -> 154, 512KB 1405 -> 155). It scales
-- with delimiter count, so the curve is linear in bytes -- 64KB 291ms, 128KB
-- 418ms, 256KB 695ms, 384KB 1043ms, 512KB 1440ms. Hence 256KB: it is where
-- the curve crosses ~0.7s, and half a megabyte would still wave through a
-- 1.4s block. The .json case is nvim-treesitter instead (27.6s -> 0.6s).
--
-- Routing this through a filetype rather than a size check per plugin is what
-- keeps it to one file: treesitter.lua's highlight autocmd is an explicit
-- filetype allowlist, rainbow-delimiters needs a parser and a query for the
-- filetype before it does anything, and coc has no extension registered for
-- 'bigfile'. All three stand down on their own.
--
-- Deliberately not extended to indent-blankline, nvim-highlight-colors and
-- vim-illuminate, which attach on buffer events and are not gated by this.
-- Each takes an exclude list, but adding 'bigfile' to all three moved 40
-- cursor moves on the 750KB file from 2944ms to 2873ms -- noise. illuminate
-- already self-guards at 10000 lines, and the other two only ever look at the
-- visible window.
-- ============================================================

local BIGFILE_BYTES = 256 * 1024

-- Shared with the autocmd below, which has to ask what the file would have
-- been detected as -- a question that runs this same pattern again and would
-- otherwise answer 'bigfile' a second time.
local restoring = false

vim.filetype.add({
	pattern = {
		-- priority beats the builtin extension rules, which are checked
		-- before unprioritised patterns. getfsize() returns -1 for anything
		-- that is not a real file, so oil:// and fugitive:// buffers fall
		-- through untouched, and the filename rule above still wins for
		-- coc-settings.json -- exact names are matched before any pattern.
		-- Costs one stat per detection: 0.0211ms -> 0.0216ms per match.
		['.*'] = {
			priority = math.huge,
			function(path)
				if restoring then
					return nil
				end
				if vim.fn.getfsize(path) > BIGFILE_BYTES then
					return 'bigfile'
				end
			end,
		},
	},
})

-- Nothing ships a syntax/bigfile.vim, so hand the buffer back cheap regex
-- highlighting for whatever it actually is. Free: on the 750KB minified file
-- the open is 536.5ms with this and 538.8ms without, because 'synmaxcol' (200,
-- lua/config/options.lua) is already capping the per-line work.
--
-- The schedule() is load-bearing, not tidiness. nvim loads syntax from its own
-- `FileType *` autocmd -- group `syntaxset`, out of synload.vim -- which does
-- the equivalent of `set syntax=<amatch>` and so puts 'syntax' straight back to
-- 'bigfile'. Which of the two wins is decided by registration order, and this
-- file is required early (init.lua:50) while syntaxset is installed later, so
-- it always runs second. Landing after the whole FileType chain is the only
-- ordering that holds. Measured before the fix: ft=bigfile with syntax=bigfile,
-- i.e. a buffer with no highlighting at all.
vim.api.nvim_create_autocmd('FileType', {
	group = vim.api.nvim_create_augroup('BigFile', {}),
	pattern = 'bigfile',
	callback = function(args)
		vim.schedule(function()
			-- The buffer can be gone by the time this runs.
			if not vim.api.nvim_buf_is_loaded(args.buf) then
				return
			end
			restoring = true
			local ft = vim.filetype.match({ buf = args.buf })
			restoring = false
			vim.bo[args.buf].syntax = ft or ''
		end)
	end,
})
