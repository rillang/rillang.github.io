fn main() {
  var total = 0
  total += 1
  group {
    spawn { print("$total") }
  }
}
