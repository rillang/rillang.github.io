# Functions

Parameter and result types are always written. A body can be a single expression after `=`.

<!-- include: examples/functions.rl -->
```swift
fn plus(_ a: Int, _ b: Int) -> Int {
  return a + b
}

// a single expression can be the whole body
fn plusPlus(_ a: Int, _ b: Int, _ c: Int) -> Int = a + b + c

fn log(_ msg: String) {
  print("log: $msg")
}

fn main() {
  print("${plus(1, 2)}")
  print("${plusPlus(1, 2, 3)}")
  log("done")
}
```

`rill run functions.rl`

<!-- include: examples/functions.out -->
```text
3
6
log: done
```

[Index](README.md)
