# Mutex

A `Mutex` owns a value; `lock` gives one task at a time access, `get` returns a copy.

<!-- include: examples/mutex.rl -->
```swift
fn main() {
  let visits = Mutex(Map<String, Int>())
  let pages = ["/", "/about", "/", "/", "/about"]
  group {
    for p in pages {
      spawn {
        visits.lock { m in m[p] = (m[p] ?? 0) + 1 }
      }
    }
  }
  let snapshot = visits.get()
  print("/ ${snapshot["/"] ?? 0}, /about ${snapshot["/about"] ?? 0}")
}
```

`rill run mutex.rl`

<!-- include: examples/mutex.out -->
```text
/ 3, /about 2
```

Channel operations, nested locks and `spawn` are not allowed inside `lock` (E0026).

[Index](README.md)
