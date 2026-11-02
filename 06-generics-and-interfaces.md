# 6. Generics and interfaces

## Generics

Functions, structs and enums take type parameters in angle brackets.

<!-- include: examples/generics.rl -->
```swift
struct Stack<T> { items: [T] }

fn push<T>(_ s: inout Stack<T>, _ x: T) {
  s.items.push(x)
}

fn peek<T>(_ s: Stack<T>) -> T? {
  if s.items.len() == 0 {
    return nil
  }
  return s.items[s.items.len() - 1]
}

enum Tree<T> {
  case leaf(T)
  case node([Tree<T>])
}

fn count<T>(_ t: Tree<T>) -> Int {
  switch t {
  case .leaf(_): return 1
  case .node(kids):
    var n = 0
    for k in kids {
      n += count(k)
    }
    return n
  }
}

// a constraint: T must be Comparable (Int, Float, String)
fn largest<T: Comparable>(_ xs: [T]) -> T? {
  var best: T? = nil
  for x in xs {
    if let b = best {
      if x > b {
        best = x
      }
    } else {
      best = x
    }
  }
  return best
}

fn mapAll<T, U>(_ xs: [T], _ f: (T) -> U) -> [U] {
  var out: [U] = []
  for x in xs {
    out.push(f(x))
  }
  return out
}

fn empty<T>() -> [T] = []

fn main() {
  var s = Stack<Int>(items: [])
  s.push(3)
  push(&s, 4)
  print("${peek(s) ?? 0} ${s.items.len()}")

  let t: Tree<String> = .node([.leaf("a"), .node([.leaf("b"), .leaf("c")])])
  print("${count(t)}")

  print("${largest([3, 9, 4]) ?? 0} ${largest(["pear", "apple"]) ?? ""}")
  print(mapAll(["a", "bcd"], { w in "${w.len()}" }).join(","))

  // type arguments come from the arguments or from the expected type
  let none: [String] = empty()
  print("${none.len()}")
}
```

<!-- include: examples/generics.out -->
```text
4 2
3
9 pear
1,3
0
```

- A generic type is used with its arguments: `Stack<Int>`, `Pair<String, [Int]>`.
  In an expression: `Stack<Int>(items: [])`.
- Calls never name type arguments (`empty<Int>()` does not exist). The compiler infers them
  from the arguments, and failing that from the expected type
  (`let none: [String] = empty()`). If neither works: E0029.
- A type parameter may have **one** constraint: `T: Comparable`, `T: Shape`. Without one,
  a `T` can only be passed, stored, returned and put into arrays, optionals and map values.
  Anything else (`<` on an unconstrained `T`, a field access) is E0030.
- Built-in constraints: `Equatable` (`==`, `!=`) and `Comparable` (`<`, `<=`, `>`, `>=`, plus
  `Equatable`; `Int`, `Float`, `String`).
- Generic code is compiled once per set of type arguments (monomorphization): it runs
  as fast as code written for the concrete type.

## Interfaces

An interface lists functions a type must have. A type implements it **structurally**: if
the functions exist (callable with UFCS on the type), it conforms. Nothing is declared on
the type.

<!-- include: examples/interfaces.rl -->
```swift
interface Shape {
  fn area(self) -> Float
  fn name(self) -> String
}

struct Circle { r: Float }

fn area(_ c: Circle) -> Float = 3.14159 * c.r * c.r

fn name(_ _c: Circle) -> String = "circle"

struct Square { side: Float }

fn area(_ s: Square) -> Float = s.side * s.side

fn name(_ _s: Square) -> String = "square"

// static dispatch: one copy of the function per concrete S
fn total<S: Shape>(_ xs: [S]) -> Float {
  var t = 0.0
  for x in xs {
    t += x.area()
  }
  return t
}

fn main() {
  // Circle and Square implement Shape because area and name exist for them
  print("${total([Square(side: 1.0), Square(side: 3.0)])}")

  // interface values: any implementing type, dispatched at run time
  let shapes: [Shape] = [Circle(r: 1.0), Square(side: 2.0)]
  for s in shapes {
    print("${s.name()}: ${s.area()}")
  }
  print("${total(shapes)}")
}
```

<!-- include: examples/interfaces.out -->
```text
10.0
circle: 3.14159
square: 4.0
7.14159
```

- `self` in a requirement is the receiver. Further parameters keep their labels:
  `fn label(self, prefix p: String) -> String` needs
  `fn label(_ r: Rect, prefix p: String) -> String`.
- Implementations are found in the current module and in the module that declares the
  type.
- A missing function is reported where conformance is needed, naming the requirement
  (E0028).
- As a **constraint** (`S: Shape`), calls are resolved at compile time per concrete type.
- As a **value** (`let s: Shape`, `[Shape]`, `Shape?`), any implementing value converts
  implicitly. The value is boxed (copied) and calls go through a table at run time. Only
  the interface's functions can be called on it: `==`, field access and `switch` are E0030.

Not available yet: explicit type arguments on calls, several constraints per parameter,
`where` clauses on generics, interface inheritance, default implementations, `Self` in
requirements, generic closures, and sending generic or interface values between tasks.

Next: [Modules](07-modules.md).
