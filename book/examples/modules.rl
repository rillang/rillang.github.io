// the path is relative to this file, without .rl
import "lib/geometry"

fn main() {
  let v = geometry.Vec2(x: 3, y: 4)
  print("${geometry.length2(v)}")
  let s: geometry.Shape = .rect(2, 5)
  print("${geometry.area(s)} ${geometry.area(geometry.Shape.square(3))}")
  // UFCS looks in the current module only: v.length2() would not find geometry.length2
  let f: (geometry.Vec2) -> Int = geometry.length2
  print("${f(v)}")
}
