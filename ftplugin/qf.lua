-- :Cfilter {pat} keeps the quickfix entries matching {pat} and :Cfilter! {pat}
-- drops them; :Lfilter is the location-list twin. Both test the entry's text
-- *and* its filename (`v:val.text =~# pat || bufname(v:val.bufnr) =~# pat`), so
-- one command narrows either by rule or by file.
--
-- Each run pushes a new list rather than editing the current one, so filters
-- stack and :colder backs out of one that cut too far -- the same list history
-- :Lint's runs already sit in. The list title carries the filter that made it.
--
-- The complement to report() in lua/functions.lua, which already dedupes the
-- merged tsc/ESLint/stylelint output of :Lint down to one entry per line. That
-- removes the duplication it can predict; this narrows whatever is left by
-- hand, which is the half that cannot be decided in advance.
--
-- cfilter ships with nvim but lives under pack/dist/opt, which is not on the
-- runtimepath until something asks for it. Loading it from here rather than at
-- startup means nothing is paid until a quickfix window actually opens.
--
-- Guarded because an ftplugin runs for every window of the filetype and
-- :packadd re-sources the plugin file each call: 0.185ms a time against
-- 0.0003ms for the exists() check.
if vim.fn.exists(':Cfilter') == 0 then
	vim.cmd.packadd('cfilter')
end
