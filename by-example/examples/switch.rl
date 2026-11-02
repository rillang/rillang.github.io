fn kind(_ c: Int) -> String {
  switch c {
  case '0'..<':': return "digit"
  case ' ', '\t', '\n': return "space"
  case 'a'..<'{', 'A'..<'[': return "letter"
  default: return "other"
  }
}

fn main() {
  print("${kind('7')} ${kind(' ')} ${kind('q')} ${kind('#')}")
  let command = "stop"
  switch command {
  case "go": print("going")
  case "stop": print("stopping")
  default: print("unknown")
  }
  let n = 15
  switch n {
  case x where x % 15 == 0: print("fizzbuzz")
  case x where x % 3 == 0: print("fizz")
  default: print("$n")
  }
}
