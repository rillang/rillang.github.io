# Snapshots and golden files

`expectSnapshot(value)` compares a `String` or `Bytes` with a file under `testdata/snapshots/`
next to the test. `expectGolden(value, path)` compares with a file you name.

<!-- include: examples/snapshots.test.rl -->
```swift
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
```

`rill test snapshots.test.rl`

<!-- include: examples/snapshots.test.out -->
```text
ok    book/by-example/examples/snapshots.test.rl    3 tests   0.00s

result: ok. 3 passed; 1 module in 0.00s
```

A missing or different file fails the test with a diff. `rill test --update` writes the files;
read the diff in version control before you commit them.

[Index](README.md)
