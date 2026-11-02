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
