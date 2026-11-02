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
  expect(clamp(3, low: 0, high: 2) == 3)
}
```

`rill test testing.test.rl` prints:

<!-- include: examples/testing.test.out -->
```text
ok   add
ok   clamp keeps values in range
FAIL a failing test reports every failed expect
  expect failed at book/examples/testing.test.rl:28
  expect failed at book/examples/testing.test.rl:29
2 passed, 1 failed
```

- `test "name" { … }` declares a test. Tests see private (non-`pub`) declarations.
- `expect(condition)` records a failure with its line and continues the test, so one run
  reports every failed expectation. `expect` outside a test is error E0020.
- `rill test` runs the tests and not `main`; it exits with code 1 if a test failed.
- `rill run` and `rill build` ignore `test` blocks.
- A panic inside a test ends the run like any panic.

There is no special assertion library: `expect(a == b)` with Rill's structural `==` covers
structs, enums, arrays and optionals.

## The compiler's own tests

The repository uses golden tests: a program next to its expected output, compiled and
compared by `sh tests/golden.sh` (conventions in [AGENTS.md](https://github.com/rillang/rill/blob/main/AGENTS.md)). The book's
examples use the same conventions ([check.sh](check.sh)).

Not yet: doctests, richer failure output for `expect` (showing both sides), filtering
tests by name, and benchmarks.

Next: [Concurrency](09-concurrency.md).
