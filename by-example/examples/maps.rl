fn main() {
  var m: Map<String, Int> = [:]
  m["k1"] = 7
  m["k2"] = 13
  print("${m.len()} ${m["k1"] ?? 0} ${m.has("k3")}")

  // a lookup returns an optional
  if let v = m["k2"] {
    print("k2 = $v")
  }

  let ids = [1: "one", 2: "two"]
  for id, name in ids {
    print("$id: $name")
  }
  print(m.keys().join(" "))
}
