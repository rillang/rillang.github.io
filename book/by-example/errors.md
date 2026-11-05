# Results and errors

`T!` is a value or an error. `fail` creates an error, `?` passes it up, `??` and `if let` skip it, `switch` inspects it.

<!-- include: examples/errors.rl -->
```swift
fn divide(_ a: Int, by b: Int) -> Int! {
  if b == 0 {
    return fail("division by zero")
  }
  return a / b
}

fn average(_ total: Int, _ count: Int) -> String! {
  let avg = divide(total, by: count)?
  return "average $avg"
}

fn main() {
  print("${divide(10, by: 2) ?? -1} ${divide(1, by: 0) ?? -1}")
  switch average(10, 0) {
  case .ok(s): print(s)
  case .err(e): print("failed: ${e.msg}")
  }
  print(average(9, 3) ?? "?")
  if let q = divide(7, by: 7) {
    print("quotient $q")
  }
}
```

`rill run errors.rl`

<!-- include: examples/errors.out -->
```text
5 -1
failed: division by zero
average 3
quotient 1
```

[Index](README.md)
