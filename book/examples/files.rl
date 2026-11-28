import "std/fs"
import "std/io"

// Writes a file, reads it back and copies it to stdout. defer closes the file at every exit.
fn save(_ path: String, _ text: String) -> Void! {
  var f = fs.create(path)?
  defer { let _ = f.close() }
  io.writeString(&f, text)?
}

fn show(_ path: String) -> Void! {
  var f = fs.open(path)?
  defer { let _ = f.close() }
  var out = io.stdout()
  io.copy(&out, &f)?
}

fn main() -> Void! {
  let dir = fs.tempDir("files")?
  let path = "$dir/hello.txt"
  save(path, "hello, files\n")?
  show(path)?

  // errors name the operation and the file and carry the fs sentinel as cause
  switch fs.open("$dir/missing.txt") {
  case .ok(_): print("opened?")
  case .err(e): print("notFound: ${e.is(fs.notFound)}")
  }

  // a closed file reports io.closed
  var f = fs.open(path)?
  f.close()?
  var buf = Bytes(8)
  switch f.read(&buf) {
  case .ok(_): print("read?")
  case .err(e): print("closed: ${e.is(io.closed)}")
  }
}
