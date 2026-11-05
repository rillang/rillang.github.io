// the path is relative to this file, without .rl
import "lib/geometry"

fn main() {
  let v = geometry.Vec2(x: 3, y: 4)
  print("${v.length2()}") // UFCS: length2 is pub in the module declaring Vec2
  let s: geometry.Shape = .rect(2, 5)
  print("${geometry.area(s)} ${geometry.area(geometry.Shape.square(3))}")
  let f: (geometry.Vec2) -> Int = geometry.length2
  print("${f(v)}")
}
