" Overrides for the Stylelint compiler plugin. Invoked by :Stylelint (see
" lua/functions.lua), which supplies the glob of files as a :Make argument.
"
" Only makeprg is wrong in the bundled compiler ($VIMRUNTIME/compiler/
" stylelint.vim): it calls a bare `stylelint`, which isn't on $PATH here (it's
" a devDependency), and passes no files at all — with no file arguments
" stylelint reads stdin and reports a single bogus "Empty source" error.
"
" Its errorformat is left untouched on purpose: it parses the compact
" formatter correctly, verified against real output from the Astro projects.
" Nothing shadows the bundled file the way vim-javascript shadows eslint's
" (see after/compiler/eslint.vim), so it is still in effect when this runs.

if exists(':CompilerSet') != 2
  command -nargs=* CompilerSet setlocal <args>
endif

CompilerSet makeprg=npx\ stylelint\ --formatter\ compact

finish " Sample output follows:

/Users/adrianfurlan/Desktop/Vibe Coding/adrianfurlan.com/src/styles/main.css: line 2, col 10, error - Expected "#FFFFFF" to be "#FFF" (color-hex-length)
/Users/adrianfurlan/Desktop/Vibe Coding/adrianfurlan.com/src/styles/main.css: line 3, col 12, error - Disallowed unit (length-zero-no-unit)
