import "std/os"

fn text(_ b: Bytes) -> String = String(utf8: b) ?? ""

test "environment, directory and input" {
  let r = os.command(["sh", "-c", "echo \$GREETING from \$(pwd)"]).env(["GREETING=hello"]).cwd("/").run()?
  expect(r.code == 0)
  expect(text(r.stdout).trim() == "hello from /")
  let echo = os.command(["cat"]).stdin("piped in".bytes()).run()?
  expect(text(echo.stdout) == "piped in")
}

test "stdout and stderr apart" {
  let r = os.command(["sh", "-c", "echo out; echo err >&2; exit 2"]).run()?
  expect(r.code == 2, "exit ${r.code}")
  expect(text(r.stdout).trim() == "out")
  expect(text(r.stderr).trim() == "err")
}

test "timeout" {
  let r = os.command(["sleep", "5"]).timeout(100).run()?
  expect(r.timedOut)
  expect(r.code == -1)
}
