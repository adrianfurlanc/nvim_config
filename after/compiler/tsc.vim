" Overrides for the TypeScript compiler plugin. Invoked by :Typecheck (see
" lua/functions.lua), which supplies the project root as a :Make argument.
"
" Only makeprg is wrong in the bundled compiler ($VIMRUNTIME/compiler/tsc.vim):
" it defaults to a bare `tsc`, which isn't on $PATH here (it's a devDependency).
" The bundled file reads g:tsc_makeprg if set, but that would leave the flags
" below scattered across two places, so it's set outright here.
"
" Its errorformat is left untouched: it parses tsc's output correctly, verified
" against real TypeScript 7 output including a project path containing a space
" (%f stops at the literal "(" that follows, so "Vibe Coding" survives intact).
" Nothing shadows the bundled file the way vim-javascript shadows eslint's.
"
" -p (--project) rather than a list of files, because passing file paths to tsc
" makes it ignore tsconfig.json entirely — losing "extends": "astro/tsconfigs/
" strict" and the generated .astro/types.d.ts. With -p, the argument is the
" directory holding tsconfig.json, and diagnostics come out relative to the
" current directory, which is where :make resolves them from.
"
" NOTE: this only type-checks .ts/.tsx files. tsc skips .astro components as an
" unknown extension, so it silently sees just the .ts half of an Astro project.
" after/compiler/astro.vim (:AstroCheck) covers both and is what to reach for
" there; this stays for plain TypeScript, and for projects where `astro check`
" cannot run — it needs @astrojs/check with typescript 6.x, which the 7.x
" native compiler does not satisfy (the reasoning is in that file, along with
" https://github.com/withastro/roadmap/discussions/1321).

if exists(':CompilerSet') != 2
  command -nargs=* CompilerSet setlocal <args>
endif

CompilerSet makeprg=npx\ tsc\ --noEmit\ -p

finish " Sample output follows:

src/lib/format.ts(2,15): error TS2551: Property 'lenght' does not exist on type 'string'. Did you mean 'length'?
src/lib/format.ts(4,14): error TS2322: Type 'string' is not assignable to type 'number'.
