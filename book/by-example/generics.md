# Generics

Type parameters on structs and functions, inferred at call sites. `T: Equatable` allows `==`.

<!-- include: examples/generics.rl -->
```swift
struct Pair<A, B> { first: A, second: B }

fn swap<A, B>(_ p: Pair<A, B>) -> Pair<B, A> = Pair(first: p.second, second: p.first)

fn contains<T: Equatable>(_ xs: [T], _ x: T) -> Bool {
  for y in xs {
    if y == x {
      return true
    }
  }
  return false
}

fn main() {
  let p = Pair(first: 1, second: "one")
  let q = swap(p)
  print("${q.first} ${q.second}")
  print("${contains([1, 2, 3], 2)} ${contains(["a"], "b")}")
  let explicit = Pair<String, [Int]>(first: "xs", second: [1, 2])
  print("${explicit.second.len()}")
}
```

`rill run generics.rl`

<!-- include: examples/generics.out -->
```text
one 1
true false
2
```

[Index](README.md)
