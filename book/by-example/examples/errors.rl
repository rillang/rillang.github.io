fn divide(_ a: Int, by b: Int) -> Int! {
  if b == 0 {
    return fail("division by zero")
  }
  return a / b
}

fn average(_ total: Int, _ count: Int) -> String! {
  let avg = divide(total, by: count)?
  return "average $avg"
}

fn main() {
  let none = -1
  print("${divide(10, by: 2) ?? none} ${divide(1, by: 0) ?? none}")
  switch average(10, 0) {
  case .ok(s): print(s)
  case .err(e): print("failed: ${e.msg}")
  }
  print(average(9, 3) ?? "?")
  if let q = divide(7, by: 7) {
    print("quotient $q")
  }
}
