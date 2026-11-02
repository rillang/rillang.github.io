// An expression body: `= expr`
fn square(_ x: Int) -> Int = x * x

// Argument labels: `_` means none, otherwise the label is part of the call
fn move(_ x: Int, by delta: Int) -> Int = x + delta

fn area(width: Int, height: Int) -> Int {
  return width * height
}

// A function without `-> T` returns nothing (Void)
fn greet(_ name: String) {
  print("hello $name")
}

// inout: the callee changes the caller's variable; the call site says so with &
fn bump(_ n: inout Int) {
  n += 1
}

fn main() {
  print("${square(7)}")
  print("${move(1, by: 2)}")
  print("${area(width: 3, height: 4)}")
  greet("Rill")
  var x = 10
  bump(&x)
  bump(&x)
  print("$x")
}
