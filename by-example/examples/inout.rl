struct Cursor { text: String, pos: Int }

fn next(_ c: inout Cursor) -> Int {
  let b = c.text.byteAt(c.pos)
  c.pos += 1
  return b
}

fn swap(_ a: inout Int, _ b: inout Int) {
  let t = a
  a = b
  b = t
}

fn main() {
  var c = Cursor(text: "ab", pos: 0)
  let first = c.next()
  let second = next(&c)
  print("$first $second ${c.pos}")
  var xs = [1, 2]
  swap(&xs[0], &xs[1])
  print("${xs[0]} ${xs[1]}")
}
