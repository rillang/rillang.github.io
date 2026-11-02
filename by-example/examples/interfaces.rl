interface Animal {
  fn sound(self) -> String
}

struct Dog { name: String }

fn sound(_ d: Dog) -> String = "${d.name}: woof"

struct Cat {}

fn sound(_ _c: Cat) -> String = "meow"

fn chorus(_ xs: [Animal]) -> String = xs.map { $.sound() }.join(", ")

fn main() {
  let zoo: [Animal] = [Dog(name: "rex"), Cat()]
  print(chorus(zoo))
}
