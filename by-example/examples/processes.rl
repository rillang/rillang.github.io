// run, runCapture and env are global builtins today (planned: std/os)
fn main() -> Void! {
  let out = runCapture(["echo", "from a child process"])?
  print(out.trim())
  let code = run(["sh", "-c", "exit 3"])?
  print("exit code $code")
  print("HOME set: ${env("HOME") != nil}")
  print(env("RILL_SURELY_UNSET") ?? "unset")
}
