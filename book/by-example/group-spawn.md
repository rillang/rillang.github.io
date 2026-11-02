# group and spawn

`group` waits for every task `spawn`ed inside it. Tasks run on all cores.

<!-- include: examples/group_spawn.rl -->
```swift
fn work(_ id: Int) -> Int {
  var x = 0
  for i in 0..<100000 {
    x += i % (id + 1)
  }
  return x
}

fn main() {
  let done = Atomic(0)
  group {
    for id in 0..<4 {
      spawn {
        if work(id) >= 0 {
          let _ = done.add(1)
        }
      }
    }
  }
  // every task has finished here
  print("${done.load()} tasks done")
}
```

`rill run group_spawn.rl`

<!-- include: examples/group_spawn.out -->
```text
4 tasks done
```

Captured `let` values are copied into the task; capturing a `var` is error E0025.

[Index](README.md)
