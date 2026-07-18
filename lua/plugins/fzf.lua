-- fzf.vim builds on the base fzf plugin from the git install in ~/.fzf,
-- which is kept on the runtimepath via performance.rtp.paths in
-- lua/config/lazy.lua (lazy.nvim resets 'runtimepath' at startup).
return {
	'junegunn/fzf.vim', -- Use FZF for searching buffers, Ex commands, etc
}
