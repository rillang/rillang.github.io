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

[Index](README.md)
