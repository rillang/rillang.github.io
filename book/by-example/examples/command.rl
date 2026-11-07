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
