# The Rill Book

An introduction to Rill as it exists today: an experimental, self-hosted language that
compiles to native arm64 executables for macOS and Linux.

Rill is early. Everything in this book runs with the compiler in this repository; things
that are designed but not built yet are marked **planned** and link to their spec.

## Contents

1. [Getting started](01-getting-started.md): build from source, `rill run/build/test/fmt/lsp/debug`
2. [Basics](02-basics.md): values, types, control flow, functions and labels, closures, UFCS, collections, strings
3. [Structs and enums](03-structs-and-enums.md)
4. [Optionals and results](04-optionals-and-results.md): `T?`, `T!`, `?`, `??`, `if let`, `guard`
5. [Pattern matching](05-pattern-matching.md)
6. [Generics and interfaces](06-generics-and-interfaces.md)
7. [Modules](07-modules.md) (and the planned packages)
8. [Testing](08-testing.md)
9. [Concurrency](09-concurrency.md): `group`/`spawn`, channels, `parMap`, `Mutex`, `Atomic`
10. [Memory](10-memory.md): value semantics and the garbage collector
11. [Tooling](11-tooling.md): formatter, language server, debugger, diagnostics as JSON
12. [Diagnostics](12-diagnostics.md): error codes
13. [Built-in reference](13-builtins.md): every builtin function and method
14. [Known limits](14-limits.md): what is missing today
15. [The standard library](15-standard-library.md)

Also: **[Rill by Example](by-example/README.md)**, short runnable programs, one topic each.

And: **[Tutorials](../tutorials/README.md)**, small real programs built step by step.

## The examples are checked

Every program in this book lives in [`examples/`](examples) (and
[`by-example/examples/`](by-example/examples)) next to its expected output. The pages show
copies of those files.

```sh
sh book/check.sh       # run every example, compare output, fmt and lsp checks
sh book/sync.sh        # copy changed examples into the pages
```

`check.sh` uses the same file conventions as the golden tests: `name.rl` + `name.out`,
`name.test.rl` (run with `rill test`), `name.panic.rl` / `name.fail.rl` + `name.err` (exit 101
/ exit 1), `name.err.rl` + `name.err` (a compile error). To change an example, edit the
`.rl` file, run `UPDATE=1 sh book/check.sh`, review the new expected output, then run
`sync.sh`.
