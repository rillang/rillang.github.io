# Command-line arguments

`args()` returns the arguments after the file name. `eprint` writes to stderr.

<!-- include: examples/args.rl -->
```swift
// try: rill run args.rl one two

import "std/os"

fn main() {
  let a = os.args()
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

`os.args()` comes from `std/os`.

[Index](README.md)
