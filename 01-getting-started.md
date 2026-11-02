# 1. Getting started

## What you need

An **arm64** machine running macOS or Linux. Nothing else: no C compiler, assembler,
linker or package manager. The `rill` binary contains the compiler, the runtime sources,
the formatter, the language server and the test runner, and it writes Mach-O (macOS,
signed) and static ELF (Linux) executables itself.

x86-64 is not supported. Windows is not supported.

## Build from source

There are no releases yet; build from the repository:

```sh
git clone <repository> rill
cd rill
sh bootstrap.sh
```

`bootstrap.sh` takes the checked-in seed compiler (`bootstrap/rill-<os>-arm64`, a previous
build of Rill), builds the compiler in `compiler/` with it, then builds the compiler with
itself twice and checks that the last two builds are byte-identical (the *fixpoint*). It
also runs the module tests and the golden test suite. The result is `out/rill`. Put it on
your `PATH` or call it by path:

```sh
export PATH="$PWD/out:$PATH"
```

## Hello, world

<!-- include: examples/hello.rl -->
```swift
fn main() {
  let name = "Rill"
  print("Hello, $name!")
}
```

```sh
rill run hello.rl
```

<!-- include: examples/hello.out -->
```text
Hello, Rill!
```

`rill run` compiles the file to `~/.cache/rill/run/` and runs it; arguments after the
file name go to the program. A program starts at `fn main()`. (Two `rill run`s of files
with the same name at the same time share that path; use `rill build -o` for parallel
scripts.)

## The `rill` command

| Command | What it does |
|---|---|
| `rill run <file.rl> [args...]` | compile and run |
| `rill build <file.rl> [-o <out>]` | compile to an executable (default name: the file without `.rl`) |
| `rill test <file.rl>` | run the file's `test` blocks ([chapter 8](08-testing.md)) |
| `rill fmt <file.rl>...` | format in place; `--check` lists unformatted files, `--stdout` prints |
| `rill lsp` | language server on stdin/stdout; `--check <files>` prints what an editor would show |
| `rill debug <file.rl> [args...]` | build without optimization and start lldb with Rill formatters |

Options:

| Option | Meaning |
|---|---|
| `--target=macos-arm64` / `--target=linux-arm64` | cross-compile (default: the host) |
| `--json` | diagnostics as JSON lines |
| `--opt=0` | no optimization |
| `--strip` | no debug information |
| `--dump-tokens`, `--dump-ast`, `--dump-ir`, `--dump-opt`, `--dump-asm` | print an intermediate form and exit |

Cross-compiling needs nothing extra: `rill build app.rl --target=linux-arm64 -o app` on a
Mac produces a static Linux binary.

## How fast is it?

Measured on an Apple M4 (2026-11-02, single runs, `rill` built by `bootstrap.sh`):

| Task | Time |
|---|---|
| `rill build hello.rl` | 0.22 s, 623 KB executable (runtime and debug info included) |
| the compiler building itself (~19 000 lines of Rill plus the 4 500-line runtime) | 2.1 s |

The history of these numbers, and what the collector costs, is in
[`docs/perf.md`](../perf.md). No comparisons with other languages have been measured.

## Runtime settings

Environment variables tune a compiled program; the defaults need no tuning.

| Variable | Meaning |
|---|---|
| `RILL_GC` | heap growth between collections in percent (default `100`), `off`, or `stress[:N]` |
| `RILL_WORKERS` | threads that run tasks (default: number of cores) |
| `RILL_STACK` | stack size per task in bytes (default 1 MiB) |
| `RILL_BACKTRACE` | `1`: a panic prints the call chain |

Next: [Basics](02-basics.md).
