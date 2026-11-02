struct Team { name: String, members: [String] }

fn main() {
  var a = Team(name: "core", members: ["ana"])
  var b = a
  b.members.push("bo")
  print("${a.members.len()} ${b.members.len()}")
  a.name = "lang"
  print("${a.name} ${b.name}")
}
