# Matching one case

Patterns live in `switch`. To act on one case, give the others an empty body; `let` and
`for` bind names, and a `switch` inside the loop picks elements.

<!-- include: examples/one_case.rl -->
```swift
struct Point { x: Int, y: Int }

enum Token {
  case num(Int)
  case word(String)
}

// a pattern with a fallback
fn firstNumber(_ tokens: [Token]) -> Int = switch tokens {
  case [.num(n), ...]: n
  default: -1
}

fn main() {
  let t: Token = .word("let")
  switch t {
  case .word(w): print("word $w")
  case .num(_):
  }

  // let and for bind names: read the fields
  let p = Point(x: 1, y: 2)
  let px = p.x
  print("$px ${p.y}")

  // visit only some elements: switch inside the loop
  let tokens: [Token] = [.num(4), .word("x"), .num(5)]
  var sum = 0
  for tok in tokens {
    switch tok {
    case .num(n): sum += n
    case .word(_): continue
    }
  }
  print("sum $sum")
  print("${firstNumber(tokens)} ${firstNumber([])}")
}
```

`rill run one_case.rl`

<!-- include: examples/one_case.out -->
```text
word let
1 2
sum 9
4 -1
```

Name the cases you skip rather than writing `default:`: when a `default` would cover only
one or two cases, the compiler asks for their names (W0007).

[Index](README.md)
