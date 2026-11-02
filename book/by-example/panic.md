# Panics

`panic` is for bugs: it prints the message and the source line, and exits with code 101.

<!-- include: examples/panic.panic.rl -->
```swift
// panics are for bugs: they print a message and exit with code 101.
// RILL_BACKTRACE=1 adds the call chain.
fn checkedAge(_ n: Int) -> Int {
  if n < 0 {
    panic("negative age: $n")
  }
  return n
}

fn main() {
  print("${checkedAge(30)}")
  print("${checkedAge(-1)}")
}
```

`rill run panic.panic.rl` (stderr)

<!-- include: examples/panic.panic.err -->
```text
panic: negative age: -1
 --> book/by-example/examples/panic.panic.rl:5
```

[Index](README.md)
