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
  if case .err(e) = config("http") {
    print("error: ${e.msg}")
  }
}
