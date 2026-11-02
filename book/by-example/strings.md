# Strings

Strings are immutable UTF-8 bytes. `len`, `slice` and `byteAt` work on bytes.

<!-- include: examples/strings.rl -->
```swift
fn main() {
  let s = "hello, world"
  print("${s.len()} ${s.slice(0, 5)} ${s.byteAt(0)}")
  print("${s.startsWith("hello")} ${s.contains("wor")}")
  print(s.split(", ").join(" / "))
  print("[${"  padded  ".trim()}]")
  print("${("12".toInt() ?? 0) + 1} ${"1.5".toFloat() ?? 0.0}")
  for line in "a\nb".lines() {
    print("line $line")
  }
  print("${"apple" < "banana"}")
}
```

`rill run strings.rl`

<!-- include: examples/strings.out -->
```text
12 hello 104
true true
hello / world
[padded]
13 1.5
line a
line b
true
```

More string functions are in `std/strings` (`replace`, `index`, `toUpper`, …).

[Index](README.md)
