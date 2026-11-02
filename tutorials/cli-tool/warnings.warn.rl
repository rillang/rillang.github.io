import "std/strings"
import "std/fs"

fn main() -> Void! {
  var name = "fox.txt"
  let unused = 42
  let text = fs.readFile("testdata/" + name)?
  print("${text.len()} bytes")
}
