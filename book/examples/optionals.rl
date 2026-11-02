fn firstEven(_ xs: [Int]) -> Int? {
  for x in xs {
    if x % 2 == 0 {
      return x
    }
  }
  return nil
}

// `?` on an optional returns nil from the enclosing function when it is empty
fn doubledFirstEven(_ xs: [Int]) -> Int? {
  let x = firstEven(xs)?
  return x * 2
}

fn describe(_ xs: [Int]) -> String {
  guard let x = firstEven(xs) else {
    return "no even number"
  }
  return "first even: $x"
}

fn main() {
  let a = firstEven([1, 4, 6])
  let b = firstEven([1, 3])

  // ?? supplies a default
  print("${a ?? -1} ${b ?? -1}")

  // if let unwraps
  if let x = a {
    print("found $x")
  } else {
    print("none")
  }

  print("${doubledFirstEven([3, 8]) ?? 0} ${doubledFirstEven([]) ?? 0}")
  print(describe([5, 2]))
  print(describe([5]))
  print("${b == nil}")
}
