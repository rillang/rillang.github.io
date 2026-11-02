# Atomic

`Atomic` holds an `Int` or a `Bool` for lock-free counters and flags. `add` returns the new value.

<!-- include: examples/atomic.rl -->
```swift
fn main() {
  let ops = Atomic(0)
  group {
    for _ in 0..<8 {
      spawn {
        for _ in 0..<1000 {
          let _ = ops.add(1)
        }
      }
    }
  }
  print("ops ${ops.load()}")
  let flag = Atomic(false)
  flag.store(true)
  print("${flag.load()} ${ops.compareSwap(8000, 1)} ${ops.load()}")
}
```

`rill run atomic.rl`

<!-- include: examples/atomic.out -->
```text
ops 8000
true true 1
```

[Index](README.md)
