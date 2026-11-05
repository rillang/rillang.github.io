#!/usr/bin/env rill
// todo: every TODO line in the text files below a directory, as path:line: text.
import "std/fs"
import "std/os"
import "std/path"
import "std/strings"

fn main() -> Void! {
  let args = os.args()
  let root = if args.len() > 0 { args[0] } else { "." }
  var found = 0
  for file in fs.walk(root)? {
    if path.ext(file) != ".md" && path.ext(file) != ".txt" {
      continue
    }
    let lines = fs.readFile(file)?.lines()
    for i in 0..<lines.len() {
      if strings.contains(lines[i], "TODO") {
        print("$file:${i + 1}: ${lines[i].trim()}")
        found += 1
      }
    }
  }
  print("$found TODOs")
}
