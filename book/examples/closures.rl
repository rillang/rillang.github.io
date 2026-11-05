fn apply(_ f: (Int) -> Int, _ x: Int) -> Int = f(x)

fn makeAdder(_ n: Int) -> (Int) -> Int {
  return { x in x + n }
}

fn triple(_ x: Int) -> Int = x * 3

fn main() {
  // a closure: { params in body }
  print("${apply({ x in x * 2 }, 5)}")

  // functions are values too
  print("${apply(triple, 5)}")

  // a trailing closure follows the call; `$` names a single parameter
  let xs = [1, 2, 3, 4]
  let big = xs.map { $ * 10 }.filter { $ > 15 }
  print(big.map { "${$}" }.join(", "))

  // two parameters
  let byLength = ["ccc", "a", "bb"].sortBy { a, b in a.len() < b.len() }
  print(byLength.join(" "))

  // closures capture values when they are created
  var base = 1
  let addBase: (Int) -> Int = { x in x + base }
  base = 100
  print("${addBase(1)} ${makeAdder(base)(1)}")

  // a closure stored in a variable needs a type: on the variable or on its parameters
  let isEven: (Int) -> Bool = { n in n % 2 == 0 }
  let isOdd = { (n: Int) in n % 2 == 1 }
  print("${isEven(4)} ${isEven(7)} ${isOdd(7)}")
}
