fn main() {
  // a pipeline: producer -> squarer -> main
  let numbers = Channel<Int>(capacity: 4)
  let squares = Channel<Int>(capacity: 4)
  group {
    spawn {
      for i in 1..<6 {
        numbers.send(i)
      }
      numbers.close()
    }
    spawn {
      for n in numbers {
        squares.send(n * n)
      }
      squares.close()
    }
    var total = 0
    for s in squares {
      total += s
    }
    print("total $total")
  }

  // capacity 0 is a rendezvous; recv returns nil once closed and drained
  let left = Channel<String>(capacity: 2)
  left.send("a")
  left.send("b")
  left.close()
  print("${left.recv() ?? "-"} ${left.recv() ?? "-"} ${left.recv() ?? "-"}")
}
