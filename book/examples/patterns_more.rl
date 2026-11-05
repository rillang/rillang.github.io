struct Point { x: Int, y: Int }

enum Shape {
  case circle(Float)
  case square(Float)
}

// A function whose body starts with `case` matches its parameters
fn fib(_ n: Int) -> Int {
case 0: return 0
case 1: return 1
case n: return fib(n - 1) + fib(n - 2)
}

// several parameters: one pattern per parameter, in parentheses
fn gcd(_ a: Int, _ b: Int) -> Int {
case (a, 0): return a
case (a, b): return gcd(b, a % b)
}

// one pattern with a fallback: a switch as the function's value
fn sumOfFirstTwo(_ xs: [Int]) -> Int = switch xs {
  case [a, b, ...]: a + b
  default: 0
}

fn main() {
  print("${fib(10)} ${gcd(84, 36)}")
  print("${sumOfFirstTwo([4, 5, 6])} ${sumOfFirstTwo([1])}")

  // one case of interest: name the others with an empty body
  let s: Shape = .circle(2.0)
  switch s {
  case .circle(r): print("radius $r")
  case .square(_):
  }

  // let and for bind names; fields are read with `.`
  let p = Point(x: 3, y: 4)
  let px = p.x
  print("$px ${p.y}")

  // to visit only some elements, switch inside the loop
  let points = [Point(x: 1, y: 2), Point(x: 3, y: 4)]
  var dot = 0
  for pt in points {
    dot += pt.x * pt.y
  }
  let shapes: [Shape] = [.circle(1.0), .square(2.0), .circle(0.5)]
  var radii = 0.0
  for sh in shapes {
    switch sh {
    case .circle(r): radii += r
    case .square(_): continue
    }
  }
  print("$dot $radii")

  // maps iterate as key, value
  for word, n in ["one": 1, "two": 2] {
    print("$word -> $n")
  }
}
