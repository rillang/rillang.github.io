// textkit: small text helpers.
import "internal/ascii"

/// `s` as a URL slug: lower-case letters and digits, runs of anything else as one "-".
pub fn slug(_ s: String) -> String {
  var sb = StringBuilder()
  var gap = false
  for i in 0..<s.len() {
    let b = s.byteAt(i)
    if ascii.isLetter(b) || ascii.isDigit(b) {
      if gap && sb.len() > 0 {
        sb.add("-")
      }
      sb.addByte(ascii.lower(b))
      gap = false
    } else {
      gap = true
    }
  }
  return sb.build()
}

/// The number of words (runs of letters and digits) in `s`.
pub fn words(_ s: String) -> Int {
  var n = 0
  var inWord = false
  for i in 0..<s.len() {
    let b = s.byteAt(i)
    let w = ascii.isLetter(b) || ascii.isDigit(b)
    if w && !inWord {
      n += 1
    }
    inWord = w
  }
  return n
}

test "slug" {
  expect(slug("Hello, World!") == "hello-world")
  expect(slug("  Rill 0.1  ") == "rill-0-1")
}

test "words" {
  expect(words("one, two;three") == 3)
  expect(words("") == 0)
}
