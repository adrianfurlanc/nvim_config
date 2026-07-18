return {
	{
		'janko-m/vim-test', -- Run tests for multiple languages/frameworks directly from Vim
		cmd = { 'TestNearest', 'TestFile', 'TestSuite', 'TestLast', 'TestVisit' },
	},
	{
		'tpope/vim-dispatch', -- Asynchronous build and test dispatcher — runs jobs in the background
		cmd = { 'Dispatch', 'Make', 'Focus', 'Start' },
		dependencies = {
			'radenling/vim-dispatch-neovim', -- Adds Neovim terminal support to vim-dispatch
		},
	},
}
