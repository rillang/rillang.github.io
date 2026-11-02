fn main() {
  for i in 0..<3 {
    print("range $i")
  }

  for word in ["red", "green"] {
    print("word $word")
  }

  var n = 1
  while n < 100 {
    n *= 3
  }
  print("first power of 3 above 100: $n")

  for i in 0..<10 {
    if i % 2 == 0 {
      continue
    }
    if i > 5 {
      break
    }
    print("odd $i")
  }
}
