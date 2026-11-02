# Command-line arguments

`args()` returns the arguments after the file name. `eprint` writes to stderr.

<!-- include: examples/args.rl -->
```swift
// try: rill run args.rl one two
fn main() {
  let a = args()
  if a.len() == 0 {
    eprint("usage: args <words...>")
    print("no arguments")
    return
  }
  print("${a.len()} arguments: ${a.join(", ")}")
}
```

`rill run args.rl`

<!-- include: examples/args.out -->
```text
no arguments
```

`args` moves to `std/os` with the planned standard library.

[Index](README.md)
