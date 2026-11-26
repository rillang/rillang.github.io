//! Byte classes. Under internal/: only textkit itself may import this.

/// Whether `b` is an ASCII letter.
pub fn isLetter(_ b: Int) -> Bool = (b >= 'a' && b <= 'z') || (b >= 'A' && b <= 'Z')

/// Whether `b` is an ASCII digit.
pub fn isDigit(_ b: Int) -> Bool = b >= '0' && b <= '9'

/// `b` lower-cased if it is an ASCII capital.
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
