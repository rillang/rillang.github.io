enum Color {
  case red
  case green
  case blue
}

// cases can carry values, and enums can be recursive
enum Expr {
  case num(Int)
  case add(Expr, Expr)
  case neg(Expr)
}

fn name(_ c: Color) -> String {
  switch c {
  case .red: return "red"
  case .green: return "green"
  case .blue: return "blue"
  }
}

fn eval(_ e: Expr) -> Int {
  switch e {
  case .num(n): return n
  case .add(a, b): return eval(a) + eval(b)
  case .neg(x): return -eval(x)
  }
}

fn main() {
  // `.case` works where the type is known; otherwise write Type.case
  let c: Color = .green
  print("${name(c)} ${name(Color.blue)}")
  let e = Expr.add(.num(2), .neg(.num(5)))
  print("${eval(e)}")
  print("${e == .add(.num(2), .neg(.num(5)))}")
}
