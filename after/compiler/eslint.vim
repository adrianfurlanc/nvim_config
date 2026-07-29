" Overrides for the ESLint compiler plugin. Invoked by :Lint (see
" lua/functions.lua), which supplies the path to lint as a :Make argument.
"
" Two things need fixing, which is why this exists at all:
"
" 1. pangloss/vim-javascript (lua/plugins/lang.lua) ships its own
"    compiler/eslint.vim and wins: it sits before $VIMRUNTIME on
"    'runtimepath', and sets 'current_compiler', so the bundled compiler
"    bails at its `if exists("current_compiler")` guard. Its makeprg is
"    `eslint -f compact %` — but the compact formatter was removed from
"    core in ESLint 10 ("no longer part of core ESLint. Install it manually
"    with `npm install -D eslint-formatter-compact`"), so it fails before
"    linting anything, and its errorformat expects that dead format.
"
" 2. The bundled makeprg passes no path, and ESLint lints nothing when given
"    none — it exits silently with no output.
"
" Living under after/ means this is sourced last, so it wins over both.
" Vimscript rather than Lua because :compiler only looks for compiler/{name}.vim.

if exists(':CompilerSet') != 2
  command -nargs=* CompilerSet setlocal <args>
endif

" npx, not a bare eslint: it's a devDependency, not on $PATH.
CompilerSet makeprg=npx\ eslint\ --format\ stylish

" Verbatim from $VIMRUNTIME/compiler/eslint.vim, which parses stylish output
" correctly — verified against real output from the Astro projects. Repeated
" here only because vim-javascript's value would otherwise be left in place.
"
" Stylish prints a filename header, then indented "line:col  error  msg" rows,
" so the file is pushed with %-P and popped with %-Q; %-G drops the blank
" lines and the "✖ N problems" summary. See after/compiler/README.md.
CompilerSet errorformat=
      \%-P%f,
      \%\\s%#%l:%c\ %#\ %trror\ \ %m,
      \%\\s%#%l:%c\ %#\ %tarning\ \ %m,
      \%-Q,
      \%-G%.%#

finish " Sample output follows:

/Users/adrianfurlan/Desktop/Vibe Coding/adrianfurlan.com/src/pages/index.astro
  4:5   error  'set:text' conflicts with 'set:html'  astro/no-conflict-set-directives
  4:22  error  'set:html' conflicts with 'set:text'  astro/no-conflict-set-directives

✖ 2 problems (2 errors, 0 warnings)
