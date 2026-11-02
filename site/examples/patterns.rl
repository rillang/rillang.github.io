fn describe(_ xs: [Int]) -> String {
  switch xs {
  case []: return "empty"
  case [x]: return "just $x"
  case [first, ...rest] where first > 100: return "big start, ${rest.len()} more"
  case [first, second, ...]: return "$first, $second, ..."
  }
}

fn port(_ conf: Map<String, Int>) -> String {
  switch conf {
  case ["port": p, "tls": 1]: return "https on $p"
  case ["port": p]: return "http on $p"
  default: return "no port"
  }
}

fn main() {
  print("${describe([])} | ${describe([7])} | ${describe([500, 1])} | ${describe([1, 2, 3])}")
  print("${port(["port": 443, "tls": 1])} | ${port(["port": 80])}")
}
