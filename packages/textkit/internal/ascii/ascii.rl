// Byte classes. Under internal/: only textkit itself may import this.

pub fn isLetter(_ b: Int) -> Bool = (b >= 'a' && b <= 'z') || (b >= 'A' && b <= 'Z')

pub fn isDigit(_ b: Int) -> Bool = b >= '0' && b <= '9'

pub fn lower(_ b: Int) -> Int {
  if b >= 'A' && b <= 'Z' {
    return b + 32
  }
  return b
}

test "classes" {
  expect(isLetter('q') && isLetter('Q') && !isLetter('1'))
  expect(isDigit('7') && !isDigit('x'))
  expect(lower('A') == 'a' && lower('-') == '-')
}
