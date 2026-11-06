# 13. Built-in reference

Everything below is built into the compiler (from `builtinCall` in
`compiler/check/check.rl`). Files, processes and the environment live in the
[standard library](15-standard-library.md) (`std/fs`, `std/os`); using one of the former
global names (`readFile`, `args`, …) is error E0039, which names the replacement.

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
| `expect(cond)` | `(Bool) -> Void` | only in `test` blocks |

## Constructors

| Expression | Type |
|---|---|
| `StringBuilder()` | `StringBuilder` |
| `Bytes(n)`, `Bytes()`, `Bytes([1, 2])` | `Bytes` |
| `[T](repeating: x, count: n)` | `[T]` (n copies, allocated at once) |
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
| `Char` | one Unicode scalar; `Int(c)` its code point, `Char(i) -> Char?`; `charAt(i)` and `charCount()` on a `String` |
| `Bytes` | `len()`, `push(b)`, `slice(from, to)`, `b[i]` (0–255), `for x in b`, `==`; `s.bytes() -> Bytes`, `String(b: b)` (no check), `String(utf8: b) -> String!` |
| `StringBuilder` | `add(s)`, `addInt(n)`, `addByte(b)`, `addChar(c)`, `len()`, `build() -> String` |
| `Channel<T>` | `send(x)`, `recv() -> T?`, `close()` |
| `Mutex<T>` | `lock { v in … }`, `get() -> T` |
| `Atomic<T>` | `load()`, `store(x)`, `compareSwap(old, new) -> Bool`, `add(n) -> Int` (Int only, returns the new value) |

## Operators

| Operators | Types |
|---|---|
| `+ - * /` | `Int`, `Float`; `+` also concatenates `String`s |
| `%` | `Int` |
| `== !=` | `Int`, `Float`, `Bool`, `String`, and structs, enums, arrays, maps and optionals of comparable types (structural; maps: same keys with equal values, in any order); not interface values or functions |
| `< <= > >=` | `Int`, `Float`, `String` |
| `&& \|\| !` | `Bool` |
| `??` | optionals and results |
| `+= -= *=` | compound assignment |
| `a..<b` | half-open range (in `for` and in patterns) |

Next: [Known limits](14-limits.md).
