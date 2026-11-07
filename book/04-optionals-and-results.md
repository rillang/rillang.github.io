# 4. Optionals and results

Rill has no `null` references and no exceptions. A value that may be missing is an
**optional** `T?`; an operation that may fail returns a **result** `T!`. Both are visible
in the types, so the compiler can check that they are handled.

## Optionals

<!-- include: examples/optionals.rl -->
```swift
fn firstEven(_ xs: [Int]) -> Int? {
  for x in xs {
    if x % 2 == 0 {
      return x
    }
  }
  return nil
}

// `?` on an optional returns nil from the enclosing function when it is empty
fn doubledFirstEven(_ xs: [Int]) -> Int? {
  let x = firstEven(xs)?
  return x * 2
}

fn describe(_ xs: [Int]) -> String {
  guard let x = firstEven(xs) else {
    return "no even number"
  }
  return "first even: $x"
}

fn main() {
  let a = firstEven([1, 4, 6])
  let b = firstEven([1, 3])

  // ?? supplies a default
  print("${a ?? -1} ${b ?? -1}")

  // if let unwraps
  if let x = a {
    print("found $x")
  } else {
    print("none")
  }

  print("${doubledFirstEven([3, 8]) ?? 0} ${doubledFirstEven([]) ?? 0}")
  print(describe([5, 2]))
  print(describe([5]))
  print("${b == nil}")
}
```

<!-- include: examples/optionals.out -->
```text
4 -1
found 4
16 0
first even: 2
no even number
true
```

| Form | Meaning |
|---|---|
| `nil` | the empty optional |
| `a ?? b` | the value of `a`, or `b` if `a` is empty |
| `if let x = a { … } else { … }` | run the block with `x` bound if `a` has a value |
| `guard let x = a else { return … }` | leave early if empty; `x` is visible afterwards |
| `a?` | the value, or return `nil` from the enclosing function (which must return an optional) |
| `a == nil`, `a == 3` | comparisons (the optional on the left) |

`if let`, `guard let` and `??` work on results too ([below](#results)).

`??` binds more loosely than arithmetic: `a ?? 0 + 1` means `a ?? (0 + 1)`.

An optional is an enum with the cases `.some(x)` and `.none`, and can be matched like one
(`case .some(x):`, or with the patterns `x?` and `nil`; [chapter 5](05-pattern-matching.md)).

There is no optional chaining (`a?.b`): use `if let`, `guard let` or `?` inside a function
that returns an optional.

## Results

<!-- include: examples/results.rl -->
```swift
// T! is a result: a T or an Error. fail("…") creates the error.
fn parsePort(_ s: String) -> Int! {
  guard let n = s.toInt() else {
    return fail("not a number: $s")
  }
  if n <= 0 || n >= 65536 {
    return fail("out of range: $n")
  }
  return n
}

// guard let takes the value of a result and skips the error: right here,
// because any bad input means "use the default port"
fn portOr80(_ s: String) -> Int {
  guard let p = parsePort(s) else {
    return 80
  }
  return p
}

// `?` propagates the error to the caller
fn parsePair(_ a: String, _ b: String) -> Int! {
  return parsePort(a)? + parsePort(b)?
}

fn main() {
  print("${parsePort("8080") ?? 0}")
  print("${parsePort("x") ?? 0}")

  // a result is an enum with the cases .ok and .err
  switch parsePair("80", "99999") {
  case .ok(sum): print("sum $sum")
  case .err(e): print("error: ${e.msg}")
  }

  // if let runs the block only when there is a value
  if let p = parsePort("443") {
    print("port $p")
  }
  print("${portOr80("http")}")

  // to look at the error, switch on .err(e)
  switch parsePort("") {
  case .ok(_):
  case .err(e): print("empty input: ${e.msg}")
  }
}
```

<!-- include: examples/results.out -->
```text
8080
0
error: out of range: 99999
port 443
80
empty input: not a number: 
```

- `T!` holds a `T` or an `Error`. `Void!` is a result without a value.
- `fail("message")` creates an error; `e.msg` is its message, the whole chain of
  context (next section).
- `e?` returns the error from the enclosing function (which must return a result,
  otherwise E0015); otherwise it is the value. In a test it fails the test instead
  ([chapter 8](08-testing.md)).
- `e ?? fallback` uses a fallback instead of the error.
- `if let v = r { … } else { … }` and `guard let v = r else { … }` work on results as on
  optionals: they bind the value, and on an error they take the other branch and drop the
  error. A `Void!` has no value to bind: use `switch` or `?` (E0003).
- A result is an enum with the cases `.ok(value)` and `.err(error)`; `switch` takes it
  apart, and is the way to look at the error (an empty case body ignores the other case).
- Skipping an error, with `??` or `if let`, is right only when the fallback is a correct
  answer (an optional settings file that is missing). Otherwise propagate it with `?` or
  handle `.err(e)` in a `switch`.

## Context, causes and sentinels

<!-- include: examples/error_causes.rl -->
```swift
import "std/fs"

// a sentinel: one error value that callers can recognize
let badPort = Error("port is not a number")

fn loadPort(_ path: String) -> Int! {
  // a missing file means the default; anything else gets context and propagates
  let text = switch fs.readFile(path) {
    case .ok(t): t
    case .err(fs.notFound): "8080"
    case .err(e): return e.context("load $path")
  }
  guard let n = text.trim().toInt() else {
    return fail("load $path", cause: badPort)
  }
  return n
}

fn main() -> Void! {
  print("${loadPort("/nonexistent/app.conf")?}")
  let dir = fs.tempDir("book")?
  fs.writeFile("$dir/app.conf", "eighty")?
  switch loadPort("$dir/app.conf") {
  case .ok(n): print("port $n")
  case .err(e):
    print("${e.is(badPort)} ${e.cause != nil}")
  }
  // context on a result adds a layer only when it holds an error
  let n = loadPort("/nonexistent/x").context("start")?
  print("$n")
  fs.removeAll(dir)?
}
```

<!-- include: examples/error_causes.out -->
```text
8080
true true
8080
```

- `r.context("load $path")` adds what the caller was doing to an error, and passes a value
  through untouched; `e.context(…)` does the same on an `Error`. The message becomes
  `"load a.conf: read a.conf: no such file"`.
- `fail("msg", cause: e)` builds such an error by hand; `e.cause` is the error underneath
  (`Error?`).
- A top-level `let x = Error("…")` is a **sentinel**: one value that callers recognize.
  `e.is(x)` asks whether `e` or any error in its chain is that value; two errors with the
  same text are still different errors. `==` does not apply to errors.
- `case .err(fs.notFound):` matches a sentinel of another module anywhere in the chain. A
  bare name in a pattern binds a new name, so inside the declaring module write `e.is(x)`.
  A `switch` still needs `.err(e)` or `default` for the other errors.
- `std/fs` fails with `fs.notFound`, `fs.alreadyExists`, `fs.permission`, `fs.isDir`,
  `fs.notDir` and `fs.notEmpty`. Never look at `e.msg` to tell errors apart.

## Errors in `main`

`main` may return `Void!`. An error that reaches the end of `main` is printed to stderr
as `error: <msg>` and the program exits with code 1:

<!-- include: examples/main_error.fail.rl -->
```swift
import "std/fs"

fn load(_ path: String) -> String! {
  let text = fs.readFile(path)?
  return text.trim()
}

// main may return Void!: an error ends the program with exit code 1
fn main() -> Void! {
  print("loading")
  let config = load("/nonexistent/rill-book.conf")?
  print(config)
}
```

<!-- include: examples/main_error.fail.err -->
```text
error: read /nonexistent/rill-book.conf: no such file
```

## Panics are for bugs

`panic("message")` stops the program with exit code 101. The runtime panics on bugs:
an index out of bounds, integer overflow, division by zero, a stack overflow, sending on a
closed channel. Panics are not caught; a panic in any task ends the whole program.

<!-- include: examples/bounds.panic.rl -->
```swift
fn pick(_ xs: [Int], _ i: Int) -> Int = xs[i]

fn main() {
  let xs = [1, 2, 3]
  print("${pick(xs, 1)}")
  print("${pick(xs, 5)}")
}
```

<!-- include: examples/bounds.panic.err -->
```text
panic: index out of bounds: 5 (len 3)
 --> book/examples/bounds.panic.rl:1
```

With `RILL_BACKTRACE=1` the panic also prints the call chain (function names with
`file:line`, inlined calls included).

Errors today are only messages: there are no error types to match on. See
[known limits](14-limits.md).

Next: [Pattern matching](05-pattern-matching.md).
