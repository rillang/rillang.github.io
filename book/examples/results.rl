// T! is a result: a T or an Error. fail("…") creates the error.
fn parsePort(_ s: String) -> Int! {
  guard let n = s.toInt() else {
    return fail("not a number: $s")
  }
  guard n > 0 && n < 65536 else {
    return fail("out of range: $n")
  }
  return n
}

// guard let takes the value of a result and skips the error: right here,
// because any bad input means "use the default port"
fn portOr80(_ s: String) -> Int {
  guard let p = parsePort(s) else {
    return 80
  }
  return p
}

// `?` propagates the error to the caller
fn parsePair(_ a: String, _ b: String) -> Int! {
  return parsePort(a)? + parsePort(b)?
}

fn main() {
  print("${parsePort("8080") ?? 0}")
  print("${parsePort("x") ?? 0}")

  // a result is an enum with the cases .ok and .err
  switch parsePair("80", "99999") {
  case .ok(sum): print("sum $sum")
  case .err(e): print("error: ${e.msg}")
  }

  // if let runs the block only when there is a value
  if let p = parsePort("443") {
    print("port $p")
  }
  print("${portOr80("http")}")

  // to look at the error, switch on .err(e)
  switch parsePort("") {
  case .ok(_):
  case .err(e): print("empty input: ${e.msg}")
  }
}
