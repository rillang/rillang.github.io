# Loops

`for` iterates ranges, arrays, maps and channels; `while` loops on a condition.

<!-- include: examples/loops.rl -->
```swift
fn main() {
  for i in 0..<3 {
    print("range $i")
  }

  for word in ["red", "green"] {
    print("word $word")
  }

  var n = 1
  while n < 100 {
    n *= 3
  }
  print("first power of 3 above 100: $n")

  for i in 0..<10 {
    if i % 2 == 0 {
      continue
    }
    if i > 5 {
      break
    }
    print("odd $i")
  }
}
```

`rill run loops.rl`

<!-- include: examples/loops.out -->
```text
range 0
range 1
range 2
word red
word green
first power of 3 above 100: 243
odd 1
odd 3
odd 5
```

`0..<3` is half-open. There is no closed range.

[Index](README.md)
