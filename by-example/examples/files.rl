// Files and directories come from std/fs.

import "std/fs"

fn main() -> Void! {
  let dir = "/tmp/rill-by-example"
  fs.mkdirAll(dir)?
  fs.writeFile("$dir/notes.txt", "first\nsecond\n")?
  fs.writeFile("$dir/empty.txt", "")?
  let text = fs.readFile("$dir/notes.txt")?
  print("${text.lines().len()} lines, starts with ${text.lines()[0]}")
  print("${fs.exists("$dir/notes.txt")} ${fs.exists("$dir/missing.txt")}")
  print(fs.readDir(dir)?.join(" "))
  switch fs.readFile("$dir/missing.txt") {
  case .ok(_): print("unexpected")
  case .err(e): print(e.msg)
  }
}
