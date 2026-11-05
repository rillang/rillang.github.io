import "std/strings"
import "std/fs"

fn main() -> Void! {
  let unused = 42
  let text = fs.readFile("testdata/fox.txt")?
  print("${text.len()} bytes")
}
