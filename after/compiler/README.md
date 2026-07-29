# `errorformat` notes

Reference for the compiler plugins in this directory. Each one overrides part
of a compiler bundled with nvim (`$VIMRUNTIME/compiler/`) — see the comment at
the top of each file for what it changes and why.

They are driven by commands in `lua/config/keymaps.lua`, all of which go
through `require('functions').lint()` — it finds the project root, selects the
compiler, and hands the target to `:Make`:

| Command       | Compiler    | Covers                             |
| ------------- | ----------- | ---------------------------------- |
| `:Lint`       | `eslint`    | whatever `eslint.config.js` matches |
| `:Stylelint`  | `stylelint` | `.css`, `.astro`, `.html`          |
| `:Typecheck`  | `tsc`       | `.ts`/`.tsx` only                  |
| `:AstroCheck` | `astro`     | `.astro` as well as `.ts`/`.tsx`   |

`astro.vim` overrides nothing — nvim ships no astro compiler — but lives here
so all four sit together.

## Escaping inside a compiler plugin

`CompilerSet` takes an option assignment, so the value is escaped the way any
`:set` argument is:

| In the file | Means            |
| ----------- | ---------------- |
| `\ `        | a literal space  |
| `\\`        | a literal `\`    |
| leading `\` | line continuation |

That double layer is why `%\s` (the `errorformat` atom for whitespace) is
written `%\\s`, and why `makeprg=npx\ eslint` has no unescaped spaces.

## Test with `:Make`, not `:make`

These compilers are always run through vim-dispatch's `:Make`, and it does not
behave like built-in `:make`. Verifying against `:make` alone will pass and
then fail in real use:

- **No shell syntax in `makeprg`.** Dispatch builds its own command line rather
  than handing the string to a shell, so a pipe is dropped silently — no error,
  output simply arrives unfiltered. That is why colour-stripping for
  `astro check` lives in `bin/astro-check` and not in the option. (Built-in
  `:make` does honour a pipe, but only if written `\\\|`, so that the stored
  value keeps the `\|` that `:!` needs. Both facts together make a wrapper the
  only thing that works in both.)
- **`%-G` is not always honoured.** Dispatch tends to add unmatched lines to
  the quickfix list as invalid `||` entries instead of discarding them. Formats
  that emit one self-contained line per diagnostic — stylelint's `compact`,
  tsc — come out clean. Anything with banners or a summary needs filtering at
  the source, which is the other job `bin/astro-check` does.

`%-P`/`%-Q` do work under dispatch: ESLint's `stylish` output resolves its
filenames correctly.

## Checking the buffer you are looking at

Every one of these tools reads from **disk**. `require('functions').lint()`
therefore runs `:update` first, so an unsaved buffer isn't silently checked in
its last-written state — a false clean result that looks exactly like a broken
`errorformat`. Only the current buffer is written, as with `'autowrite'`; use
`:wall` when several are dirty.

## The atoms used here

| Atom     | Meaning                                                    |
| -------- | ---------------------------------------------------------- |
| `%f`     | file name                                                  |
| `%l`     | line number                                                |
| `%c`     | column number                                              |
| `%m`     | the error message                                          |
| `%t`     | error type, one character — `%trror` matches `error` and captures `e` |
| `%\s`    | whitespace (a Vim regex atom, written `%\\s`)              |
| `%#`     | `*` — zero or more of the preceding atom                   |
| `%.%#`   | `.*` — anything                                            |
| `%-G...` | ignore lines matching this entirely                        |
| `%-P%f`  | push a file name; following entries belong to it           |
| `%-Q`    | pop the pushed file name                                   |

`%-P`/`%-Q` are what make a "header, then indented rows" layout work — ESLint's
`stylish` prints the filename once and then rows that carry only line and
column, so the file has to be remembered across lines. Compact formats like
stylelint's put the path on every row and need none of this.

The `-` in `%-G`/`%-P`/`%-Q` means "don't add this line to the quickfix list".

## Testing a format

Capture real output first — guessing at a tool's format is how these break:

```
npx eslint --format stylish . > /tmp/out.txt 2>&1
nvim -c 'compiler eslint' -c 'cgetfile /tmp/out.txt' -c copen
```

Entries showing `|| text` in the quickfix window are unparsed. To see which
survived, check `valid`:

```
:lua print(vim.inspect(vim.fn.getqflist()))
```

A format is right when every real problem is `valid = 1` with the correct file,
line, column and type, and every banner or summary line is dropped.

## See also

- `:help errorformat`, `:help write-compiler-plugin`
- Compilers bundled with nvim: `$VIMRUNTIME/compiler/`
