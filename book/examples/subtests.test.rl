fn sign(_ x: Int) -> Int {
  if x < 0 {
    return -1
  }
  return 1
}

fn main() {
  print("${sign(-4)}")
}

struct Row { name: String, input: Int, want: Int }

fn rows() -> [Row] = [
  Row(name: "negative", input: -4, want: -1),
  Row(name: "zero", input: 0, want: 0),
  Row(name: "positive", input: 9, want: 1),
]

test "sign per row" {
  for r in rows() {
    test r.name {
      expect(sign(r.input) == r.want)
    }
  }
}

test "sign in one loop" {
  for r in rows() {
    expect(sign(r.input) == r.want, r.name)
  }
}
