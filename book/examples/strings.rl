fn main() {
  let s = "  Hello, Rill  ".trim()
  print(s)
  print("${s.len()} ${s.slice(0, 5)} ${s.startsWith("Hell")} ${s.contains("Rill")}")
  print("a,b,,c".split(",").join("|"))
  print("${"one\ntwo\n".lines().len()} lines")
  print("${"42".toInt() ?? 0} ${"x".toInt() ?? -1} ${"2.5".toFloat() ?? 0.0}")
  print("${"abc" < "abd"} ${"abc" == "abc"}")
  // byteAt returns a byte as an Int; an ASCII character literal is an Int here
  print("${"#x".byteAt(0) == '#'}")
  print("escapes: \"quoted\" \$5 tab\tend")
}
