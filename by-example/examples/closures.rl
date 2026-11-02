fn counterFrom(_ start: Int) -> (Int) -> Int {
  return { step in start + step }
}

fn twice(_ f: (Int) -> Int, _ x: Int) -> Int = f(f(x))

fn main() {
  let next = counterFrom(10)
  print("${next(1)} ${next(5)}")
  print("${twice({ x in x * 3 }, 2)}")
  let words = ["kiwi", "fig", "banana"]
  print(words.filter { $.len() > 3 }.join(" "))
  print(words.map { w in "${w.len()}" }.join(" "))
}
