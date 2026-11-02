// the label is what the caller writes, the name what the body uses
fn send(_ message: String, to person: String, times n: Int) -> String {
  var out = ""
  for _ in 0..<n {
    out = "$out$message "
  }
  return "${out.trim()} -> $person"
}

// without `_`, the parameter name is also the label
fn rect(width: Int, height: Int) -> Int = width * height

fn main() {
  print(send("hi", to: "ana", times: 2))
  print("${rect(width: 2, height: 3)}")
}
