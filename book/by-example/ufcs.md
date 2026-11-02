# UFCS

Rill has no methods: `x.f(y)` calls `f(x, y)`, so any function can be chained.

<!-- include: examples/ufcs.rl -->
```swift
fn shout(_ s: String) -> String = s + "!"

fn repeat(_ s: String, times n: Int) -> String {
  var out = ""
  for _ in 0..<n {
    out = out + s
  }
  return out
}

fn main() {
  // f(x, y) can be written x.f(y)
  print(repeat(shout("hey"), times: 2))
  print("hey".shout().repeat(times: 2))
}
```

`rill run ufcs.rl`

<!-- include: examples/ufcs.out -->
```text
hey!hey!
hey!hey!
```

[Index](README.md)
