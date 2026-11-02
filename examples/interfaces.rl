interface Shape {
  fn area(self) -> Float
  fn name(self) -> String
}

struct Circle { r: Float }

fn area(_ c: Circle) -> Float = 3.14159 * c.r * c.r

fn name(_ c: Circle) -> String = "circle"

struct Square { side: Float }

fn area(_ s: Square) -> Float = s.side * s.side

fn name(_ s: Square) -> String = "square"

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
