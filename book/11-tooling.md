# 11. Tooling

Everything is in the one `rill` binary.

## Formatter: `rill fmt`

```sh
rill fmt app.rl lib/*.rl      # format in place
rill fmt --check *.rl         # list files that are not formatted (exit 1 if any)
rill fmt --stdout app.rl      # print the formatted file
```

One style, no options: two-space indentation, canonical spacing around operators, braces
and commas, gofmt-like. It does not re-break long lines or align columns. The repository
(and every example in this book) is checked with `--check`.

## Language server: `rill lsp`

`rill lsp` speaks the Language Server Protocol on stdin/stdout: diagnostics, hover, go to
definition, formatting and document symbols. Columns are byte offsets (exact for ASCII).

Helix (`languages.toml`):

```toml
[[language]]
name = "rill"
scope = "source.rill"
file-types = ["rl"]
language-servers = ["rill-lsp"]

[language-server.rill-lsp]
command = "rill"
args = ["lsp"]
```

Neovim: `vim.lsp.start({ name = "rill", cmd = { "rill", "lsp" } })` in a `FileType rl`
autocommand.

`rill lsp --check a.rl b.rl` prints the diagnostics an editor would show and exits with 1
if there are any; useful in scripts and CI.

Not yet: completion, rename, find references.

## Diagnostics as data

Every compile error has a stable code ([chapter 12](12-diagnostics.md)). `--json` prints one
JSON object per line instead of the human format:

```sh
rill build --json app.rl
```

```json
{"code":"E0013","message":"cannot infer closure parameter types","file":"app.rl","line":2,"col":11}
```

This is meant for editors, scripts and AI agents fixing code in a loop.

## Debugger: `rill debug`

Executables carry a symbol table and DWARF line tables, so lldb, gdb, `sample`,
Instruments and `perf` show function names (`rl_<module>_<function>`) with `file:line`.

`rill debug app.rl [args]` builds without optimization and starts lldb with Rill's data
formatters loaded:

```
(lldb) b app.rl:33
(lldb) run
(lldb) frame variable
(Path) path = {
  name = "trip"
  points = len=2 {
    [0] = {
      x = 1
      y = 2
    }
    ...
(lldb) p path.points[1].y
```

Strings, arrays, maps, optionals, results, enum cases, structs, generic instances and
`inout` parameters are shown as values. With plain lldb, load the formatters with
`command script import tools/lldb/rill_lldb.py` and let the scheduler's signal through:
`process handle SIGURG -n false -p true -s false` (gdb: `handle SIGURG nostop noprint`).

Optimized builds keep line breakpoints and stepping, but variables that live in registers
are not shown. Closures and interface values show their raw representation.

## Inspecting the compiler

`--dump-tokens`, `--dump-ast`, `--dump-ir`, `--dump-opt` and `--dump-asm` print the
intermediate forms ([dump formats](https://github.com/rillang/rill/blob/main/docs/dump-format.md), [IR](https://github.com/rillang/rill/blob/main/docs/ir.md)) and exit.

## Planned tooling

From the [packages spec](https://github.com/rillang/rill/blob/main/docs/specs/2026-11-02-rill-packages-stdlib-design.md) and the
[roadmap notes](https://github.com/rillang/rill/blob/main/docs/notes/2026-11-02-findings.md): `rill doc` (rendering `///` comments),
warnings with `--deny-warnings`, `rill fix` (automatic migrations), `rill api`,
`rill release`, `rill get` / `rill mod …`, `rill update`, an interactive `rill tour`, a
toolchain version manager, a WebAssembly target and a browser playground.

Next: [Diagnostics](12-diagnostics.md).
