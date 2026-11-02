# Variables

`let` declares a constant, `var` a variable. Types are inferred inside functions and can be written after a colon.

<!-- include: examples/variables.rl -->
```swift
fn main() {
  let a = "initial"
  print(a)

  let b: Int = 1
  let c = 2
  print("${b + c}")

  var d = 10
  d -= 3
  d *= 2
  print("$d")

  var e: [String] = []
  e.push("x")
  print("${e.len()}")
}
```

`rill run variables.rl`

<!-- include: examples/variables.out -->
```text
initial
3
14
1
```

An empty array literal needs a type: `var e: [String] = []`.

[Index](README.md)
