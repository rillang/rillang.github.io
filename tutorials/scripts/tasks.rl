#!/usr/bin/env rill
// tasks: runs the commands of tasks.json in order and stops at the first that fails,
// with the time each one took.
import "std/fs"
import "std/json"
import "std/os"
import "std/time"

fn main() -> Void! {
  let args = os.args()
  let file = if args.len() > 0 { args[0] } else { "tasks.json" }
  let tasks = json.parse(fs.readFile(file)?)?
  for t in json.items(json.get(tasks, "tasks")) {
    let name = json.str(json.get(t, "name")) ?? "?"
    let argv = json.items(json.get(t, "run")).map { a in json.str(a) ?? "" }
    let start = time.monotonic()
    let code = os.run(argv)?
    print("== $name: exit $code in ${time.text(time.since(start))}")
    if code != 0 {
      os.exit(code)
    }
  }
}
