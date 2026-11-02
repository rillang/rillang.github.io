fn find(_ xs: [String], _ want: String) -> Int? {
  for i in 0..<xs.len() {
    if xs[i] == want {
      return i
    }
  }
  return nil
}

fn main() {
  let names = ["ana", "bo"]
  print("${find(names, "bo") ?? -1} ${find(names, "cy") ?? -1}")
  if let i = find(names, "ana") {
    print("ana at $i")
  }
  let port: Int? = "8080".toInt()
  guard let p = port else {
    print("no port")
    return
  }
  print("port $p")
}
