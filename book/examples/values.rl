enum Shape {
  case circle(Int)
  case square(Int)
  case dot
}

// a function whose whole body is a value
fn sign(_ n: Int) -> Int = if n < 0 { -1 } else if n == 0 { 0 } else { 1 }

fn name(_ s: Shape) -> String = switch s {
  case .circle(_): "circle"
  case .square(_): "square"
  case .dot: "dot"
}

fn half(_ n: Int) -> Int? {
  // a branch may leave instead of giving a value
  let h = if n % 2 == 0 { n / 2 } else { return nil }
  return h
}

fn main() {
  let wide = true
  let width = if wide { 120 } else { 80 }
  let size = switch Shape.square(3) {
    case .circle(r): 3 * r * r
    case .square(a): a * a
    case .dot: 0
  }
  print("$width $size ${sign(-4)} ${name(.dot)}")
  print("${half(10) ?? -1} ${half(7) ?? -1}")
}
