enum Event {
  case click(Int, Int)
  case key(String)
  case quit
}

fn describe(_ e: Event) -> String {
  switch e {
  case .click(x, y): return "click at $x,$y"
  case .key(k): return "key $k"
  case .quit: return "quit"
  }
}

fn main() {
  let events: [Event] = [.click(3, 4), .key("q"), .quit]
  for e in events {
    print(describe(e))
  }
  print("${Event.key("a") == .key("a")}")
}
