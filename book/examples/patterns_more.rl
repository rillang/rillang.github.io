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

fn sumOfFirstTwo(_ xs: [Int]) -> Int {
  guard case [a, b, ...] = xs else {
    return 0
  }
  return a + b
}

fn main() {
  print("${fib(10)} ${gcd(84, 36)}")
  print("${sumOfFirstTwo([4, 5, 6])} ${sumOfFirstTwo([1])}")

  // let destructures with an irrefutable pattern
  let p = Point(x: 3, y: 4)
  let Point(x: px, y: py) = p
  print("$px $py")

  // for destructures every element; for case visits only matching ones
  let points = [Point(x: 1, y: 2), Point(x: 3, y: 4)]
  var dot = 0
  for Point(x: x, y: y) in points {
    dot += x * y
  }
  let shapes: [Shape] = [.circle(1.0), .square(2.0), .circle(0.5)]
  var radii = 0.0
  for case .circle(r) in shapes {
    radii += r
  }
  print("$dot $radii")

  // maps iterate as key, value
  for word, n in ["one": 1, "two": 2] {
    print("$word -> $n")
  }
}
