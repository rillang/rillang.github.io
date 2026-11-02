enum Token {
  case num(Int)
  case word(String)
}

fn firstNumber(_ tokens: [Token]) -> Int {
  guard case [.num(n), ...] = tokens else {
    return -1
  }
  return n
}

fn main() {
  let t: Token = .word("let")
  if case .word(w) = t {
    print("word $w")
  }
  if case .num(_) = t {
    print("number")
  } else {
    print("not a number")
  }
  print("${firstNumber([.num(4), .word("x")])} ${firstNumber([])}")
}
