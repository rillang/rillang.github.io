import "std/hex"

fn main() {
  var b = Bytes([72, 105])
  b.push(33)
  print("${b.len()} ${b[0]} ${b[2]}")

  // text to bytes and back; the conversion back checks UTF-8
  let raw = "é".bytes()
  print("${raw.len()} ${raw[0]} ${raw[1]}")
  if let s = String(utf8: raw) {
    print(s)
  }
  let bad = Bytes([0xE9])
  switch String(utf8: bad) {
  case .ok(_): print("valid")
  case .err(e): print(e.msg)
  }

  // copy on write: the copy does not see later writes
  let copy = b
  b.push(0)
  print("${copy.len()} ${b.len()}")
  print(hex.encode(b))
}
