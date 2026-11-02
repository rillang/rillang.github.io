struct Point { x: Int, y: Int }

fn scale(_ p: Point, by f: Int) -> Point = Point(x: p.x * f, y: p.y * f)

fn sum(_ p: Point) -> Int = p.x + p.y

fn double(_ n: Int) -> Int = n * 2

fn main() {
  let p = Point(x: 1, y: 2)
  // x.f(args) calls f(x, args): there are no methods, only functions
  print("${sum(scale(p, by: 10))}")
  print("${p.scale(by: 10).sum()}")
  print("${3.double().double()}")
}
