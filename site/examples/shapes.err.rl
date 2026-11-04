enum Shape {
  case circle(Float)
  case rect(Float, Float)
  case dot
}

fn area(_ s: Shape) -> Float {
  switch s {
  case .circle(r): return 3.14 * r * r
  case .rect(w, h): return w * h
  }
}

fn main() {
  print("${area(.dot)}")
}
