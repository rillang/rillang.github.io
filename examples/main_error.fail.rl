fn load(_ path: String) -> String! {
  let text = readFile(path)?
  return text.trim()
}

// main may return Void!: an error ends the program with exit code 1
fn main() -> Void! {
  print("loading")
  let config = load("/nonexistent/rill-book.conf")?
  print(config)
}
