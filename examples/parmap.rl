fn collatz(_ start: Int) -> Int {
  var n = start
  var steps = 0
  while n != 1 {
    if n % 2 == 0 {
      n = n / 2
    } else {
      n = 3 * n + 1
    }
    steps += 1
  }
  return steps
}

fn main() {
  var xs: [Int] = []
  for i in 1..<10001 {
    xs.push(i)
  }
  // parMap spreads the work over all cores and keeps the order
  let steps = xs.parMap { collatz($) }
  var best = 0
  for i in 0..<steps.len() {
    if steps[i] > steps[best] {
      best = i
    }
  }
  print("${xs[best]} takes ${steps[best]} steps")
}
