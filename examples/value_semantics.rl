struct Team { name: String, members: [String] }

fn withMember(_ t: Team, _ m: String) -> Team {
  var copy = t
  copy.members.push(m)
  return copy
}

fn addMember(_ t: inout Team, _ m: String) {
  t.members.push(m)
}

fn main() {
  // arrays are values: b keeps its own elements
  var a = [1, 2, 3]
  let b = a
  a.push(4)
  print("a=${a.len()} b=${b.len()}")

  // the same holds inside structs and maps, at any depth
  let red = Team(name: "red", members: ["ana"])
  let bigger = withMember(red, "bo")
  print("${red.members.len()} ${bigger.members.len()}")

  var grid = [[1, 2], [3, 4]]
  let snapshot = grid
  grid[0].push(9)
  print("${grid[0].len()} ${snapshot[0].len()}")

  // inout is the one way to change a caller's value
  var blue = Team(name: "blue", members: [])
  addMember(&blue, "cy")
  print("${blue.members.len()}")
}
