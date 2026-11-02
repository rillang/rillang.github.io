fn main() {
  let urls = ["/", "/docs", "/blog", "/about"]
  let sizes = Channel<Int>(capacity: 4)
  group {
    for u in urls {
      spawn { sizes.send(u.len() * 100) }
    }
  }
  sizes.close()
  var total = 0
  for s in sizes {
    total += s
  }
  let squares = [1, 2, 3, 4].parMap { $ * $ }
  print("total $total, squares ${squares[3]}")
}
