// a function that only matches its parameter: `= switch` as the body
fn fizz(_ n: Int) -> String = switch n {
  case x where x % 15 == 0: "FizzBuzz"
  case x where x % 3 == 0: "Fizz"
  case x where x % 5 == 0: "Buzz"
  default: "$n"
}

fn sum(_ xs: [Int]) -> Int = switch xs {
  case []: 0
  case [x, ...rest]: x + sum(rest)
}

// several parameters: conditions, not patterns
fn both(_ a: Bool, _ b: Bool) -> String {
  if a && b {
    return "both"
  }
  if a || b {
    return "one"
  }
  return "none"
}

fn main() {
  var out: [String] = []
  for i in 1..<16 {
    out.push(fizz(i))
  }
  print(out.join(" "))
  print("${sum([1, 2, 3, 4])} ${both(true, false)}")
}
