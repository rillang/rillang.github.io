fn add(_ a: Int, _ b: Int) -> Int = a + b

fn clamp(_ x: Int, low: Int, high: Int) -> Int {
  if x < low {
    return low
  }
  if x > high {
    return high
  }
  return x
}

fn main() {
  print("rill test does not run main")
}

test "add" {
  expect(add(1, 2) == 3)
}

test "clamp keeps values in range" {
  expect(clamp(5, low: 0, high: 10) == 5)
  expect(clamp(-1, low: 0, high: 10) == 0)
  expect(clamp(11, low: 0, high: 10) == 10)
}

test "a failing test reports every failed expect" {
  expect(add(2, 2) == 5)
  expect(clamp(3, low: 0, high: 2) == 3)
}
