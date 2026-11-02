fn pick(_ xs: [Int], _ i: Int) -> Int = xs[i]

fn main() {
  let xs = [1, 2, 3]
  print("${pick(xs, 1)}")
  print("${pick(xs, 5)}")
}
