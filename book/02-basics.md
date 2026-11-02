# 2. Basics

## Values and types

<!-- include: examples/values.rl -->
```swift
fn main() {
  // let binds a constant, var a variable
  let answer = 42
  var count = 0
  count += 1

  // the basic types: Int (64-bit), Float (64-bit), Bool, String
  let pi: Float = 3.14159
  let ready: Bool = answer > 40 && count == 1
  let greeting: String = "hi"

  // interpolation: $name or ${expression}
  print("$greeting: answer=$answer, count=$count, ready=$ready")
  print("pi doubled is ${pi * 2.0}")

  // integer division truncates, % is the remainder
  print("${7 / 2} ${7 % 2} ${7.0 / 2.0}")

  // no implicit conversions between Int and Float
  let n = 3
  let half = Float(n) / 2.0
  print("${half} ${Int(2.9)} ${str(n)}")

  // literals: hex, digit separators, characters (which are Ints)
  print("${0xff} ${1_000_000} ${'A'}")

  // strings are immutable UTF-8 bytes
  let word = "naïve"
  print("${word.len()} bytes")
}
```

<!-- include: examples/values.out -->
```text
hi: answer=42, count=1, ready=true
pi doubled is 6.28318
3 1 3.5
1.5 2 3
255 1000000 65
6 bytes
```

- `let` binds a constant, `var` a variable. Assigning to a `let` is error E0006.
- Types are inferred inside a function body. Function parameters and results are always
  written out.
- `Int` is a 64-bit signed integer. Overflow and division by zero **panic** (they are bugs,
  not wrapping arithmetic). `x.wrapAdd(y)`, `wrapSub`, `wrapMul` wrap on purpose; bit
  operations are functions: `and`, `or`, `xor`, `shl`, `shr`, `sar`.
- `Float` is a 64-bit IEEE double. `Float(n)` and `Int(x)` convert (`Int` truncates);
  nothing converts implicitly.
- `Bool` has `true`, `false`, `&&`, `||`, `!`.
- `String` is an immutable sequence of UTF-8 bytes. `len()` counts bytes. There is no
  character type: a character literal like `'A'` is an `Int` (its byte value) and only
  ASCII characters are allowed in it.
- Interpolation: `"$name"` or `"${expression}"`; `\$` is a literal dollar sign.
- `str(x)` turns an `Int`, `Float`, `Bool` or `String` into a `String`.
- Comments are `//` to the end of the line. There are no block comments.

## Control flow

<!-- include: examples/control.rl -->
```swift
fn classify(_ n: Int) -> String {
  if n < 0 {
    return "negative"
  } else if n == 0 {
    return "zero"
  }
  return "positive"
}

fn firstWord(_ line: String) -> String {
  // guard: the else block must leave the function
  guard line.len() > 0 else {
    return "(empty)"
  }
  return line.split(" ")[0]
}

fn main() {
  print("${classify(-5)} ${classify(0)} ${classify(9)}")
  print("${firstWord("hello world")} ${firstWord("")}")

  // ranges are half-open: 0, 1, 2, 3, 4
  var sum = 0
  for i in 0..<5 {
    if i == 3 {
      continue
    }
    sum += i
  }
  print("sum $sum")

  var n = 27
  var steps = 0
  while n != 1 {
    if n % 2 == 0 {
      n = n / 2
    } else {
      n = 3 * n + 1
    }
    steps += 1
    if steps > 1000 {
      break
    }
  }
  print("collatz steps $steps")

  for name in ["ana", "bo"] {
    print(name)
  }
}
```

<!-- include: examples/control.out -->
```text
negative zero positive
hello (empty)
sum 7
collatz steps 111
ana
bo
```

- `if` / `else if` / `else` are statements (not expressions); conditions must be `Bool`.
- `guard condition else { … }` checks a precondition. The `else` block must leave the
  scope (`return`, `break`, `continue`, `panic`, `exit`), otherwise error E0019. Bindings made
  by `guard let` and `guard case` stay visible after the guard.
- `for x in xs` iterates an array, `for i in a..<b` a half-open range, `for k, v in m` a map
  (in insertion order), `for x in ch` a channel until it is closed. `while` loops while a
  condition holds. `break` and `continue` apply to the innermost loop.
- `switch` is covered in [chapter 5](05-pattern-matching.md).
- A block `{ … }` on its own opens a scope.

## Functions and argument labels

<!-- include: examples/functions.rl -->
```swift
// An expression body: `= expr`
fn square(_ x: Int) -> Int = x * x

// Argument labels: `_` means none, otherwise the label is part of the call
fn move(_ x: Int, by delta: Int) -> Int = x + delta

fn area(width: Int, height: Int) -> Int {
  return width * height
}

// A function without `-> T` returns nothing (Void)
fn greet(_ name: String) {
  print("hello $name")
}

// inout: the callee changes the caller's variable; the call site says so with &
fn bump(_ n: inout Int) {
  n += 1
}

fn main() {
  print("${square(7)}")
  print("${move(1, by: 2)}")
  print("${area(width: 3, height: 4)}")
  greet("Rill")
  var x = 10
  bump(&x)
  bump(&x)
  print("$x")
}
```

<!-- include: examples/functions.out -->
```text
49
3
12
hello Rill
12
```

Each parameter has a **label** (what the caller writes) and a **name** (what the body
uses): `by delta: Int` is called as `move(1, by: 2)`. `_` means the argument has no label.
Without a separate label (`width: Int`), the name is also the label. Labels are part of the
call: a wrong or missing label is error E0004.

`fn f() -> T = expression` is a function whose body is one expression.

Parameters are read-only values. An `inout` parameter writes back to the caller's
variable; the call marks it with `&` (`bump(&x)`, `bump(&xs[0])`). This is the only way a
function changes a value it did not create (see [chapter 10](10-memory.md)).

Functions can share a name when their first unlabeled parameters have different types
(`fn area(_ c: Circle)` and `fn area(_ s: Square)`). The call picks the function by the
type of its first argument. This exists so types can implement interfaces
([chapter 6](06-generics-and-interfaces.md)); there is no other overloading.

## Closures

<!-- include: examples/closures.rl -->
```swift
fn apply(_ f: (Int) -> Int, _ x: Int) -> Int = f(x)

fn makeAdder(_ n: Int) -> (Int) -> Int {
  return { x in x + n }
}

fn triple(_ x: Int) -> Int = x * 3

fn main() {
  // a closure: { params in body }
  print("${apply({ x in x * 2 }, 5)}")

  // functions are values too
  print("${apply(triple, 5)}")

  // a trailing closure follows the call; `$` names a single parameter
  let xs = [1, 2, 3, 4]
  let big = xs.map { $ * 10 }.filter { $ > 15 }
  print(big.map { "${$}" }.join(", "))

  // two parameters
  let byLength = ["ccc", "a", "bb"].sortBy { a, b in a.len() < b.len() }
  print(byLength.join(" "))

  // closures capture values when they are created
  var base = 1
  let addBase: (Int) -> Int = { x in x + base }
  base = 100
  print("${addBase(1)} ${makeAdder(base)(1)}")

  // a closure stored in a variable needs a type
  let isEven: (Int) -> Bool = { n in n % 2 == 0 }
  print("${isEven(4)} ${isEven(7)}")
}
```

<!-- include: examples/closures.out -->
```text
10
15
20, 30, 40
a bb ccc
2 101
true false
```

- A closure is `{ params in body }`; `{ $ * 2 }` uses `$` for a single parameter.
- A closure written after a call's parentheses (or instead of them) is a *trailing
  closure*: `xs.map { $ + 1 }`.
- Closure parameter types come from the context: the parameter type of the function
  being called, or an annotation like `let f: (Int) -> Int = { x in x + 1 }`.
  `let f = { x in x + 1 }` is error E0013.
- Closures **capture by value**, at the moment they are created. Assigning to a captured
  variable is error E0006.
- Function types are written `(Int, String) -> Bool`; a named function is a value of such
  a type.
- In a string inside a closure, write `${$}` for the parameter: `"$"` is just a dollar sign.

## UFCS: there are no methods

Rill has functions only. `x.f(y)` is another way to write `f(x, y)` (Uniform Function Call
Syntax): the value before the dot becomes the first argument.

<!-- include: examples/ufcs.rl -->
```swift
struct Point { x: Int, y: Int }

fn scale(_ p: Point, by f: Int) -> Point = Point(x: p.x * f, y: p.y * f)

fn sum(_ p: Point) -> Int = p.x + p.y

fn double(_ n: Int) -> Int = n * 2

fn main() {
  let p = Point(x: 1, y: 2)
  // x.f(args) calls f(x, args): there are no methods, only functions
  print("${sum(scale(p, by: 10))}")
  print("${p.scale(by: 10).sum()}")
  print("${3.double().double()}")
}
```

<!-- include: examples/ufcs.out -->
```text
30
30
12
```

If `x` has a field of function type named `f`, `x.f(y)` calls that field instead.
`x.f()` finds `f` in the current module only; a function from another module is called as
`module.f(x)` (see [chapter 7](07-modules.md)).

## Arrays, maps and StringBuilder

<!-- include: examples/collections.rl -->
```swift
fn main() {
  // arrays: [T]
  var xs = [3, 1, 2]
  xs.push(5)
  xs[0] = 4
  print("${xs.len()} ${xs[0]} ${xs.slice(1, 3).len()}")
  let sorted = xs.sortBy { a, b in a < b }
  print(sorted.map { "${$}" }.join(" "))
  let empty: [String] = []
  print("${empty.len()}")

  // maps: Map<K, V>, keys are Int or String, iteration in insertion order
  var ages = ["ana": 33, "bo": 41]
  ages["cy"] = 25
  print("${ages.len()} ${ages.has("bo")} ${ages["zed"] ?? 0}")
  for name, age in ages {
    print("$name is $age")
  }
  print(ages.keys().join(","))
  var counts = Map<String, Int>()
  for w in "a b a c a".split(" ") {
    counts[w] = (counts[w] ?? 0) + 1
  }
  print("a=${counts["a"] ?? 0}")

  // StringBuilder builds strings without copying
  var sb = StringBuilder()
  for i in 0..<3 {
    sb.add("#")
    sb.addInt(i)
  }
  print(sb.build())
}
```

<!-- include: examples/collections.out -->
```text
4 4 2
1 2 4 5
0
3 true 0
ana is 33
bo is 41
cy is 25
ana,bo,cy
a=3
#0#1#2
```

- `[T]` is an array: `len`, `push`, `slice(from, to)`, `map`, `filter`, `sortBy`,
  `parMap`, and `join(separator)` for `[String]`. Indexing out of bounds panics.
- `Map<K, V>` is a hash map with `Int` or `String` keys, iterated in insertion order:
  `m[k]` returns `V?`, `m[k] = v` inserts or replaces, `has`, `keys`, `len`. A map literal is
  `["a": 1]`; the empty map is `[:]` or `Map<String, Int>()`.
- An empty array literal needs a type: `let xs: [Int] = []`.
- Arrays and maps are **values**: assigning one copies it (lazily, on the first write).
- `StringBuilder()` collects pieces (`add`, `addInt`, `addByte`) and `build()`s a string.

The full list is in the [built-in reference](13-builtins.md).

## Strings

<!-- include: examples/strings.rl -->
```swift
fn main() {
  let s = "  Hello, Rill  ".trim()
  print(s)
  print("${s.len()} ${s.slice(0, 5)} ${s.startsWith("Hell")} ${s.contains("Rill")}")
  print("a,b,,c".split(",").join("|"))
  print("${"one\ntwo\n".lines().len()} lines")
  print("${"42".toInt() ?? 0} ${"x".toInt() ?? -1} ${"2.5".toFloat() ?? 0.0}")
  print("${"abc" < "abd"} ${"abc" == "abc"}")
  // byteAt returns a byte as an Int; character literals are Ints too
  print("${"#x".byteAt(0) == '#'}")
  print("escapes: \"quoted\" \$5 tab\tend")
}
```

<!-- include: examples/strings.out -->
```text
Hello, Rill
11 Hello true true
a|b||c
2 lines
42 -1 2.5
true true
true
escapes: "quoted" $5 tab	end
```

Strings compare with `==`, `!=`, `<`, `<=`, `>`, `>=` (bytewise). `+` concatenates. More text
processing (Unicode, formatting widths, `replace`, case conversion) is in the standard
library: `std/strings`, `std/utf8`, `std/fmt` ([chapter 15](15-standard-library.md)).

Next: [Structs and enums](03-structs-and-enums.md).
