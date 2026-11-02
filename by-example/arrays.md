# Arrays

`[T]` grows with `push`, is indexed from 0, and is a value: copies do not share changes.

<!-- include: examples/arrays.rl -->
```swift
fn main() {
  var a = [10, 20, 30]
  a[1] = 25
  a.push(40)
  print("${a.len()} ${a[1]} ${a[a.len() - 1]}")
  print(a.slice(1, 3).map { "${$}" }.join(","))

  let nested = [[1, 2], [3]]
  print("${nested[0][1]} ${nested.len()}")

  let byDesc = [3, 1, 2].sortBy { x, y in x > y }
  print(byDesc.map { "${$}" }.join(" "))

  var sum = 0
  for x in a {
    sum += x
  }
  print("sum $sum")
  print("${[1, 2] == [1, 2]}")
}
```

`rill run arrays.rl`

<!-- include: examples/arrays.out -->
```text
4 25 40
25,30
2 2
3 2 1
sum 105
true
```

An index out of bounds panics.

[Index](README.md)
