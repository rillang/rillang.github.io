struct Point { x: Int, y: Int }

enum Shape {
  case circle(Float)
  case rect(Point, Point)
  case dot
}

fn describe(_ s: Shape) -> String {
  switch s {
  case .circle(r) where r > 10.0: return "big circle"
  case .circle(_): return "circle"
  case .rect(Point(x: 0, y: 0), corner): return "rect from the origin to ${corner.x},${corner.y}"
  case .rect(_, _): return "rect"
  case .dot: return "dot"
  }
}

fn head(_ xs: [Int]) -> String {
  switch xs {
  case []: return "empty"
  case [x]: return "one: $x"
  case [x, y, ...rest]: return "$x, $y and ${rest.len()} more"
  }
}

fn grade(_ n: Int) -> String {
  switch n {
  case 90..<101: return "A"
  case 0, 1, 2: return "almost nothing"
  case x where x < 0: return "invalid"
  default: return "other"
  }
}

fn greet(_ name: String?) -> String {
  switch name {
  case nil: return "hello, stranger"
  case "root"?: return "hello, admin"
  case n?: return "hello, $n"
  }
}

// maps are not matched: look keys up with m[k]
fn server(_ conf: Map<String, Int>) -> String {
  if conf.len() == 0 {
    return "no config"
  }
  guard let p = conf["port"] else {
    return "no port"
  }
  if conf["debug"] == 1 {
    return "port $p (debug)"
  }
  return "port $p"
}

fn main() {
  print(describe(.circle(12.0)))
  print(describe(.rect(Point(x: 0, y: 0), Point(x: 3, y: 4))))
  print(describe(.dot))
  print("${head([])} | ${head([7])} | ${head([1, 2, 3, 4])}")
  print("${grade(95)} ${grade(1)} ${grade(-3)} ${grade(50)}")
  print("${greet(nil)}; ${greet("root")}; ${greet("ana")}")
  print("${server([:])}; ${server(["port": 80])}; ${server(["port": 8080, "debug": 1])}")

  // the whole value is the switch subject itself
  let s: Shape = .rect(Point(x: 9, y: 0), Point(x: 0, y: 0))
  switch s {
  case .rect(Point(x: x, y: _), _): print("x=$x in ${describe(s)}")
  case .circle(_), .dot:
  }
}
