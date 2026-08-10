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

" The ignore patterns keep build output out of the quickfix list. :Stylelint
" globs from the project root, not src/ the way the projects' own lint:css
" scripts do, so a built Astro site puts its generated dist/index.html in front
" of the real files — 45 warnings from markup nobody wrote, sorted ahead of the
" 36 in src/. stylelint ignores node_modules on its own; these are the rest.
"
" Quoted, and this is load-bearing: vim-dispatch passes the command to
" jobstart() as a string, which nvim runs through 'shell' — zsh here, where **
" is a recursive glob. Left bare, zsh expands the patterns itself against the
" wrong directory, and aborts the whole command with "no matches found" when
" one of these directories doesn't exist. The quotes get them to stylelint
" intact, which is what expands them, relative to each file it considers.
CompilerSet makeprg=npx\ stylelint\ --formatter\ compact
      \\ --ignore-pattern\ '**/dist/**'
      \\ --ignore-pattern\ '**/build/**'
      \\ --ignore-pattern\ '**/.next/**'
      \\ --ignore-pattern\ '**/out/**'

finish " Sample output follows:

/Users/adrianfurlan/Desktop/Vibe Coding/adrianfurlan.com/src/styles/main.css: line 2, col 10, error - Expected "#FFFFFF" to be "#FFF" (color-hex-length)
/Users/adrianfurlan/Desktop/Vibe Coding/adrianfurlan.com/src/styles/main.css: line 3, col 12, error - Disallowed unit (length-zero-no-unit)
