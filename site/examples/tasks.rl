fn main() {
  let results = Channel<Int>(capacity: 3)
  group {
    for n in [10, 20, 30] {
      spawn { results.send(n * n) }
    }
  }
  results.close()
  var total = 0
  for r in results {
    total += r
  }
  print("total $total")
}
