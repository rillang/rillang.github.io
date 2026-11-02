# Structs

A struct groups named fields. It is constructed with every field labeled and compared with `==`.

<!-- include: examples/structs.rl -->
```swift
struct Person {
  name: String
  age: Int
}

fn older(_ p: Person, by years: Int) -> Person = Person(name: p.name, age: p.age + years)

fn main() {
  let ana = Person(name: "Ana", age: 33)
  print("${ana.name} ${ana.age}")
  let later = ana.older(by: 10)
  print("${later.age} ${ana.age}")
  var bo = Person(name: "Bo", age: 41)
  bo.age += 1
  print("${bo.age} ${bo == Person(name: "Bo", age: 42)}")
}
```

`rill run structs.rl`

<!-- include: examples/structs.out -->
```text
Ana 33
43 33
42 true
```

[Index](README.md)
