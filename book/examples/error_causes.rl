import "std/fs"

// a sentinel: one error value that callers can recognize
let badPort = Error("port is not a number")

fn loadPort(_ path: String) -> Int! {
  // a missing file means the default; anything else gets context and propagates
  let text = switch fs.readFile(path) {
    case .ok(t): t
    case .err(fs.notFound): "8080"
    case .err(e): return e.context("load $path")
  }
  guard let n = text.trim().toInt() else {
    return fail("load $path", cause: badPort)
  }
  return n
}

fn main() -> Void! {
  print("${loadPort("/nonexistent/app.conf")?}")
  let dir = fs.tempDir("book")?
  fs.writeFile("$dir/app.conf", "eighty")?
  switch loadPort("$dir/app.conf") {
  case .ok(n): print("port $n")
  case .err(e):
    print("${e.is(badPort)} ${e.cause != nil}")
  }
  // context on a result adds a layer only when it holds an error
  let n = loadPort("/nonexistent/x").context("start")?
  print("$n")
  fs.removeAll(dir)?
}
