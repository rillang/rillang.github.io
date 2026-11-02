fn work(_ id: Int) -> Int {
  var x = 0
  for i in 0..<100000 {
    x += i % (id + 1)
  }
  return x
}

fn main() {
  let done = Atomic(0)
  group {
    for id in 0..<4 {
      spawn {
        if work(id) >= 0 {
          let _ = done.add(1)
        }
      }
    }
  }
  // every task has finished here
  print("${done.load()} tasks done")
}
