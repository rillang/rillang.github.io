fn isPrime(_ n: Int) -> Bool {
  if n < 2 {
    return false
  }
  var d = 2
  while d * d <= n {
    if n % d == 0 {
      return false
    }
    d += 1
  }
  return true
}

fn check(_ s: String) -> Int! {
  guard let n = s.toInt() else {
    return fail("bad input: $s")
  }
  return n
}

fn main() {
  var xs: [Int] = []
  for i in 0..<50000 {
    xs.push(i)
  }
  let flags = xs.parMap { isPrime($) }
  var count = 0
  for f in flags {
    if f {
      count += 1
    }
  }
  print("$count primes below 50000")

  // results come back in order, errors included
  let parsed = ["1", "x", "3"].parMap { check($) }
  for r in parsed {
    switch r {
    case .ok(n): print("ok $n")
    case .err(e): print(e.msg)
    }
  }
}
