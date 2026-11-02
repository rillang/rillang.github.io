struct Point { x: Int, y: Int }

struct Line {
  from: Point
  to: Point
  label: String?
}

fn length2(_ l: Line) -> Int {
  let dx = l.to.x - l.from.x
  let dy = l.to.y - l.from.y
  return dx * dx + dy * dy
}

fn main() {
  // construction names every field
  var p = Point(x: 1, y: 2)
  p.x = 10

  // structs are values: q is a copy
  let q = p
  p.y = 0
  print("p=(${p.x}, ${p.y}) q=(${q.x}, ${q.y})")

  var l = Line(from: Point(x: 0, y: 0), to: Point(x: 3, y: 4), label: nil)
  print("${length2(l)} ${l.length2()}")
  l.to.x = 6
  print("${length2(l)}")

  // == compares structurally
  print("${q == Point(x: 10, y: 2)} ${p == q}")
}
