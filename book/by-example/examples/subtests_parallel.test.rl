fn square(_ n: Int) -> Int = n * n

fn main() {
  print("${square(4)}")
}

// The parent runs again once per parallel subtest: it only lists the inputs.
test "square" {
  for n in [1, 2, 3] {
    test "n=${n}" parallel {
      expect(square(n) == n * n)
    }
  }
}
