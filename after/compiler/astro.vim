" Compiler plugin for `astro check`, the type-checker that understands .astro
" components. Invoked by :AstroCheck (see lua/functions.lua), which supplies
" the project root as a :Make argument.
"
" Unlike its neighbours this overrides nothing — nvim ships no astro compiler.
" It lives in after/ anyway so all four compilers sit together, documented by
" the README next to them.
"
" Prefer this over :Typecheck (after/compiler/tsc.vim) in an Astro project:
" plain tsc silently skips .astro files as an unknown extension, so it only
" ever sees the .ts ones. `astro check` covers both, and reports the same TS
" diagnostics with the same codes.
"
" Requires @astrojs/check, plus typescript 6.x — the 7.x native compiler does
" not expose the programmatic API the checker needs, and it refuses to start.
"
" --root, rather than a list of files, for the same reason tsc gets -p: it
" keeps tsconfig.json authoritative ("extends": "astro/tsconfigs/strict" and
" the generated .astro/types.d.ts). Diagnostics come out relative to the
" current directory, which is where :make resolves them from.
"
" makeprg is the bin/astro-check wrapper next to this config, not npx directly,
" because `astro check` always colours its output and the escapes have to be
" stripped before the errorformat sees them. The full reasoning — including
" why the filter can't just be a pipe in 'makeprg' — is in the script itself.

if exists(':CompilerSet') != 2
  command -nargs=* CompilerSet setlocal <args>
endif

" Built from stdpath() so the path is right wherever the config is checked out,
" and escaped in case that path ever contains a space. No $*: with none, :make
" appends its argument (the project root) at the end, which is where the
" wrapper wants it.
execute 'CompilerSet makeprg=' . escape(stdpath('config') . '/bin/astro-check', ' \|"')

" Matches one diagnostic per line, for all three severities: %t takes the
" first character of error/warning/hint, and %\w%# eats the rest of the word.
" %n captures the TS code, so :clist shows it. Everything else — the startup
" banner, the source excerpt and its ~~~~ underline, and the trailing
" "Result (N files)" summary — is dropped by the catch-all.
CompilerSet errorformat=
      \%f:%l:%c\ -\ %t%\\w%#\ ts(%n):\ %m,
      \%-G%.%#

finish " Sample output follows (after the colour has been stripped):

08:20:41 [types] Generated 21ms
08:20:41 [check] Getting diagnostics for Astro files in /Users/adrianfurlan/Desktop/Vibe Coding/adrianfurlan.com...
src/lib/format.ts:2:17 - error ts(2551): Property 'lenght' does not exist on type 'string'. Did you mean 'length'?

2   return nombre.lenght;
                  ~~~~~~

src/pages/index.astro:2:7 - error ts(2322): Type 'string' is not assignable to type 'number'.

2 const n: number = "no soy un número";
        ~

Result (8 files):
- 2 errors
- 0 warnings
- 0 hints
