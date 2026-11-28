fn render(_ names: [String]) -> String {
  var out = "team:\n"
  var i = 0
  for n in names {
    i += 1
    out += "  ${i}. ${n}\n"
  }
  return out
}

test "team list" {
  expectSnapshot(render(["Ada", "Grace"]))
}

test "labels" {
  expectSnapshot(render([]), "empty")
  expectSnapshot(render(["Linus"]), "one")
}

test "golden file" {
  expectGolden(render(["Ada", "Grace"]), "testdata/team.txt")
}
