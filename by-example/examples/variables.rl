fn main() {
  let a = "initial"
  print(a)

  let b: Int = 1
  let c = 2
  print("${b + c}")

  var d = 10
  d -= 3
  d *= 2
  print("$d")

  var e: [String] = []
  e.push("x")
  print("${e.len()}")
}
