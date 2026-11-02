fn plus(_ a: Int, _ b: Int) -> Int {
  return a + b
}

// a single expression can be the whole body
fn plusPlus(_ a: Int, _ b: Int, _ c: Int) -> Int = a + b + c

fn log(_ msg: String) {
  print("log: $msg")
}

fn main() {
  print("${plus(1, 2)}")
  print("${plusPlus(1, 2, 3)}")
  log("done")
}
