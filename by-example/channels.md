# Channels

Channels pass values between tasks. Capacity 0 is a rendezvous. `for x in ch` receives until the channel is closed.

<!-- include: examples/channels.rl -->
```swift
fn main() {
  let jobs = Channel<String>(capacity: 0)
  let lengths = Channel<Int>(capacity: 3)
  group {
    spawn {
      for j in jobs {
        lengths.send(j.len())
      }
      lengths.close()
    }
    for w in ["one", "three", "seven"] {
      jobs.send(w)
    }
    jobs.close()
  }
  var all: [String] = []
  for n in lengths {
    all.push("$n")
  }
  print(all.join(" "))
}
```

`rill run channels.rl`

<!-- include: examples/channels.out -->
```text
3 5 5
```

[Index](README.md)
