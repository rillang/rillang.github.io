# Processes and environment

`run` returns a child's exit code, `runCapture` its stdout; `env` reads a variable.

<!-- include: examples/processes.rl -->
```swift
// Processes and the environment come from std/os.

import "std/os"

fn main() -> Void! {
  let out = os.runCapture(["echo", "from a child process"])?
  print(out.trim())
  let code = os.run(["sh", "-c", "exit 3"])?
  print("exit code $code")
  print("HOME set: ${os.env("HOME") != nil}")
  print(os.env("RILL_SURELY_UNSET") ?? "unset")
}
```

`rill run processes.rl`

<!-- include: examples/processes.out -->
```text
from a child process
exit code 3
HOME set: true
unset
```

[Index](README.md)
