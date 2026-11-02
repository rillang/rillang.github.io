// gen <dir> <files>: writes a tree of files with deterministic pseudo-random text.
import "std/os"
import "std/fs"
import "std/path"
import "std/fmt"

fn main() -> Void! {
  let args = os.args()
  if args.len() != 2 {
    return fail("usage: gen <dir> <files>")
  }
  guard let n = args[1].toInt() else {
    return fail("not a number: ${args[1]}")
  }
  var seed = 42
  var bytes = 0
  for i in 0..<n {
    let dir = path.join(args[0], "d" + fmt.zero(i / 100, width: 2))
    fs.mkdirAll(dir)?
    // a linear congruential generator: the same tree on every run
    seed = (seed * 1103515245 + 12345) % 2147483648
    let size = 1000 + seed % 60000
    var sb = StringBuilder()
    for j in 0..<size {
      sb.addByte('a' + (seed + j * 7) % 26)
    }
    fs.writeFile(path.join(dir, "f" + fmt.zero(i, width: 4) + ".txt"), sb.build())?
    bytes += size
  }
  print("wrote $n files, $bytes bytes")
}
