# Interfaces

A type implements an interface when the required functions exist for it. Interface values hold any implementing type.

<!-- include: examples/interfaces.rl -->
```swift
interface Animal {
  fn sound(self) -> String
}

struct Dog { name: String }

fn sound(_ d: Dog) -> String = "${d.name}: woof"

struct Cat {}

fn sound(_ c: Cat) -> String = "meow"

fn chorus(_ xs: [Animal]) -> String = xs.map { $.sound() }.join(", ")

fn main() {
  let zoo: [Animal] = [Dog(name: "rex"), Cat()]
  print(chorus(zoo))
}
```

`rill run interfaces.rl`

<!-- include: examples/interfaces.out -->
```text
rex: woof, meow
```

Nothing is declared on `Dog` or `Cat`: conformance is structural.

[Index](README.md)
