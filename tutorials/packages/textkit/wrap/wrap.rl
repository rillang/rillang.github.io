// wrap: a second package of the module (import "github.com/ada/textkit/wrap").

/// The words of `s` as lines of at most `width` bytes (longer words get a line each).
pub fn lines(_ s: String, width: Int) -> [String] {
  var out: [String] = []
  var line = ""
  for w in s.split(" ") {
    if w == "" {
      continue
    }
    if line == "" {
      line = w
    } else if line.len() + 1 + w.len() <= width {
      line = line + " " + w
    } else {
      out.push(line)
      line = w
    }
  }
  if line != "" {
    out.push(line)
  }
  return out
}

test "lines" {
  expect(lines("a bb ccc dddd", width: 6) == ["a bb", "ccc", "dddd"])
  expect(lines("", width: 3).len() == 0)
}
