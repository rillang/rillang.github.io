fn classify(_ n: Int) -> String {
  if n < 0 {
    return "negative"
  } else if n == 0 {
    return "zero"
  }
  return "positive"
}

fn firstWord(_ line: String) -> String {
  // an early exit is an if with return
  if line.len() == 0 {
    return "(empty)"
  }
  return line.split(" ")[0]
}

fn main() {
  print("${classify(-5)} ${classify(0)} ${classify(9)}")
  print("${firstWord("hello world")} ${firstWord("")}")

  // ranges are half-open: 0, 1, 2, 3, 4
  var sum = 0
  for i in 0..<5 {
    if i == 3 {
      continue
    }
    sum += i
  }
  print("sum $sum")

  var n = 27
  var steps = 0
  while n != 1 {
    if n % 2 == 0 {
      n = n / 2
    } else {
      n = 3 * n + 1
    }
    steps += 1
    if steps > 1000 {
      break
    }
  }
  print("collatz steps $steps")

  for name in ["ana", "bo"] {
    print(name)
  }
}
