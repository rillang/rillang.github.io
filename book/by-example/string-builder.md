# StringBuilder

`StringBuilder` appends without copying the string built so far.

<!-- include: examples/string_builder.rl -->
```swift
fn csvRow(_ cells: [Int]) -> String {
  var sb = StringBuilder()
  for i in 0..<cells.len() {
    if i > 0 {
      sb.addByte(',')
    }
    sb.addInt(cells[i])
  }
  return sb.build()
}

fn main() {
  print(csvRow([1, 22, 333]))
  var sb = StringBuilder()
  for i in 0..<1000 {
    sb.add("line $i\n")
  }
  print("${sb.len()} bytes")
}
```

`rill run string_builder.rl`

<!-- include: examples/string_builder.out -->
```text
1,22,333
8890 bytes
```

[Index](README.md)
