# Closures

Closures capture values, can be returned, and are passed as trailing closures. `$` names a single parameter.

<!-- include: examples/closures.rl -->
```swift
fn counterFrom(_ start: Int) -> (Int) -> Int {
  return { step in start + step }
}

fn twice(_ f: (Int) -> Int, _ x: Int) -> Int = f(f(x))

fn main() {
  let next = counterFrom(10)
  print("${next(1)} ${next(5)}")
  print("${twice({ x in x * 3 }, 2)}")
  let words = ["kiwi", "fig", "banana"]
  print(words.filter { $.len() > 3 }.join(" "))
  print(words.map { w in "${w.len()}" }.join(" "))
}
```

`rill run closures.rl`

<!-- include: examples/closures.out -->
```text
11 15
18
kiwi banana
4 3 6
```

A closure needs a typed context: `let f = { x in x + 1 }` cannot infer `x` (E0013).

[Index](README.md)
