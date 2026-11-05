fn parsePort(_ s: String) -> Int! {
  guard let n = s.toInt() else {
    return fail("not a number: $s")
  }
  return n
}

fn config(_ raw: String) -> String! {
  let port = parsePort(raw)?
  return "listening on $port"
}

fn main() {
  print(config("8080") ?? "?")
  switch config("http") {
  case .ok(msg): print(msg)
  case .err(e): print("error: ${e.msg}")
  }
}
