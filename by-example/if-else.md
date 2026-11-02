# If and else

Conditions are `Bool`s; no parentheses, braces always.

<!-- include: examples/if_else.rl -->
```swift
fn sign(_ n: Int) -> String {
  if n < 0 {
    return "negative"
  } else if n == 0 {
    return "zero"
  } else {
    return "positive"
  }
}

fn main() {
  if 7 % 2 == 0 {
    print("7 is even")
  } else {
    print("7 is odd")
  }
  print("${sign(-3)} ${sign(0)} ${sign(8)}")
  let n = 9
  if n > 0 && n < 10 {
    print("$n has one digit")
  }
}
```

`rill run if_else.rl`

<!-- include: examples/if_else.out -->
```text
7 is odd
negative zero positive
9 has one digit
```

`if` is a statement, not an expression.

[Index](README.md)
