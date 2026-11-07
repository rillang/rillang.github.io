# Strings and characters

A `String` is bytes: `len` counts bytes. `for c in s` decodes UTF-8 into `Char`s (one Unicode scalar each); with an index it yields byte offsets. `unicode.graphemes` splits what a reader sees as one character. An ASCII character literal also works as its byte value.

<!-- include: examples/characters.rl -->
```swift
import "std/strings"
import "std/unicode"

fn main() {
  let s = "héllo 🦀"
  // a String is bytes: len counts bytes, charCount counts Chars
  print("${s.len()} bytes, ${s.charCount()} chars")

  // for c in s decodes UTF-8; with an index it yields byte offsets
  for i, c in s {
    if c == 'é' || c == '🦀' {
      print("$i: $c")
    }
  }

  // an ASCII literal is also an Int where one is expected
  print("${s.byteAt(0) == 'h'}")

  // a grapheme is what a reader calls one character
  let flag = "🇦🇹!"
  print("${flag.charCount()} chars, ${unicode.graphemes(flag).len()} graphemes")

  // case-insensitive comparison and width-aware padding
  print("${strings.equalFold("Ärger", "äRGER")}")
  print("[${strings.padLeft("日本", 6)}]")

  var sb = StringBuilder()
  sb.addChar('é')
  sb.addChar('\u{1F980}')
  print(sb.build())
}
```

`rill run characters.rl`

<!-- include: examples/characters.out -->
```text
11 bytes, 7 chars
1: é
7: 🦀
true
3 chars, 2 graphemes
true
[  日本]
é🦀
```

[Index](README.md)
