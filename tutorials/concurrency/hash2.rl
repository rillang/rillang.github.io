// Step 2: the same with parMap: every core hashes, the order stays.
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
    return fail("usage: hash2 <dir>")
  }
  let start = time.monotonic()
  let files = fs.walk(args[0])?
  // [String] -> [Entry!]: an error is a value like any other
  let results = files.parMap { hashFile($) }
  var bytes = 0
  for r in results {
    let e = r?
    bytes += e.size
    print("${e.hash}  ${e.path}")
  }
  eprint("$bytes bytes in ${time.text(time.since(start))}")
}
