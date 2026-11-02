# Destructuring

`let`, `for` and `for case` take values apart with patterns.

<!-- include: examples/destructuring.rl -->
```swift
struct Point { x: Int, y: Int }

enum Item {
  case book(String)
  case pen
}

fn main() {
  let Point(x: x, y: y) = Point(x: 1, y: 2)
  print("$x $y")

  for Point(x: px, y: _) in [Point(x: 5, y: 0), Point(x: 6, y: 0)] {
    print("x $px")
  }

  let items: [Item] = [.book("Dune"), .pen, .book("Emma")]
  for case .book(title) in items {
    print("book $title")
  }

  for name, nums in ["odds": [1, 3], "evens": [2, 4], "none": []] {
    if case [first, ...] = nums {
      print("$name start at $first")
    }
  }
}
```

`rill run destructuring.rl`

<!-- include: examples/destructuring.out -->
```text
1 2
x 5
x 6
book Dune
book Emma
odds start at 1
evens start at 2
```

`let` and `for` need patterns that always match; `for case` skips elements that do not.

[Index](README.md)
