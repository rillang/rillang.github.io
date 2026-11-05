import "std/fs"

fn main() -> Void! {
  var name = "fox.txt"
  let text = fs.readFile("testdata/" + name)?
  print("${text.len()} bytes")
}
