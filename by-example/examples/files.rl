// readFile, writeFile, mkdirAll, fileExists and readDir are global builtins today;
// the planned standard library moves them to std/fs.
fn main() -> Void! {
  let dir = "/tmp/rill-by-example"
  mkdirAll(dir)?
  writeFile("$dir/notes.txt", "first\nsecond\n")?
  writeFile("$dir/empty.txt", "")?
  let text = readFile("$dir/notes.txt")?
  print("${text.lines().len()} lines, starts with ${text.lines()[0]}")
  print("${fileExists("$dir/notes.txt")} ${fileExists("$dir/missing.txt")}")
  print(readDir(dir)?.join(" "))
  switch readFile("$dir/missing.txt") {
  case .ok(_): print("unexpected")
  case .err(e): print(e.msg)
  }
}
