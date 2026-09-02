return {
	{ 'christoomey/vim-tmux-navigator' },     -- Easier (tmux - vim) navigation
	{
		'edkolev/tmuxline.vim', -- Create tmux line from lightline theme
		cmd = { 'Tmuxline', 'TmuxlineSnapshot' },
	},
}

-- No focus-events plugin here on purpose. tmux-plugins/vim-tmux-focus-events
-- smuggled FocusGained/FocusLost through tmux by mapping <F24>/<F25> to
-- doautocmd, back when tmux swallowed them. nvim reports focus natively now.
--
-- Measured rather than assumed, which this file's history earns: with both
-- mappings confirmed gone (maparg('<F25>','n') empty), fourteen FocusLost and
-- FocusGained still arrived across seven pane switches, timestamped and
-- alternating cleanly. Nothing paired within milliseconds either, so it had not
-- been double-firing -- the events were always nvim's.
--
-- Three things here consume them and all keep working: the window dimming in
-- lua/config/autocmds.lua, lightline's git-status refresh, and terminus's
-- `autocmd FocusGained * silent! checktime`, which is what reloads a file
-- changed in another pane. That last one is why terminus stays (see its spec in
-- lua/plugins/ui.lua) -- nvim has no equivalent, and focus events arriving is
-- only half of it; something has to act on them.
--
-- tmux needs `focus-events on` for any of this, which ~/.tmux.conf:179 sets.
