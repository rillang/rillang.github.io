struct Point { x: Int, y: Int }

enum Token {
  case num(Int)
  case word(String)
}

// a pattern with a fallback
fn firstNumber(_ tokens: [Token]) -> Int = switch tokens {
  case [.num(n), ...]: n
  default: -1
}

fn main() {
  let t: Token = .word("let")
  switch t {
  case .word(w): print("word $w")
  case .num(_):
  }

  // let and for bind names: read the fields
  let p = Point(x: 1, y: 2)
  let px = p.x
  print("$px ${p.y}")

  // visit only some elements: switch inside the loop
  let tokens: [Token] = [.num(4), .word("x"), .num(5)]
  var sum = 0
  for tok in tokens {
    switch tok {
    case .num(n): sum += n
    case .word(_): continue
    }
  }
  print("sum $sum")
  print("${firstNumber(tokens)} ${firstNumber([])}")
}
