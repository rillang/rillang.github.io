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
```text
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

- `test "name" { … }` declares a test. Tests see private (non-`pub`) declarations.
- `expect(condition)` records a failure and continues the test, so one run reports every
  failed expectation. For a comparison (`==`, `!=`, `<`, `<=`, `>`, `>=`) the failure shows
  both sides as Rill values; each side is evaluated once. `expect(condition, message)` adds
  a message, evaluated only when the expectation fails. `expect` outside a test is error
  E0020; a message that is no `String` is E0113.
- Long or multi-line values are shown as a line diff (`-` left, `+` right).
- `?` works in a test as in a function returning a result: `let n = parse("3")?` takes the
  value, and an error (or `nil` from an optional) fails the test with its message and ends
  it. The report shows the expression and `error: <message>`. Inside a closure `?` still
  belongs to the closure. The same holds in bench and fuzz blocks: there a failing `?` is
  a failed bench, or a finding.
- `rill test` runs the tests and not `main`; `rill run` and `rill build` ignore `test` blocks.
- A panic (or `os.exit`) inside a test ends that package's run: the test is reported as
  `PANIC` with the panic message, and the tests after it as not run.

There is no special assertion library: `expect(a == b)` with Rill's structural `==` covers
structs, enums, arrays, maps and optionals (a map shows as `["a": 1, "b": 2]`, in insertion
order).

### Subtests and table tests

A `test` statement inside a test declares a subtest. For a table, one subtest per row is the
main form: each row passes or fails on its own, and the report names it.

<!-- include: examples/subtests.test.rl 12-26 -->
```swift
struct Row { name: String, input: Int, want: Int }

fn rows() -> [Row] = [
  Row(name: "negative", input: -4, want: -1),
  Row(name: "zero", input: 0, want: 0),
  Row(name: "positive", input: 9, want: 1),
]

test "sign per row" {
  for r in rows() {
    test r.name {
      expect(sign(r.input) == r.want)
    }
  }
}
```

`rill test subtests.test.rl` prints (the file's `sign` is wrong for `0`):

<!-- include: examples/subtests.test.out -->
```text
FAIL  book/examples/subtests.test.rl    5 tests   0.00s   (3 failed)

failures:

--- FAIL book/examples/subtests.test.rl: sign per row/zero
book/examples/subtests.test.rl:23: expect(sign(r.input) == r.want)
    left:  1
    right: 0

--- FAIL book/examples/subtests.test.rl: sign in one loop
book/examples/subtests.test.rl:30: expect(sign(r.input) == r.want)
    left:  1
    right: 0
    message: zero

result: FAIL. 2 passed, 3 failed; 1 module in 0.00s
```

- The name is any `String` expression (`test r.name`). A string literal is the common case.
  The expression ends at the `{`, so a trailing closure is not parsed there, as in an `if`
  condition.
- The full name joins the levels with `/`: `sign per row/zero`. A `/` inside a name stays.
  Equal full names under one parent get `#01`, `#02`, ...: the first keeps its name.
- The body is a closure, run in place when the statement is reached. `return` ends the
  subtest and passes it if nothing failed before. A failing `?` fails the subtest and ends
  its body. The parent goes on.
- A failed `expect` or `?` in a subtest fails it, and, once it ends, its parent. A parent
  whose only failure is a child shows no failure of its own: the failures-only report
  (agent mode) lists the failing subtests, not the parent.
- Every test and subtest counts once in `N passed, M failed` and in the JSON `package`
  event. The JSON `start` and `end` events carry the full name; a parent's `end` follows
  its children's.
- Subtests nest. `test` outside a test body is E0020, also inside an ordinary closure in a
  test; in a `bench` body it is E0020 too.
- A panic in a subtest ends the package's run as in any test: the innermost test is
  reported as panicked, its open parents as failed, and the later tests as not run.

The light option is the loop with `expect` and a message naming the row. It is a single
test: `expect` continues, so one run reports every failing row, but the rows are not
counted or listed as tests of their own:

<!-- include: examples/subtests.test.rl 28-32 -->
```swift
test "sign in one loop" {
  for r in rows() {
    expect(sign(r.input) == r.want, r.name)
  }
}
```

## Snapshots and golden files

For output that is long or tedious to write by hand (a rendered report, generated code, a
binary format), compare it with a file instead of a literal.

```swift
test "report" {
  expectSnapshot(render(items))            // testdata/snapshots/report.snap
  expectSnapshot(render([]), "empty")      // testdata/snapshots/report.empty.snap
  expectGolden(render(items), "testdata/report.txt")
}
```

Both take a `String` or `Bytes`.

| | `expectSnapshot(value, label)` | `expectGolden(value, path)` |
|---|---|---|
| File | `testdata/snapshots/<test name>[.<label>].snap`, named for you | the path you give, relative to the package |
| Use for | output only this test cares about | a file that is also an input or documentation elsewhere |
| Several calls | unlabeled ones count (`name`, `name-2`); a label may be used once per test | one path per call |

- A missing file fails: `snapshot testdata/snapshots/report.snap missing; run rill test --update`.
  CI never accepts output nobody has seen.
- A difference fails with a unified diff of the file (`-`) against the value (`+`).
- `rill test --update` writes the missing and changed files (`RILL_TEST_UPDATE=1` does the
  same). It bypasses the test cache and reports `(updated N)`.
- **Read the diff of the `.snap` files before you commit.** `--update` makes every test
  pass; reviewing the changed files is the check that the new output is the right one.

## Fixtures

Three helpers in `std/testing` set up what a test needs and undo it when the test (or subtest)
ends:

```swift
import "std/testing"

test "export" {
  let dir = testing.tempDir()              // new empty directory, removed afterwards
  testing.setenv("EXPORT_FORMAT", "csv")   // the old value comes back afterwards
  testing.cleanup { closeConnections() }   // any closure
  // ...
}
```

- `tempDir()` returns a new empty directory named after the test, removed with everything in it.
- `setenv(name, value)` sets the variable; the old value, or its absence, is restored. The test
  owns the variable: it is not an input of the test cache. Outside tests, `os.setenv` and
  `os.unsetenv` change the environment of the process and the children it starts later.
- `cleanup(f)` runs `f` at the end. A test's cleanups run in reverse order of registration, so
  what was set up last is torn down first. A subtest has its own list, run when the subtest ends.
- Cleanups run before the verdict, also when an `expect` failed or `?` ended the test. An
  `expect` that fails inside a cleanup fails the test. A panic ends the process: no cleanups.
- Fixtures belong to tests: `rill test` runs fuzz seeds as tests, so fixtures work there; in a benchmark or under `rill fuzz` there is no running test and they panic with `called outside a test`.

**`cleanup` versus `defer`.** `defer` runs when the function that wrote it returns; `cleanup`
runs when the test ends. A helper `fn newServer() -> Server` cannot `defer` the server's
shutdown (it would stop it on return), but it can register `testing.cleanup { server.stop() }`,
and the test does not have to remember. Inside the test body, `defer` is fine for what
belongs to one block.

The environment belongs to the whole process, and `setenv` is not safe while other tasks read
it. Tests without the `parallel` marker run one after another and restore it between tests; a
`parallel` test runs in a process of its own, so its `setenv` does not reach the others.

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
| `--run <regex>` | only the tests whose name matches (`std/regexp` syntax, unanchored); split at `/` (outside `[]` and `()`), part *i* matches subtest level *i*: `--run 'sign per row/zero'` |
| `--skip <regex>` | do not run the tests whose name matches (not reported); split at `/` like `--run` |
| `-v` | one line per test, with its output |
| `-p N` | packages tested in parallel (default: the number of cores) |
| `--count N` | run the tests N times; never from the cache |
| `--retries N` | rerun a failed test up to N times; one that passes on a later try is reported `FLAKY` (exit 0), never as a plain pass |
| `--timeout D` | stop a test binary after D (`10s`, `500ms`; default `10m`; `0`: never) |
| `--shuffle S` | run the top-level tests of each package in random order: `on` (a seed from the clock), `off` (default) or a seed; prints `shuffle seed N` |
| `--shard i/n` | run only the i-th of n parts of the tests, split by a hash of each test's name |
| `--failfast` | after the first failure no other test or package starts; they are reported not run |
| `--slowest N` | after the report, list the N slowest tests and how many test processes ran at once on average |
| `--update` | write the files of `expectSnapshot` and `expectGolden` (also `RILL_TEST_UPDATE=1`); never uses the cache |
| `--json` | one JSON event per line instead of the report |
| `--bench <regex>` | after the tests, run the benchmarks whose name matches (`.` = all) |
| `--benchtime D` | time per benchmark (`1s`, the default; `500ms`) or iterations (`100x`) |
| `--fuzz <regex>` | fuzz the one fuzz target that matches, in each package; `--fuzztime D` is how long (`10s`) or how many inputs (`5000x`) |
| `--cover`, `--coverprofile F`, `--coverpkg P,Q`, `--covermode M` | coverage, see [Coverage](#coverage) |
| `--cpuprofile F`, `--memprofile F`, `--memprofilerate N` | profiles of the test binary (one package), see [chapter 11](11-tooling.md); `--memprofilerate` is the bytes per heap sample (default 524288; `1`: all) |
| `--opt=0`, `--target=…`, `--deny-warnings` | as for `rill build` |

Flags for a run that goes wrong are explained in [When tests misbehave](#when-tests-misbehave). Output a test prints is shown with its failure (and always with `-v`). Colours are used only
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
| `output` | `text`: a test's output (with `test`, or `bench`) or text outside tests (build warnings, the panic text of a test binary that died) |
| `expect` | a failed expectation: `file`, `line`, `source`, `left`, `right`, `msg` (absent ones left out); for a `?` that met an error, `source` is the expression and `msg` the error |
| `end` | `test`, `result` (`ok`, `fail`, `panic`, `notrun`), `ns`, `panic` (its text; also the timeout report), `timeout` (true: the test was running when `--timeout` stopped its binary), `tries` and `flaky` (see below) |
| `bench` | a benchmark (`bench` instead of `test`): `result`, and when it passed `n`, `nsPerOp`, `bytesPerOp`, `allocsPerOp`; `panic` after a panic |
| `fuzz` | a `--fuzz` run: `target`, `result`, `execs`, `corpus`, `ns`; for a failure `file` (the saved input), `input` and `failure` |
| `package` | `result` (`ok`, `fail`, `panic`, `buildfail`, `notests`, `notrun`: `--failfast` did not start it), `passed`, `benches`, `flaky`, `failed`, `panicked`, `notRun`, `ns`, `cached`, `coverage` (percent, under `--cover`) |
| `result` | the totals over all packages: `result` (`ok`, `fail`), the counts of `package`, `packages`, `ns`, `coverage`, `shuffle`, `shard`, `slowest`, `testNs`, `tailNs` |

Every event has `event`; all but `result` have `pkg`. Absent fields are left out, so a script reads
`flaky` or `benches` as 0 when it is missing. The count fields are `passed`, `failed`, `panicked`
and `notRun`, always present; `benches` (benchmarks that ran) and `flaky` (of the passed, on a later
try) only when above 0. `ns` is nanoseconds.

- `run` (from 1) is on `start`, `output`, `expect`, `end` and `bench` with `--count` above 1.
- `tries` is on the `end` of a test that failed its first try under `--retries`: the number of runs.
  `flaky` (true) is added when it passed on a later one; `result` stays `ok`, `panic` holds the
  first try's text. A leaf that never passed has `tries` and `result` `fail`.
- `shuffle` on `result` is the seed (a number) that reproduces the order, present under `--shuffle`.
- `shard` on `result` is the part (`"1/2"`) under `--shard`.
- `slowest` on `result`, under `--slowest N`, is an array of `{pkg, test, ns}` for the N slowest
  leaf tests, slowest first; `testNs` is the sum of the test times, `tailNs` the time the run lasted
  after its last test started.

```
{"event":"end","pkg":"lexer","test":"flaky","result":"ok","ns":900,"tries":2,"flaky":true}
{"event":"end","pkg":"lexer","test":"spins","result":"fail","ns":1000000000,"timeout":true,"panic":"panic: test timed out after 1s\n..."}
{"event":"result","result":"ok","passed":2,"flaky":1,"failed":0,"panicked":0,"notRun":0,"packages":1,"shard":"1/2","ns":130000000}
```

## When tests misbehave

What to reach for, by what you see.

**Run a subset.** `--run` selects by name, `--skip` removes by name; both are unanchored
regular expressions split at `/`, one part per subtest level (`--skip 'parse/slow'` skips the
subtest `slow` of `parse` and runs its siblings). Skipped tests are not reported.

**A test hangs.** `--timeout 30s` stops a test binary that runs longer (default `10m`; `0` turns it off). The binary
prints `panic: test timed out after 30s`, the running tests with their age and the call chain of
every task, and the running tests fail (`timeout: true` in `--json`); tests that did not start
are reported not run, and the rest of the package continues in a new process, with its own full
timeout. A test still running after 60 s prints a `SLOW` line on stderr first.

**A test is flaky.** Three flags find it, one tolerates it:

- `--shuffle on` runs the top-level tests of each package in random order and prints
  `shuffle seed N`. A failure that appears only in some orders means a test depends on state
  another test left behind. `--shuffle N` repeats that order; with `--count`, every repetition
  uses the same seed.
- `--count N` runs the tests N times (never cached).
- `--retries N` reruns a failed test, alone, up to N times. A test that passes on a later try is
  reported `FLAKY` with the first try's failure and output, counts as passed, and the exit code
  stays 0. It is never shown as a plain pass: `result: ok. 2 passed (1 flaky)`. Use it to keep CI
  moving while you fix the test, not to hide it.

**Stop early.** `--failfast` starts no further test or package after the first failure; they are
reported `not run`. Panic continuation is off under it.

**Find slow tests.** `--slowest 5` lists the five slowest tests after the report and a `busy:` line:
how many test processes ran at once on average. A low number with a long run means one
package or `parallel` test dominates; mark independent slow tests `parallel`.

**Snapshots changed on purpose.** `--update` rewrites the files of `expectSnapshot` and
`expectGolden` ([Snapshots and golden files](#snapshots-and-golden-files)); review the diff.

**Split CI over machines.** `--shard i/n` runs the i-th of n parts. A leaf test (one without
subtests) belongs to the part its name's hash selects (FNV-1a of the full name, for a subtest
`parent/child`), so every leaf runs in exactly one of the n parts. A test with subtests runs in every
part, with only its selected subtests, so its setup is repeated, not skipped. Run each part on its own machine:

```sh
rill test --shard 1/4 ./...    # machine 1
rill test --shard 2/4 ./...    # machine 2, and so on
```

The result line names the part (`result: ok. 11 passed; shard 1/2; 1 module in 0.00s`), and so does
`result` in `--json` (`"shard":"1/2"`). A part can be empty; benches and fuzz seeds are split the
same way. The cache keys include the shard, so changing the split does not reuse an old verdict.

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

## Comparing benchmarks

Did a change make the code faster? `rill bench compare` answers it from the `--json` output
of two runs: save one run before the change and one after, then compare them.

```sh
git stash
rill test --bench . --run '^$' --count 10 --json ./parser > old.json
git stash pop
rill test --bench . --run '^$' --count 10 --json ./parser > new.json
rill bench compare old.json new.json
```

```
pkg: parser
        │  old.json  │              new.json              │
        │  time/op   │  time/op    vs base                │
parse     12.3µ ± 2%   10.1µ ± 1%  -17.81% (p=0.000 n=10)
tokens    4.01µ ± 1%   4.00µ ± 2%        ~ (p=1.000 n=10)
geomean   7.01µ        6.35µ        -9.35%
```

Each bench shows its median and the 95 % confidence interval of it. `vs base` is the change
against the first file, `p` the probability of seeing such a difference if nothing changed
(Mann-Whitney U test), `n` the number of runs. The command prints one block per package, and
in it the sections time/op, B/op and allocs/op, each with a geomean over its benches. With
one file it prints only the medians.

Run with `--count 10`: one run of a bench varies by a few percent, and the statistics need
the samples to tell a change from noise. With fewer than 6 runs there is no confidence
interval (`± ∞`).

- `~` means no significant difference (`p` of 0.05 or more): the difference is within noise.
- `?` means too few runs for the test: use `--count 4` or more, 10 recommended.

`--json` prints one event per bench and metric, then a result line. `--fail-above P` exits 1 when
a significant change makes a metric more than P % worse (`5`, `5%`, `2.5`); it needs two files,
so a CI job can gate on it: `rill bench compare --fail-above 5 old.json new.json`.

## Parallel tests

A slow test (files, the network, large inputs) can run next to the others: mark it
`parallel`.

```rill
import "std/fs"

test "parses the big fixture" parallel {
  let text = fs.readFile("testdata/big.json") ?? ""
  expect(text.len() > 0)
}
```

- The tests without the marker run first, one after another; then every parallel test runs
  in a process of its own, `--parallel N` at a time (default: the number of cores).
- A parallel test that panics or calls `os.exit` ends only itself: the other tests still
  run and are reported.
- The report and `--json` list every test in the order of the source, wherever it ran;
  coverage and the test cache include the parallel tests.
- `--parallel 1`, and `--count N` with N > 1, run every test in one process, in order.
- A process costs a few milliseconds to start: mark tests that take longer than that.

### Parallel subtests

`parallel` works on a subtest too:

```rill
test "fixtures" {
  for name in fs.readDir("testdata") ?? [] {
    test name parallel {
      // the work is here
    }
  }
}
```

- A parallel subtest runs in a process of its own, after the serial run of its package has
  ended, `--parallel N` at a time together with the parallel top-level tests.
- **The parent's body runs again once per parallel subtest**, in that subtest's process,
  with the parent silent: what it prints before and after the subtest is dropped there, and
  a crash in the parent's code after the subtest is not reported (the serial run reports the
  parent). Keep enumeration (a directory listing, a table) in the parent and the work in the subtests. A
  parent that does not reach the subtest again (a different listing) makes it panic with
  `subtest not reached on rerun`.
- The report and `--json` put each subtest inside its parent, in the order of the source.
  The parent fails if a parallel child fails.
- A panic or `os.exit` in one parallel subtest ends only that one: its siblings still
  report `ok`.
- A parallel subtest inside a parallel subtest runs in place, in the outer one's process.
  `--parallel 1`, `--count N` and the profiles (`--cpuprofile`, `--memprofile`) run every
  parallel subtest in place, in one process; so does a fuzz body, whose input need not repeat.
- `--run 'a/b'` runs `a`, and in it only `b` with its subtests; `--run '/b'` runs every `b`.

## Fuzzing

A fuzz block states a property for every input; `rill test --fuzz` searches for an input
that breaks it.

```rill
import "std/json"

fuzz "parse" (s: String, depth: Int) {
  seed("{}", 1)
  seed("[[1]]", 3)
  let _ = json.parse(s) // a panic or a failed expect is a finding
}
```

- Parameters can be `String` (any bytes), `Int`, `Float`, `Bool` and `[Int]`. The `seed(...)`
  calls at the start are example inputs.
- Plain `rill test` runs every seed and every saved input as a test (`parse#1`,
  `parse#3f9a…`), so a fuzz block is also a regression test.
- `rill test --fuzz parse --fuzztime 30s ./json` builds the package with coverage counters
  and runs `--parallel N` worker processes that mutate inputs; an input that reaches new
  code joins the corpus (kept in `~/.cache/rill/fuzz` for the next run).
- A panic, a failed `expect`, `os.exit` or a hang (no result after 10 s) is a finding: the
  input is minimized, saved to `testdata/fuzz/<name>/` and shown with a command to rerun it.
  Commit the file: from then on it is a test.

```sh
$ rill test --fuzz magic ./magic
FAIL  ./magic    1 test   0.00s
    fuzz magic   72623 execs (1711330/s)   4 corpus   0.04s

failures:

--- FAIL ./magic: fuzz magic
panic: index out of bounds: 5 (len 1)
 --> magic/magic.rl:7
input (magic/testdata/fuzz/magic/0b52ec813ab93c7b):
    s: "FUZZ"
rerun: rill test --run 'magic#0b52ec813ab93c7b'
```

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
- A cover run is never cached, and a package that panicked has no coverage (`[panicked]`):
  it writes no profile, so the merged profile and the total leave its code out (as Go does).

## Running programs

A test of a command-line tool runs the tool. `os.command` builds the child process, `run` starts it and returns an `ExecResult`: `code`, `stdout` and `stderr` as `Bytes`, apart from each other, and `timedOut`.

<!-- include: examples/command.test.rl -->
```swift
import "std/os"

fn text(_ b: Bytes) -> String = String(utf8: b) ?? ""

test "environment, directory and input" {
  let r = os.command(["sh", "-c", "echo \$GREETING from \$(pwd)"]).env(["GREETING=hello"]).cwd("/").run()?
  expect(r.code == 0)
  expect(text(r.stdout).trim() == "hello from /")
  let echo = os.command(["cat"]).stdin("piped in".bytes()).run()?
  expect(text(echo.stdout) == "piped in")
}

test "stdout and stderr apart" {
  let r = os.command(["sh", "-c", "echo out; echo err >&2; exit 2"]).run()?
  expect(r.code == 2, "exit ${r.code}")
  expect(text(r.stdout).trim() == "out")
  expect(text(r.stderr).trim() == "err")
}

test "timeout" {
  let r = os.command(["sleep", "5"]).timeout(100).run()?
  expect(r.timedOut)
  expect(r.code == -1)
}
```

- `env(["NAME=value"])` adds to or overrides the inherited environment; calls accumulate, a later entry wins.
- `cwd(dir)` sets the working directory, `stdin(bytes)` is written in full and closed (without it the child reads `/dev/null`).
- `timeout(ms)` kills the child when it runs out: `timedOut` is true and `code` is -1. Only the child is killed, not what it started.
- A nonzero exit is a `code`, a signal is 128 + n. Only a program that cannot start (or a bad `cwd`) is an error: `cannot run <program>`.
- A package whose tests run a command is never cached: `rill test` cannot see what the child reads.

The API is listed in [the standard library](15-standard-library.md).

## The compiler's own tests

The repository uses golden tests: a program next to its expected output, compiled and
compared by `sh tests/golden.sh` (conventions in [AGENTS.md](https://github.com/rillang/rill/blob/main/AGENTS.md)). The book's
examples use the same conventions ([check.sh](check.sh)).

Not yet: coverage, parallel tests within a package, fuzzing, and doctests
(they come with `rill doc`).

Next: [Concurrency](09-concurrency.md).
