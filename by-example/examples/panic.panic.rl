// panics are for bugs: they print a message and exit with code 101.
// RILL_BACKTRACE=1 adds the call chain.
fn checkedAge(_ n: Int) -> Int {
  if n < 0 {
    panic("negative age: $n")
  }
  return n
}

fn main() {
  print("${checkedAge(30)}")
  print("${checkedAge(-1)}")
}
