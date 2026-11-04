enum Shape {
  case circle(Float)
  case rect(Float, Float)
  case dot
}

fn area(_ s: Shape) -> Float {
  switch s {
  case .circle(r): return 3.14 * r * r
  case .rect(w, h): return w * h
  case .dot: return 0.0
  }
}

test "a rectangle is width times height" {
  expect(area(.rect(2.0, 3.0)) == 6.0)
}
