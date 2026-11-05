enum Expr {
  case num(Int)
  case add(Expr, Expr)
  case mul(Expr, Expr)
}

fn eval(_ e: Expr) -> Int = switch e {
  case .num(n): n
  case .add(a, b): eval(a) + eval(b)
  case .mul(a, b): eval(a) * eval(b)
}

fn main() {
  let e: Expr = .add(.num(2), .mul(.num(3), .num(4)))
  let big = [1, 2, 3, 4].map { $ * 10 }.filter { $ > 15 }
  print("result ${eval(e)}, big ${big.len()}")
}

test "eval follows the tree" {
  expect(eval(.mul(.num(2), .num(5))) == 10)
}
