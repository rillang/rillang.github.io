# Tests

`test` blocks sit next to the code. `rill test` runs them; `rill run` ignores them.

<!-- include: examples/tests.test.rl -->
```swift
fn isLeap(_ year: Int) -> Bool {
  return year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)
}

fn main() {
  print("${isLeap(2024)}")
}

test "leap years" {
  expect(isLeap(2024))
  expect(isLeap(2000))
}

test "common years" {
  expect(!isLeap(1900))
  expect(!isLeap(2023))
}
```

`rill test tests.test.rl`

<!-- include: examples/tests.test.out -->
```text
ok    book/by-example/examples/tests.test.rl    2 tests   0.00s

result: ok. 2 passed; 1 module in 0.00s
```

[Index](README.md)
