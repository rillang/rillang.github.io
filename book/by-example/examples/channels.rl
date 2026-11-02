fn main() {
  let jobs = Channel<String>(capacity: 0)
  let lengths = Channel<Int>(capacity: 3)
  group {
    spawn {
      for j in jobs {
        lengths.send(j.len())
      }
      lengths.close()
    }
    for w in ["one", "three", "seven"] {
      jobs.send(w)
    }
    jobs.close()
  }
  var all: [String] = []
  for n in lengths {
    all.push("$n")
  }
  print(all.join(" "))
}
