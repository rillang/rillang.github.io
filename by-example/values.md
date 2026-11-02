# Values

Strings, integers, floats and booleans, with the usual operators.

<!-- include: examples/values.rl -->
```swift
fn main() {
  print("rill" + "lang")
  print("1+1 = ${1 + 1}")
  print("7.0/3.0 = ${7.0 / 3.0}")
  print("${true && false} ${true || false} ${!true}")
  print("${-7 / 2} ${-7 % 2}")
  print("${str(42)} ${Float(2)} ${Int(-2.7)}")
}
```

`rill run values.rl`

<!-- include: examples/values.out -->
```text
rilllang
1+1 = 2
7.0/3.0 = 2.3333333333333335
false true false
-3 -1
42 2.0 -2
```

Integer division truncates toward zero. There are no implicit conversions: `Float(2)`, `Int(-2.7)` and `str(42)` convert explicitly.

[Index](README.md)
