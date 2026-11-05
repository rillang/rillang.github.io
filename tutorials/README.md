# Rill tutorials

Small, real programs built step by step. Each tutorial is a page plus a directory with the
finished code; every command and its output on the pages is replayed and compared by
[`check.sh`](check.sh).

| Tutorial | You build | You use |
|---|---|---|
| [1. A command-line tool](01-cli-tool.md) | `wc`: lines, words, bytes of files | `std/os`, `std/fs`, `std/fmt`, `T!` and `?`, `test` blocks, `rill build`, warnings, `rill fmt` |
| [2. Concurrency](02-concurrency.md) | `hashtree`: SHA-256 of a directory tree on all cores | `fs.walk`, `std/hash/sha256`, `parMap`, `group`/`spawn`, `Channel`, `Mutex`, `std/time` |
| [3. A JSON configuration](03-json-config.md) | `cfg`: load, default and validate a config | `std/json`, pattern matching over `Json`, `inout`, `switch` values |
| [4. Packages](04-packages.md) | a library on (local) Git and an app using it | `rill mod init`, `rill get`, `rill.sum`, `internal/`, `rill api`, `rill release`, `/// deprecated:`, `rill fix` |
| [5. Scripts](05-scripts.md) | `todo`, `tidy`, `tasks`: chores as `#!/usr/bin/env rill` scripts | `fs.walk`, `fs.rename`, `std/json`, `os.run`, `std/time`, kept `rill run` binaries |

They build on each other a little, but each one stands alone. The [Rill Book](../book/README.md)
is the reference for everything they touch.

## Prerequisites

- An arm64 Mac (macOS) or arm64 Linux machine.
- The compiler, built from this repository (no C toolchain needed):

  ```sh
  sh bootstrap.sh                   # builds out/rill
  export PATH="$PWD/out:$PATH"      # so that `rill` works in any directory
  ```

- Tutorial 4 also needs `git`.

## Running a tutorial

Each page says which directory it works in; run its commands from there:

```sh
cd tutorials/cli-tool
rill run wc1.rl testdata/fox.txt
```

Tutorial 4 creates projects in your home directory; the page shows how to use a throw-away
`HOME` for it.

## How the tutorials are checked

```sh
sh tutorials/check.sh          # replay every tutorial, compare the transcripts
UPDATE=1 sh tutorials/check.sh # re-record the transcripts (review the diff!)
sh tutorials/sync.sh           # copy changed files and transcripts into the pages
```

`check.sh` copies each tutorial directory to a scratch directory, runs the commands listed
in it with `rill` on `PATH` and `HOME` pointing into the scratch directory, and compares
command, output and exit code with `<tutorial>/sessions/*.txt`. Durations are replaced by
`<time>`. Then it checks that every tutorial source is formatted (`rill fmt --check`), has
no diagnostics or warnings (`rill lsp --check`; deliberately broken inputs are named
`*.warn.rl` and `*.fmt.rl`), and that the pages show the current files (`sync.sh --check`).
