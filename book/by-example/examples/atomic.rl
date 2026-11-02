fn main() {
  let ops = Atomic(0)
  group {
    for _ in 0..<8 {
      spawn {
        for _ in 0..<1000 {
          let _ = ops.add(1)
        }
      }
    }
  }
  print("ops ${ops.load()}")
  let flag = Atomic(false)
  flag.store(true)
  print("${flag.load()} ${ops.compareSwap(8000, 1)} ${ops.load()}")
}
