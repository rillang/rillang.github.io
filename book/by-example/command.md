# Running a command

`os.command` builds a child process: `env`, `cwd`, `stdin` and `timeout` each return a changed copy, `run` starts it. A nonzero exit is a result, not an error; only a failure to start is.

<!-- include: examples/command.rl -->
```swift
// os.command builds a child process: env, cwd, stdin and a timeout, then run().

import "std/os"

fn text(_ b: Bytes) -> String = String(utf8: b) ?? ""

fn main() -> Void! {
  let r = os.command(["sh", "-c", "echo \$GREETING from \$(pwd); echo oops >&2; exit 3"])
    .env(["GREETING=hello"])
    .cwd("/")
    .run()?
  print("code ${r.code}")
  print("stdout: ${text(r.stdout).trim()}")
  print("stderr: ${text(r.stderr).trim()}")

  let echo = os.command(["cat"]).stdin("piped in".bytes()).run()?
  print("cat: ${text(echo.stdout)}")

  let slow = os.command(["sleep", "5"]).timeout(100).run()?
  print("timed out ${slow.timedOut}, code ${slow.code}")

  switch os.command(["no-such-program"]).run() {
  case .ok(_): print("ran")
  case .err(e): print(e.msg)
  }
}
```

`rill run command.rl`

<!-- include: examples/command.out -->
```text
code 3
stdout: hello from /
stderr: oops
cat: piped in
timed out true, code -1
cannot run no-such-program
```

[Index](README.md)
