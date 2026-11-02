fn main() {
  // arrays: [T]
  var xs = [3, 1, 2]
  xs.push(5)
  xs[0] = 4
  print("${xs.len()} ${xs[0]} ${xs.slice(1, 3).len()}")
  let sorted = xs.sortBy { a, b in a < b }
  print(sorted.map { "${$}" }.join(" "))
  let empty: [String] = []
  print("${empty.len()}")

  // maps: Map<K, V>, keys are Int or String, iteration in insertion order
  var ages = ["ana": 33, "bo": 41]
  ages["cy"] = 25
  print("${ages.len()} ${ages.has("bo")} ${ages["zed"] ?? 0}")
  for name, age in ages {
    print("$name is $age")
  }
  print(ages.keys().join(","))
  var counts = Map<String, Int>()
  for w in "a b a c a".split(" ") {
    counts[w] = (counts[w] ?? 0) + 1
  }
  print("a=${counts["a"] ?? 0}")

  // StringBuilder builds strings without copying
  var sb = StringBuilder()
  for i in 0..<3 {
    sb.add("#")
    sb.addInt(i)
  }
  print(sb.build())
}
