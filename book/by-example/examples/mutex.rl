fn main() {
  let visits = Mutex(Map<String, Int>())
  let pages = ["/", "/about", "/", "/", "/about"]
  group {
    for p in pages {
      spawn {
        visits.lock { m in m[p] = (m[p] ?? 0) + 1 }
      }
    }
  }
  let snapshot = visits.get()
  print("/ ${snapshot["/"] ?? 0}, /about ${snapshot["/about"] ?? 0}")
}
