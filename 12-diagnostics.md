# 12. Diagnostics

A compile error looks like this:

<!-- include: examples/nonexhaustive.err -->
```text
error[E0011]: switch must be exhaustive, missing: .add(_, _), .neg(_)
 --> docs/book/examples/nonexhaustive.err.rl:8:3
  |
8 |   switch e {
  |   ^
```

- `E0011` is the error's **code**. Codes are stable: never renumbered, never reused.
- The compiler reports several errors per run, not just the first.
- `--json` prints the same as JSON lines ([chapter 11](11-tooling.md#diagnostics-as-data)).

The full table of codes with a one-line example each is
**[docs/errors.md](../errors.md)**. Summary by area:

| Codes | Area |
|---|---|
| E0001–E0010 | names, syntax, types, labels, argument counts, constants, returns, duplicates |
| E0011, E0018, E0032–E0035 | `switch` and patterns |
| E0012–E0017 | recursive structs, inference, members, `?`, visibility, imports |
| E0019–E0022 | `guard`, misplaced statements, character literals, `inout` |
| E0023 | unsafe code outside `runtime/` |
| E0024–E0027 | concurrency rules (`group`/`spawn`, captures, `lock`, `Atomic`) |
| E0028–E0031 | generics and interfaces |

**Planned** (packages spec): codes E0036–E0042 and E0100–E0112 for modules, packages,
signatures and lints, plus warnings `W0001`–`W0005`.

Runtime errors are not diagnostics: a **panic** prints `panic: <message>` and
` --> file:line` to stderr and exits with code 101; an error returned from `main` prints
`error: <message>` and exits with code 1.

Next: [Built-in reference](13-builtins.md).
