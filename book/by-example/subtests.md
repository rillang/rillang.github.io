# Subtests

A `test` statement inside a test is a subtest. Its full name joins the levels with `/`, and
a failure names it.

<!-- include: examples/subtests.test.rl -->
```swift
fn double(_ n: Int) -> Int = n * 2

fn main() {
  print("${double(4)}")
}

test "double" {
  for n in [0, 1, 5] {
    test "n=${n}" {
      expect(double(n) == n + n)
    }
  }
}
```

`rill test subtests.test.rl`

<!-- include: examples/subtests.test.out -->
```text
ok    book/by-example/examples/subtests.test.rl    4 tests   0.00s

result: ok. 4 passed; 1 module in 0.00s
```

## Parallel

`parallel` runs a subtest in a process of its own, next to the others. The parent's body
runs again in each of those processes, so keep it to enumeration and do the work inside the
subtests.

<!-- include: examples/subtests_parallel.test.rl -->
```swift
fn square(_ n: Int) -> Int = n * n

fn main() {
  print("${square(4)}")
}

// The parent runs again once per parallel subtest: it only lists the inputs.
test "square" {
  for n in [1, 2, 3] {
    test "n=${n}" parallel {
      expect(square(n) == n * n)
    }
  }
}
```

`rill test subtests_parallel.test.rl`

<!-- include: examples/subtests_parallel.test.out -->
```text
ok    book/by-example/examples/subtests_parallel.test.rl    4 tests   0.00s

result: ok. 4 passed; 1 module in 0.00s
```

`--run 'square/n=2'` runs one subtest: the pattern splits at `/`, one regex per level.

[Index](README.md)
