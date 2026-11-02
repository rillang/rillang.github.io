# 13. Built-in reference

Everything below is built into the compiler today (from `builtinCall` in
`compiler/check.rl`). Functions marked *moves* are planned to move into the standard
library (`std/fs`, `std/os`) by the [packages spec](../specs/2026-11-02-rill-packages-stdlib-design.md).

## Global functions

| Function | Type | Notes |
|---|---|---|
| `print(s)` | `(String) -> Void` | line to stdout (whole lines are atomic across tasks) |
| `eprint(s)` | `(String) -> Void` | line to stderr |
| `str(x)` | `(Int \| Float \| Bool \| String) -> String` | |
| `Int(x)` | `(Float) -> Int` | truncates |
| `Float(n)` | `(Int) -> Float` | |
| `fail(msg)` | `(String) -> Error` | used as `return fail("…")` in a `T!` function |
| `panic(msg)` | `(String) -> Void` | exit 101 |
| `exit(code)` | `(Int) -> Void` | |
| `expect(cond)` | `(Bool) -> Void` | only in `test` blocks |
| `args()` | `() -> [String]` | program arguments, without the program name; *moves* to `std/os` |
| `env(name)` | `(String) -> String?` | *moves* to `std/os` |
| `readFile(path)` | `(String) -> String!` | *moves* to `std/fs` |
| `writeFile(path, s)` | `(String, String) -> Void!` | *moves* to `std/fs` |
| `fileExists(path)` | `(String) -> Bool` | *moves* to `std/fs` as `exists` |
| `mkdirAll(path)` | `(String) -> Void!` | *moves* to `std/fs` |
| `readDir(path)` | `(String) -> [String]!` | sorted names; *moves* to `std/fs` |
| `run(argv)` | `([String]) -> Int!` | runs a program, returns its exit code; *moves* to `std/os` |
| `runCapture(argv)` | `([String]) -> String!` | runs a program, returns its stdout; error on non-zero exit; *moves* to `std/os` |
| `readStdin(n)` | `(Int) -> String` | up to `n` bytes from stdin |
| `writeStdout(s)` | `(String) -> Void` | without a newline |
| `makeExecutable(path)` | `(String) -> Void!` | |

## Constructors

| Expression | Type |
|---|---|
| `StringBuilder()` | `StringBuilder` |
| `Map<K, V>()`, `[:]` | `Map<K, V>` |
| `Channel<T>(capacity: n)` | `Channel<T>` |
| `Mutex(x)`, `Mutex<T>(x)` | `Mutex<T>` |
| `Atomic(0)`, `Atomic(false)`, `Atomic<Int>(n)` | `Atomic<Int>` / `Atomic<Bool>` |

## Methods (called with UFCS)

| On | Functions |
|---|---|
| `Int` | `and`, `or`, `xor`, `shl`, `shr` (logical), `sar` (arithmetic), `wrapAdd`, `wrapSub`, `wrapMul` |
| `String` | `len() -> Int` (bytes), `slice(from, to) -> String`, `byteAt(i) -> Int`, `split(sep) -> [String]`, `lines() -> [String]`, `trim() -> String`, `startsWith(s) -> Bool`, `contains(s) -> Bool`, `toInt() -> Int?`, `toFloat() -> Float?` |
| `[T]` | `len()`, `push(x)` (needs a `var`), `slice(from, to)`, `map { … } -> [U]`, `filter { … } -> [T]`, `sortBy { a, b in … } -> [T]` (`true` if `a` comes first), `parMap { … } -> [U]`, `join(sep)` (only `[String]`) |
| `Map<K, V>` | `len()`, `has(k)`, `keys() -> [K]`; `m[k] -> V?`, `m[k] = v` |
| `StringBuilder` | `add(s)`, `addInt(n)`, `addByte(b)`, `len()`, `build() -> String` |
| `Channel<T>` | `send(x)`, `recv() -> T?`, `close()` |
| `Mutex<T>` | `lock { v in … }`, `get() -> T` |
| `Atomic<T>` | `load()`, `store(x)`, `compareSwap(old, new) -> Bool`, `add(n) -> Int` (Int only, returns the new value) |

## Operators

| Operators | Types |
|---|---|
| `+ - * /` | `Int`, `Float`; `+` also concatenates `String`s |
| `%` | `Int` |
| `== !=` | `Int`, `Float`, `Bool`, `String`, and structs, enums, arrays and optionals of comparable types (structural); not maps, interface values or functions |
| `< <= > >=` | `Int`, `Float`, `String` |
| `&& \|\| !` | `Bool` |
| `??` | optionals and results |
| `+= -= *=` | compound assignment |
| `a..<b` | half-open range (in `for` and in patterns) |

Next: [Known limits](14-limits.md).
