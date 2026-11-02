# Modules

`import "lib/greet"` loads the directory `lib/greet/` next to this file (every `.rl` file in it is part of the module). Only `pub` items are visible. The module:

<!-- include: examples/lib/greet/greet.rl -->
```swift
pub fn hello(_ name: String) -> String = "${prefix()}, $name"

// not pub: only this module can call it
fn prefix() -> String = "hello"
```

<!-- include: examples/modules.rl -->
```swift
import "lib/greet"

fn main() {
  print(greet.hello("modules"))
}
```

`rill run modules.rl`

<!-- include: examples/modules.out -->
```text
hello, modules
```

[Index](README.md)
