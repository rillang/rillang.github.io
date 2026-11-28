fn work(_ fail: Bool) -> Int {
  print("open")
  defer { print("close") }
  defer { print("flush") }
  if fail {
    print("early exit")
    return 1
  }
  print("done")
  return 0
}

fn main() {
  let a = work(false)
  let b = work(true)
  print("$a $b")
}
