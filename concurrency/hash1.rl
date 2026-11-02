// Step 1: hash every file below a directory, one after the other.
import "std/os"
import "std/fs"
import "std/hash/sha256"
import "std/time"

struct Entry { path: String, hash: String, size: Int }

fn hashFile(_ p: String) -> Entry! {
  let data = fs.readFile(p)?
  return Entry(path: p, hash: sha256.sum(data), size: data.len())
}

fn main() -> Void! {
  let args = os.args()
  if args.len() != 1 {
    return fail("usage: hash1 <dir>")
  }
  let start = time.monotonic()
  var bytes = 0
  for f in fs.walk(args[0])? {
    let e = hashFile(f)?
    bytes += e.size
    print("${e.hash}  ${e.path}")
  }
  eprint("$bytes bytes in ${time.text(time.since(start))}")
}
