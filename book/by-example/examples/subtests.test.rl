fn double(_ n: Int) -> Int = n * 2

fn main() {
  print("${double(4)}")
}

test "double" {
  for n in [0, 1, 5] {
    test "n=${n}" {
      expect(double(n) == n + n)
    }
  }
}
