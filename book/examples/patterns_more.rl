struct Point { x: Int, y: Int }

enum Shape {
  case circle(Float)
  case square(Float)
}

// a function that only matches is a switch as its value
fn fib(_ n: Int) -> Int = switch n {
  case 0: 0
  case 1: 1
  default: fib(n - 1) + fib(n - 2)
}

// several parameters: conditions, not patterns
fn gcd(_ a: Int, _ b: Int) -> Int = if b == 0 { a } else { gcd(b, a % b) }

// one pattern with a fallback
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
