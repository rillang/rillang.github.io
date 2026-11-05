# 14. Known limits

Rill is early. This is what you will miss today, so you do not have to find out the hard
way. Items marked **planned** have a spec or are on the roadmap.

## Platform

- arm64 only: macOS and Linux. No x86-64, no Windows. **Planned**: WebAssembly (WASI),
  then a browser playground.
- No releases or installers yet: build from source ([chapter 1](01-getting-started.md)).
  **Planned**: a toolchain version manager in `rill` and integration with tools like mise.

## Language

- Packages work (chapter 7); GPG signers are not supported yet (SSH keys are). The [standard library](15-standard-library.md) is a first version (no
  networking).
- Strings are bytes: no character type, no Unicode-aware string functions (`std/unicode`
  has the properties of single runes); a character literal is an `Int`.
- No string formatting beyond interpolation (widths, precision); no `replace`, `toUpper`.
- No optional chaining (`a?.b`), no closed ranges (`a...b`),
  no tuples.
- Arrays have no `pop`, `contains`, `reduce`, `reverse`; maps cannot remove keys and
  cannot be compared with `==`.
- `%` works on `Int` only. A unary minus applies after a UFCS call: `-1.shr(60)` is
  `-(1.shr(60))`.
- Errors carry only a message (`e.msg`); there are no error types to match on.
- A closure's result type cannot be written; it comes from the context or the body.
- No generic function as a value (`empty<Int>` without a call); one constraint per type
  parameter; no `Self` or
  default methods in interfaces.
- UFCS calls (`x.f()`) find functions in the current module only.
- `==` between an optional and a plain value works with the optional on the left
  (`opt == 3`) but not on the right (`3 == opt`).
- `let`, `var` and `for` bind names only (`for k, v in m` two of them); patterns appear
  only in `switch` cases.
- No `select` over channels, no timeouts, no sleep.
- Only `//` comments; `///` doc comments are a convention without tooling yet.

## Tooling

- No completion or rename in the language server (references and workspace symbols work).
- The debugger shows closures and interface values in their raw form, and optimized builds
  hide variables kept in registers.

The maintainers' own list, with context, is in
[docs/notes/2026-11-02-findings.md](https://github.com/rillang/rill/blob/main/docs/notes/2026-11-02-findings.md).
