# 3. Structs and enums

Rill has two ways to define types: a **struct** (several fields, all present) and an
**enum** (one of several cases, each with optional values). There are no classes and no
inheritance.

## Structs

<!-- include: examples/structs.rl -->
```swift
struct Point { x: Int, y: Int }

struct Line {
  from: Point
  to: Point
  label: String?
}

fn length2(_ l: Line) -> Int {
  let dx = l.to.x - l.from.x
  let dy = l.to.y - l.from.y
  return dx * dx + dy * dy
}

fn main() {
  // construction names every field
  var p = Point(x: 1, y: 2)
  p.x = 10

  // structs are values: q is a copy
  let q = p
  p.y = 0
  print("p=(${p.x}, ${p.y}) q=(${q.x}, ${q.y})")

  var l = Line(from: Point(x: 0, y: 0), to: Point(x: 3, y: 4), label: nil)
  print("${length2(l)} ${l.length2()}")
  l.to.x = 6
  print("${length2(l)}")

  // == compares structurally
  print("${q == Point(x: 10, y: 2)} ${p == q}")
}
```

<!-- include: examples/structs.out -->
```text
p=(10, 0) q=(10, 2)
25 25
52
true false
```

- Fields are listed with commas on one line or one per line.
- A struct is constructed by its name with every field labeled: `Point(x: 1, y: 2)`.
- Fields are changed through a `var` (`p.x = 10`, `l.to.x = 6`); a `let` struct is
  immutable all the way down.
- Structs are values: `let q = p` copies, and later changes to `p` do not affect `q`.
- `==` and `!=` compare field by field (also for enums, arrays and optionals).
- "Methods" are ordinary functions whose first parameter is the struct, called with
  [UFCS](02-basics.md#ufcs-there-are-no-methods): `l.length2()`.
- Fields are private to their module unless marked `pub` (`struct Span { pub label: String, ns: Int }`);
  outside the module a private field cannot be read, written, matched or named in an init (E0138).
  A struct with a private field that has no default is built by a `pub fn` of its module
  (`time.seconds(2)`, not `Duration(ns: ...)`). Inside the module, all its files included,
  nothing changes. `rill fix` adds `pub` where code outside the module uses a field.
- A struct cannot contain itself directly (E0012); use an array or an enum for recursion.

### Default field values

A field may have a default; construction may then omit it:

```swift
struct Opts {
  workers: Int = 0
  verbose: Bool = false
  tags: [String] = []
  name: String
}

let o = Opts(name: "x")                   // workers 0, verbose false, tags []
let p = Opts(verbose: true, name: "y")    // skip fields, keep declaration order
```

- A default is a constant expression (it may name a `let` constant), `nil`, a case without
  payload (`.fast`), `[]` or `[:]`. No calls (E0120).
- Arguments stay in declaration order; a defaulted field may be skipped, never reordered.
- The default is evaluated at each construction: every `[]` is a fresh array.
- `rill api` prints defaults; changing one is an API change.

## Enums

<!-- include: examples/enums.rl -->
```swift
enum Color {
  case red
  case green
  case blue
}

// cases can carry values, and enums can be recursive
enum Expr {
  case num(Int)
  case add(Expr, Expr)
  case neg(Expr)
}

fn name(_ c: Color) -> String {
  switch c {
  case .red: return "red"
  case .green: return "green"
  case .blue: return "blue"
  }
}

fn eval(_ e: Expr) -> Int {
  switch e {
  case .num(n): return n
  case .add(a, b): return eval(a) + eval(b)
  case .neg(x): return -eval(x)
  }
}

fn main() {
  // `.case` works where the type is known; otherwise write Type.case
  let c: Color = .green
  print("${name(c)} ${name(Color.blue)}")
  let e = Expr.add(.num(2), .neg(.num(5)))
  print("${eval(e)}")
  print("${e == .add(.num(2), .neg(.num(5)))}")
}
```

<!-- include: examples/enums.out -->
```text
green blue
-3
true
```

- Each `case` can carry values: `case add(Expr, Expr)`. Payloads are positional.
- Enums may be recursive (`Expr` contains `Expr`).
- `.green` is the short form of `Color.green` where the expected type is known: in a typed
  `let`, as an argument, in a `return`, in a comparison.
- A `switch` over an enum must cover every case or have a `default` (E0011).

Optionals (`T?`) and results (`T!`) are built-in enums: next chapter.

Next: [Optionals and results](04-optionals-and-results.md).
