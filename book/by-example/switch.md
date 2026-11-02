# Switch

`switch` picks the first matching case. Ranges, alternatives and `where` guards work on any value.

<!-- include: examples/switch.rl -->
```swift
fn kind(_ c: Int) -> String {
  switch c {
  case '0'..<':': return "digit"
  case ' ', '\t', '\n': return "space"
  case 'a'..<'{', 'A'..<'[': return "letter"
  default: return "other"
  }
}

fn main() {
  print("${kind('7')} ${kind(' ')} ${kind('q')} ${kind('#')}")
  let command = "stop"
  switch command {
  case "go": print("going")
  case "stop": print("stopping")
  default: print("unknown")
  }
  let n = 15
  switch n {
  case x where x % 15 == 0: print("fizzbuzz")
  case x where x % 3 == 0: print("fizz")
  default: print("$n")
  }
}
```

`rill run switch.rl`

<!-- include: examples/switch.out -->
```text
digit space letter other
stopping
fizzbuzz
```

Character literals are `Int`s, so `'a'..<'{'` is a range of bytes.

[Index](README.md)
