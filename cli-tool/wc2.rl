// Step 2: lines, words and bytes, with tests.
import "std/os"
import "std/fs"

struct Counts { lines: Int, words: Int, bytes: Int }

fn isSpace(_ b: Int) -> Bool = b == ' ' || b == '\n' || b == '\t' || b == '\r'

fn count(_ text: String) -> Counts {
  var c = Counts(lines: 0, words: 0, bytes: text.len())
  var inWord = false
  for i in 0..<text.len() {
    let b = text.byteAt(i)
    if b == '\n' {
      c.lines += 1
    }
    if isSpace(b) {
      inWord = false
    } else if !inWord {
      inWord = true
      c.words += 1
    }
  }
  return c
}

fn main() -> Void! {
  for f in os.args() {
    let c = count(fs.readFile(f)?)
    print("${c.lines} ${c.words} ${c.bytes} $f")
  }
}

test "count" {
  expect(count("") == Counts(lines: 0, words: 0, bytes: 0))
  expect(count("one two\nthree\n") == Counts(lines: 2, words: 3, bytes: 14))
  expect(count("  spaced   out  ") == Counts(lines: 0, words: 2, bytes: 16))
}
