enum Expr {
  case num(Int)
  case add(Expr, Expr)
  case neg(Expr)
}

fn eval(_ e: Expr) -> Int {
  switch e {
  case .num(n): return n
  }
}

fn main() {
  print("${eval(.num(1))}")
}
