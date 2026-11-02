struct Stats { hits: Int, names: [String] }

fn main() {
  let stats = Mutex(Stats(hits: 0, names: []))
  let counter = Atomic(0)
  group {
    for i in 0..<4 {
      spawn {
        for _ in 0..<1000 {
          let _ = counter.add(1)
        }
        // the value exists only inside the lock block
        stats.lock { s in
          s.hits += 1
          s.names.push("task$i")
        }
      }
    }
  }
  print("${counter.load()}")
  // get() returns a copy
  let snap = stats.get()
  print("${snap.hits} ${snap.names.len()}")
  print("${counter.compareSwap(4000, 0)} ${counter.load()}")
}
