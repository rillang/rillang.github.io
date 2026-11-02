fn main() {
  // let binds a constant, var a variable
  let answer = 42
  var count = 0
  count += 1

  // the basic types: Int (64-bit), Float (64-bit), Bool, String
  let pi: Float = 3.14159
  let ready: Bool = answer > 40 && count == 1
  let greeting: String = "hi"

  // interpolation: $name or ${expression}
  print("$greeting: answer=$answer, count=$count, ready=$ready")
  print("pi doubled is ${pi * 2.0}")

  // integer division truncates, % is the remainder
  print("${7 / 2} ${7 % 2} ${7.0 / 2.0}")

  // no implicit conversions between Int and Float
  let n = 3
  let half = Float(n) / 2.0
  print("${half} ${Int(2.9)} ${str(n)}")

  // literals: hex, digit separators, characters (which are Ints)
  print("${0xff} ${1_000_000} ${'A'}")

  // strings are immutable UTF-8 bytes
  let word = "naïve"
  print("${word.len()} bytes")
}
