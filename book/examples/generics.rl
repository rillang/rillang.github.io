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
