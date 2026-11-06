# Files

Reading and writing files returns results, so `?` handles errors.

<!-- include: examples/files.rl -->
```swift
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
```

`rill run files.rl`

<!-- include: examples/files.out -->
```text
2 lines, starts with first
true false
empty.txt notes.txt
read /tmp/rill-by-example/missing.txt: no such file
```

[Index](README.md)
