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

## Profiling: `rill pprof`

Profiles use the format of Go's pprof, and `rill pprof` shows them with Go's reports (Go's
own `pprof` tool reads them too: `pprof -http=: cpu.pb` for a flame graph).

```rill
import "std/pprof"

fn main() -> Void! {
  pprof.startCPU("cpu.pb")?
  work()
  pprof.stopCPU() // optional: also written at exit, on a panic or a crash
  pprof.writeHeap("mem.pb")? // needs a sample rate: pprof.setMemProfileRate or RILL_MEMPROF
  pprof.writeTasks("tasks.pb")? // the stack of every task
}
```

```sh
$ RILL_CPUPROF=cpu.pb rill build compiler/main     # any program, no code changes
$ rill pprof -top -nodecount=3 cpu.pb
Type: cpu
Duration: 797.43ms, Total samples = 820ms (102.83%)
Showing nodes accounting for 580ms, 70.73% of 820ms total
Showing top 3 nodes out of 179
      flat  flat%   sum%        cum   cum%
     280ms 34.15% 34.15%      280ms 34.15%  rl_memcpy
     160ms 19.51% 53.66%      170ms 20.73%  rl_rt_gc_scanRange
     140ms 17.07% 70.73%      140ms 17.07%  rl_zero
$ rill test --cpuprofile cpu.pb --memprofile mem.pb ./lexer
$ rill pprof mem.pb       # on a terminal: top, list <regexp>, peek <regexp>, traces, help
```

- CPU profiles sample 100 times a second on every thread, runtime functions included
  (`rl_rt_gc_*` is the collector).
- Heap profiles sample one allocation per 512 KiB on average (`RILL_MEMPROFRATE`,
  `--memprofilerate`, `setMemProfileRate`; `1` records every allocation) and hold
  `inuse_space` (the default), `inuse_objects`, `alloc_space` and `alloc_objects`
  (`-sample_index=`).
- `-list <regexp>` shows the source with values per line, `-peek <regexp>` callers and
  callees, `-traces` every sample.
- Details and limits: [docs/profiling.md](https://github.com/rillang/rill/blob/main/docs/profiling.md).

## Inspecting the compiler

`--dump-tokens`, `--dump-ast`, `--dump-ir`, `--dump-opt` and `--dump-asm` print the
intermediate forms ([dump formats](https://github.com/rillang/rill/blob/main/docs/dump-format.md), [IR](https://github.com/rillang/rill/blob/main/docs/ir.md)) and exit.

## Planned tooling

From the [roadmap](https://github.com/rillang/rill/blob/main/docs/ROADMAP.md): `rill doc`
(rendering `///` comments, with doctests), `--json` for every command, `rill mcp`, an
interactive `rill tour`, a toolchain version manager, a WebAssembly target and a browser
playground. Packages, updates and audits are in [chapter 7](07-modules.md).

Next: [Diagnostics](12-diagnostics.md).
