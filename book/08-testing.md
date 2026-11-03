# 8. Testing

Tests live in the same file as the code they test, as in Zig:

<!-- include: examples/testing.test.rl -->
```swift
fn add(_ a: Int, _ b: Int) -> Int = a + b

fn clamp(_ x: Int, low: Int, high: Int) -> Int {
  if x < low {
    return low
  }
  if x > high {
    return high
  }
  return x
}

struct Point { x: Int, y: Int }

fn main() {
  print("rill test does not run main")
}

test "add" {
  expect(add(1, 2) == 3)
}

test "clamp keeps values in range" {
  expect(clamp(5, low: 0, high: 10) == 5)
  expect(clamp(-1, low: 0, high: 10) == 0)
  expect(clamp(11, low: 0, high: 10) == 10)
}

test "a failing test reports every failed expect" {
  expect(add(2, 2) == 5)
  let p = Point(x: 1, y: 2)
  expect(p == Point(x: 1, y: 3), "points differ in y")
  expect(clamp(3, low: 0, high: 2) > 2)
}
```

`rill test testing.test.rl` prints:

<!-- include: examples/testing.test.out -->

- `test "name" { … }` declares a test. Tests see private (non-`pub`) declarations.
- `expect(condition)` records a failure and continues the test, so one run reports every
  failed expectation. For a comparison (`==`, `!=`, `<`, `<=`, `>`, `>=`) the failure shows
  both sides as Rill values; each side is evaluated once. `expect(condition, message)` adds
  a message, evaluated only when the expectation fails. `expect` outside a test is error
  E0020; a message that is no `String` is E0113.
- Long or multi-line values are shown as a line diff (`-` left, `+` right).
- `rill test` runs the tests and not `main`; `rill run` and `rill build` ignore `test` blocks.
- A panic (or `os.exit`) inside a test ends that package's run: the test is reported as
  `PANIC` with the panic message, and the tests after it as not run.

There is no special assertion library: `expect(a == b)` with Rill's structural `==` covers
structs, enums, arrays and optionals.

## Packages and flags

```sh
FAIL  book/examples/testing.test.rl    3 tests   0.00s   (1 failed)

failures:

--- FAIL book/examples/testing.test.rl: a failing test reports every failed expect
book/examples/testing.test.rl:30: expect(add(2, 2) == 5)
    left:  4
    right: 5
book/examples/testing.test.rl:32: expect(p == Point(x: 1, y: 3))
    left:  Point(x: 1, y: 2)
    right: Point(x: 1, y: 3)
    message: points differ in y
book/examples/testing.test.rl:33: expect(clamp(3, low: 0, high: 2) > 2)
    left:  2
    right: 2

result: FAIL. 2 passed, 1 failed; 1 module in 0.00s
```

A pattern ending in `/...` stops at nested modules (directories with their own `rill.mod`)
and skips hidden directories, `_name`, `out` and `testdata`; directories without test
blocks are not built. Every package is compiled and run in a process of its own, so a
panic ends only its package. The output has one line per package, then the failures with
their values, then a result line; the exit code is 0 only when every test passed.

| Flag | |
|---|---|
| `--run <regex>` | only the tests whose name matches (`std/regexp` syntax, unanchored) |
| `-v` | one line per test, with its output |
| `-p N` | packages tested in parallel (default: the number of cores) |
| `--count N` | run the tests N times; never from the cache |
| `--json` | one JSON event per line instead of the report |
| `--bench <regex>` | after the tests, run the benchmarks whose name matches (`.` = all) |
| `--benchtime D` | time per benchmark (`1s`, the default; `500ms`) or iterations (`100x`) |
| `--opt=0`, `--target=…`, `--deny-warnings` | as for `rill build` |

Output a test prints is shown with its failure (and always with `-v`). Colours are used only
when the output is a terminal (and `NO_COLOR` is unset).

### The test cache

A package whose tests all passed is cached. Run again, it shows `(cached)` in place of its
time and does not run, as long as its test binary is the same and nothing its tests read
changed: files and directories (through `std/fs`) and environment variables (`os.env`).
What the tests cannot be tracked through, the clock, randomness, other processes, is not
an input; run such tests with `--count 1`. The cache lives in `~/.cache/rill/test`
(`$RILL_CACHE/test`); `RILL_CACHE=off` turns it off.

```sh
$ rill test ./...
ok    lexer      12 tests   0.12s
$ rill test ./...
ok    lexer      12 tests   (cached)
```

### JSON events

`--json` writes one object per line, in the order of the report:

```
{"event":"start","pkg":"lexer","test":"tokens"}
{"event":"expect","pkg":"lexer","test":"tokens","file":"lexer/lexer_test.rl","line":12,"source":"n == 3","left":"2","right":"3"}
{"event":"end","pkg":"lexer","test":"tokens","result":"fail","ns":1200}
{"event":"package","pkg":"lexer","result":"fail","passed":11,"failed":1,"panicked":0,"notRun":0,"ns":120000000,"cached":false}
{"event":"result","result":"fail","passed":11,"failed":1,"panicked":0,"notRun":0,"packages":1,"ns":130000000}
```

| Event | Fields |
|---|---|
| `build` | the build failed: `ok` (false), `output` (diagnostics) |
| `start` | `test` |
| `output` | `text`: a test's output (with `test`) or text outside tests |
| `expect` | a failed expectation: `file`, `line`, `source`, `left`, `right`, `msg` (absent ones left out) |
| `end` | `test`, `result` (`ok`, `fail`, `panic`, `notrun`), `ns`, `panic` (its text) |
| `package` | `result` (`ok`, `fail`, `panic`, `buildfail`, `notests`), counts, `ns`, `cached` |
| `result` | the totals over all packages |

With `--count` above 1, `start`, `output`, `expect` and `end` carry `run` (from 1).

## Benchmarks

A `bench` block measures code. Setup runs once; the body of `while loop()` is the measured
loop, and `loop()` decides how often it runs: in growing batches until the benchmark took
`--benchtime` (1 s), or exactly `N` times with `--benchtime Nx`.

```rill
import "std/slices"

fn data() -> [Int] {
  var xs: [Int] = []
  for i in 0..<1000 {
    xs.push((i * 7919) % 1000)
  }
  return xs
}

bench "sort 1k" {
  let xs = data() // setup: not measured
  while loop() {
    let _ = slices.sort(xs)
  }
}
```

```sh
$ rill test --bench . --run '^$' ./...
ok    sorting    0 tests, 1 bench   1.17s
    bench sort 1k        7016        166273 ns/op      339024 B/op      6497 allocs/op
```

Benchmarks run only with `--bench`, after the tests (`--run '^$'` skips them), in source
order. Each line shows the iterations and, per iteration, the time, the bytes and the number
of objects allocated. The heap is collected before each benchmark, packages are measured one
at a time, and results never come from the test cache; `--count N` repeats them to see the
variance.

- `loop()` is only allowed as the condition of a `while` directly in a `bench` block (not in
  a closure, a task or another loop), and every bench has exactly one.
- No call in a bench is inlined, so the optimizer cannot remove the work of a call whose
  result is unused. Arithmetic written directly in the loop can still be folded away: put it
  in a function.
- `expect` works in a bench; a failed expectation fails the bench (no numbers).
- `--json` reports a `bench` event per benchmark: `n`, `nsPerOp`, `bytesPerOp`,
  `allocsPerOp`, `result`. Benches are counted apart from tests (`3 passed, 2 benches`;
  `"benches"` in the `package` and `result` events).
- A benchmark runs about its benchtime: the last batch is sized to the remaining time.

## Coverage

`--cover` measures which code the tests ran, the way `go test -cover` does: the statements
of a package are split into blocks that run as a whole (a block ends after an `if`, a loop,
a `switch`, a `return`, ...), and every block counts how often it ran.

```rill
pub fn grade(_ points: Int) -> String {
  if points >= 90 {
    return "A"
  }
  if points >= 50 {
    return "pass"
  }
  return "fail"
}

test "top marks" {
  expect(grade(95) == "A")
}

test "a pass" {
  expect(grade(60) == "pass")
}
```

```sh
$ rill test --coverprofile cover.out ./...
ok    grade    2 tests   0.00s   coverage: 80.0% of statements

$ rill cover cover.out
grade/grade.rl:1:  grade   80.0%
total:                     80.0%

$ rill cover --html cover.out -o cover.html
```

- `--cover` adds the percentage to each package line; `--coverprofile <file>` writes the
  counts of all packages in Go's profile format (`file:line.col,line.col statements count`),
  so Go's tools read it too.
- Only the package under test is measured; `--coverpkg ./...` (comma-separated patterns)
  measures other packages as well, and the percentage is over everything measured. Test and
  bench blocks never count.
- `--covermode atomic` counts with atomic adds (exact counts with tasks); the default `count`
  may lose counts under contention, never coverage.
- `rill cover` prints the coverage per function; `--html` writes one page with the source,
  blocks that ran in green (darker: more often) and blocks that never ran in red.
- The language server shows blocks the last `rill test --cover` of the module never ran as
  hints ("not covered by tests") while the file is unchanged since; the profile is kept in
  `~/.cache/rill/cover` (`$RILL_CACHE/cover`). An editor turns them off with
  `initializationOptions: {"coverage": false}`.
- A cover run is never cached, and a package that panicked has no coverage (`[panicked]`).

## The compiler's own tests

The repository uses golden tests: a program next to its expected output, compiled and
compared by `sh tests/golden.sh` (conventions in [AGENTS.md](https://github.com/rillang/rill/blob/main/AGENTS.md)). The book's
examples use the same conventions ([check.sh](check.sh)).

Not yet: coverage, parallel tests within a package, fuzzing, and doctests
(they come with `rill doc`).

Next: [Concurrency](09-concurrency.md).
