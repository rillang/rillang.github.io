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

## The compiler's own tests

The repository uses golden tests: a program next to its expected output, compiled and
compared by `sh tests/golden.sh` (conventions in [AGENTS.md](https://github.com/rillang/rill/blob/main/AGENTS.md)). The book's
examples use the same conventions ([check.sh](check.sh)).

Not yet: benchmarks, coverage, parallel tests within a package, fuzzing, and doctests
(they come with `rill doc`).

Next: [Concurrency](09-concurrency.md).
