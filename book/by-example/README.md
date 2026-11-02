# Rill by Example

Short, runnable programs, one topic each. Every program is in [`examples/`](examples/) with
its expected output and is checked by `sh docs/book/check.sh`. For explanations, read
[the book](../README.md).

Run any of them with `rill run docs/book/by-example/examples/<name>.rl`.

## Basics

- [Hello world](hello-world.md)
- [Values](values.md)
- [Variables](variables.md)
- [If and else](if-else.md)
- [Loops](loops.md)
- [Switch](switch.md)

## Functions

- [Functions](functions.md)
- [Argument labels](labels.md)
- [Closures](closures.md)
- [UFCS](ufcs.md)
- [inout parameters](inout.md)

## Collections

- [Arrays](arrays.md)
- [Maps](maps.md)
- [Strings](strings.md)
- [StringBuilder](string-builder.md)

## Types

- [Structs](structs.md)
- [Enums](enums.md)
- [Generics](generics.md)
- [Interfaces](interfaces.md)

## Errors

- [Optionals](optionals.md)
- [Results and errors](errors.md)
- [Panics](panic.md)

## Pattern matching

- [if case and guard case](if-case.md)
- [Destructuring](destructuring.md)
- [Functions made of cases](case-functions.md)

## Programs

- [Modules](modules.md)
- [Tests](tests.md)
- [Command-line arguments](args.md)
- [Files](files.md)
- [Processes and environment](processes.md)

## Concurrency

- [group and spawn](group-spawn.md)
- [Channels](channels.md)
- [parMap](parmap.md)
- [Mutex](mutex.md)
- [Atomic](atomic.md)
