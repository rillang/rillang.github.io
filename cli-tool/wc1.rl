// Step 1: count the lines of one file named on the command line.
import "std/os"
import "std/fs"

fn main() -> Void! {
  let args = os.args()
  if args.len() != 1 {
    return fail("usage: wc1 <file>")
  }
  let text = fs.readFile(args[0])?
  print("${text.lines().len()} ${args[0]}")
}
