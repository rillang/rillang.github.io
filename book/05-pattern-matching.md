# 5. Pattern matching

Taking values apart is one construct, used the same way in `switch`, `if case`,
`guard case`, `let`, `for` and in functions made of cases.

## switch

<!-- include: examples/patterns.rl -->
```swift
struct Point { x: Int, y: Int }

enum Shape {
  case circle(Float)
  case rect(Point, Point)
  case dot
}

fn describe(_ s: Shape) -> String {
  switch s {
  case .circle(r) where r > 10.0: return "big circle"
  case .circle(_): return "circle"
  case .rect(Point(x: 0, y: 0), corner): return "rect from the origin to ${corner.x},${corner.y}"
  case .rect(_, _): return "rect"
  case .dot: return "dot"
  }
}

fn head(_ xs: [Int]) -> String {
  switch xs {
  case []: return "empty"
  case [x]: return "one: $x"
  case [x, y, ...rest]: return "$x, $y and ${rest.len()} more"
  }
}

fn grade(_ n: Int) -> String {
  switch n {
  case 90..<101: return "A"
  case 0, 1, 2: return "almost nothing"
  case x where x < 0: return "invalid"
  default: return "other"
  }
}

fn greet(_ name: String?) -> String {
  switch name {
  case nil: return "hello, stranger"
  case "root"?: return "hello, admin"
  case n?: return "hello, $n"
  }
}

fn server(_ conf: Map<String, Int>) -> String {
  switch conf {
  case [:]: return "no config"
  case ["port": p, "debug": 1]: return "port $p (debug)"
  case ["port": p]: return "port $p"
  default: return "no port"
  }
}

fn main() {
  print(describe(.circle(12.0)))
  print(describe(.rect(Point(x: 0, y: 0), Point(x: 3, y: 4))))
  print(describe(.dot))
  print("${head([])} | ${head([7])} | ${head([1, 2, 3, 4])}")
  print("${grade(95)} ${grade(1)} ${grade(-3)} ${grade(50)}")
  print("${greet(nil)}; ${greet("root")}; ${greet("ana")}")
  print("${server([:])}; ${server(["port": 80])}; ${server(["port": 8080, "debug": 1])}")

  // name @ pattern binds the whole value too
  let s: Shape = .rect(Point(x: 9, y: 0), Point(x: 0, y: 0))
  if case whole @ .rect(Point(x: x, y: _), _) = s {
    print("x=$x in ${describe(whole)}")
  }
}
```

<!-- include: examples/patterns.out -->
```text
big circle
rect from the origin to 3,4
dot
empty | one: 7 | 1, 2 and 2 more
A almost nothing invalid other
hello, stranger; hello, admin; hello, ana
no config; port 80; port 8080 (debug)
x=9 in rect
```

The cases are tried top to bottom; the first that matches runs. There is no fallthrough.
`case a, b:` shares a body between alternatives (they must bind the same names with the
same types, E0035). `where condition` is a guard checked after the pattern matched, with
the pattern's bindings in scope. `default:` matches everything else.

## Patterns

| Pattern | Matches | Binds |
|---|---|---|
| `_` | anything | nothing |
| `name` | anything | `name` |
| `42`, `-1`, `"text"`, `'c'`, `true` | an equal literal | nothing |
| `a..<b` | an `Int` (or character) with `a <= v < b` | nothing |
| `nil` | an empty optional | nothing |
| `p?` | a non-empty optional whose value matches `p` | what `p` binds |
| `.case`, `.case(p1, p2)` | that enum case with matching payloads (also `.some`/`.none`, `.ok`/`.err`) | the payload bindings |
| `Type(field: p, …)` | a struct whose listed fields match; others are ignored | the field bindings |
| `[p1, p2]` | an array of exactly that length | elementwise |
| `[p1, ...rest]`, `[p1, ...]` | an array of at least that length; `rest` is the remainder | elementwise and `rest` |
| `["key": p]` | a map that has the key, with a value matching `p`; other keys are allowed | the value bindings |
| `[:]` | an empty map | nothing |
| `name @ p` | what `p` matches | `name` (the whole value) and what `p` binds |

Patterns nest freely. Bindings are constants. A pattern gets its type from the value it is
matched against, so `.circle(r)` needs no type name; a pattern that cannot match the type
is error E0033.

## Exhaustiveness

A `switch` without `default` must cover every possible value. The compiler names what is
missing:

<!-- include: examples/nonexhaustive.err.rl -->
```swift
enum Expr {
  case num(Int)
  case add(Expr, Expr)
  case neg(Expr)
}

fn eval(_ e: Expr) -> Int {
  switch e {
  case .num(n): return n
  }
}

fn main() {
  print("${eval(.num(1))}")
}
```

<!-- include: examples/nonexhaustive.err -->
```text
error[E0011]: switch must be exhaustive, missing: .add(_, _), .neg(_)
 --> book/examples/nonexhaustive.err.rl:8:3
  |
8 |   switch e {
  |   ^
```

Bools, enums, optionals, results, structs and array lengths are checked structurally.
`Int`, `String` and map values are only covered by a catch-all (`x`, `_` or `default`).
Cases with a `where` guard do not count as covering. A case that can never match because
earlier cases took all its values is error E0032.

## Patterns outside switch

<!-- include: examples/patterns_more.rl -->
```swift
struct Point { x: Int, y: Int }

enum Shape {
  case circle(Float)
  case square(Float)
}

// A function whose body starts with `case` matches its parameters
fn fib(_ n: Int) -> Int {
case 0: return 0
case 1: return 1
case n: return fib(n - 1) + fib(n - 2)
}

// several parameters: one pattern per parameter, in parentheses
fn gcd(_ a: Int, _ b: Int) -> Int {
case (a, 0): return a
case (a, b): return gcd(b, a % b)
}

fn sumOfFirstTwo(_ xs: [Int]) -> Int {
  guard case [a, b, ...] = xs else {
    return 0
  }
  return a + b
}

fn main() {
  print("${fib(10)} ${gcd(84, 36)}")
  print("${sumOfFirstTwo([4, 5, 6])} ${sumOfFirstTwo([1])}")

  // let destructures with an irrefutable pattern
  let p = Point(x: 3, y: 4)
  let Point(x: px, y: py) = p
  print("$px $py")

  // for destructures every element; for case visits only matching ones
  let points = [Point(x: 1, y: 2), Point(x: 3, y: 4)]
  var dot = 0
  for Point(x: x, y: y) in points {
    dot += x * y
  }
  let shapes: [Shape] = [.circle(1.0), .square(2.0), .circle(0.5)]
  var radii = 0.0
  for case .circle(r) in shapes {
    radii += r
  }
  print("$dot $radii")

  // maps iterate as key, value
  for word, n in ["one": 1, "two": 2] {
    print("$word -> $n")
  }
}
```

<!-- include: examples/patterns_more.out -->
```text
55 12
9 0
3 4
14 1.5
one -> 1
two -> 2
```

| Form | Pattern kind |
|---|---|
| `if case p = e { … } else { … }` | refutable: a condition |
| `guard case p = e else { … }` | refutable; bindings stay visible after the guard |
| `let p = e`, `var p = e` | irrefutable only (bindings, `_`, structs of those) |
| `for p in xs` | irrefutable, destructures each element |
| `for case p in xs` | refutable, visits only matching elements |
| `for k, v in m` | both irrefutable (to filter, use `if case` inside the loop) |

A refutable pattern where an irrefutable one is required is error E0034.

**Functions made of cases**: when a function body starts with `case`, it matches the
parameters. With several parameters, each case lists one pattern per parameter in
parentheses (the only place where parentheses group patterns: Rill has no tuples). The
cases must be exhaustive, like a `switch`. The signature stays explicit, so labels and
types at the boundary do not change.

Not supported: string prefix patterns, patterns on closure parameters.

Next: [Generics and interfaces](06-generics-and-interfaces.md).
