# 14. Known limits

Rill is early. This is what you will miss today, so you do not have to find out the hard
way. Items marked **planned** have a spec or are on the roadmap.

## Platform

- arm64 only: macOS and Linux. No x86-64, no Windows. **Planned**: WebAssembly (WASI),
  then a browser playground.
- No releases or installers yet: build from source ([chapter 1](01-getting-started.md)).
  **Planned**: a toolchain version manager in `rill` and integration with tools like mise.

## Language

- No standard library beyond the [builtins](13-builtins.md) and no packages. **Planned**
  next ([spec](../specs/2026-11-02-rill-packages-stdlib-design.md)).
- Strings are bytes: no character type, no Unicode-aware functions; a character literal is
  an `Int`.
- No string formatting beyond interpolation (widths, precision); no `replace`, `toUpper`.
- No optional chaining (`a?.b`), no `if`/`switch` expressions, no closed ranges (`a...b`),
  no tuples.
- Arrays have no `pop`, `contains`, `reduce`, `reverse`; maps cannot remove keys and
  cannot be compared with `==`.
- `%` works on `Int` only. A unary minus applies after a UFCS call: `-1.shr(60)` is
  `-(1.shr(60))`.
- Errors carry only a message (`e.msg`); there are no error types to match on.
- Closure parameters cannot be annotated; a closure needs a typed context.
- No explicit type arguments on calls; one constraint per type parameter; no `Self` or
  default methods in interfaces.
- UFCS calls (`x.f()`) find functions in the current module only.
- `==` between an optional and a plain value works with the optional on the left
  (`opt == 3`) but not on the right (`3 == opt`).
- `for k, v in m` takes only irrefutable patterns; there is no `for case` over maps.
- No `select` over channels, no timeouts, no sleep.
- Only `//` comments; `///` doc comments are a convention without tooling yet.

## Tooling

- No completion, rename or references in the language server.
- The debugger shows closures and interface values in their raw form, and optimized builds
  hide variables kept in registers.
- No warnings yet (**planned**: `W0001`–`W0005`).

The maintainers' own list, with context, is in
[docs/notes/2026-11-02-findings.md](../notes/2026-11-02-findings.md).
