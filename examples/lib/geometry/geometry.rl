// A module: one file. Only `pub` items are visible to importers.

pub struct Vec2 { x: Int, y: Int }

pub enum Shape {
  case square(Int)
  case rect(Int, Int)
}

pub fn area(_ s: Shape) -> Int {
  switch s {
  case .square(n): return square(n)
  case .rect(w, h): return w * h
  }
}

pub fn square(_ n: Int) -> Int = n * n

pub fn length2(_ v: Vec2) -> Int = square(v.x) + square(v.y)

fn helper() -> Int = 1

test "area of a square" {
  expect(area(.square(3)) == 9)
  expect(helper() == 1)
}
