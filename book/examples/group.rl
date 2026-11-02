fn fib(_ n: Int) -> Int {
  if n < 2 {
    return n
  }
  return fib(n - 1) + fib(n - 2)
}

fn main() {
  let results = Channel<Int>(capacity: 8)
  // group waits until every task spawned inside it has finished
  group {
    for i in 0..<4 {
      spawn { results.send(fib(20 + i)) }
    }
  }
  results.close()
  var sum = 0
  for r in results {
    sum += r
  }
  print("sum $sum")
}
