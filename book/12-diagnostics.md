# 12. Diagnostics

A compile error looks like this:

<!-- include: examples/nonexhaustive.err -->
```text
error[E0011]: switch must be exhaustive, missing: .add(_, _), .neg(_)
 --> book/examples/nonexhaustive.err.rl:8:3
  |
8 |   switch e {
  |   ^
```

- `E0011` is the error's **code**. Codes are stable: never renumbered, never reused.
- The compiler reports several errors per run, not just the first.
- `--json` prints the same as JSON lines ([chapter 11](11-tooling.md#diagnostics-as-data)).

The full table of codes with a one-line example each is
**[docs/errors.md](https://github.com/rillang/rill/blob/main/docs/errors.md)**. Summary by area:

| Codes | Area |
|---|---|
| E0001–E0010 | names, syntax, types, labels, argument counts, constants, returns, duplicates |
| E0011, E0018, E0032–E0035 | `switch` and patterns |
| E0012–E0017 | recursive structs, inference, members, `?`, visibility, imports |
| E0019–E0022 | `guard`, misplaced statements, character literals, `inout` |
| E0023 | unsafe code outside `runtime/` |
| E0024–E0027 | concurrency rules (`group`/`spawn`, captures, `lock`, `Atomic`) |
| E0028–E0031 | generics and interfaces |

| E0036–E0039 | imports (`as`, paths, `internal/`) and moved builtins |
| E0040, E0041 | a dropped `T!` result; naming conventions (types UpperCamelCase, the rest lowerCamelCase) |
| E0100–E0109 | packages: `rill.mod`, downloads, hashes, tags, signatures, `vendor/` |

## Warnings

Warnings do not stop a build: unused imports (`W0002`), unused locals and parameters
(`W0003`, name them `_x` if intended), a `var` that is never changed (`W0004`), unreachable
code (`W0005`), use of a deprecated declaration (`W0001`). When there are errors, only the
errors are shown.

- `--deny-warnings` turns warnings into errors (for CI).
- `/// allow: W0003` above a declaration silences that warning inside it.
- The language server shows warnings with warning severity; warnings in the standard
  library and in packages are never shown.

Runtime errors are not diagnostics: a **panic** prints `panic: <message>` and
` --> file:line` to stderr and exits with code 101; an error returned from `main` prints
`error: <message>` and exits with code 1.

Next: [Built-in reference](13-builtins.md).
