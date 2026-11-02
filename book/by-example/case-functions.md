# Functions made of cases

A function body that starts with `case` matches its parameters, like a `switch`.

<!-- include: examples/case_functions.rl -->
```swift
fn fizz(_ n: Int) -> String {
case n where n % 15 == 0: return "FizzBuzz"
case n where n % 3 == 0: return "Fizz"
case n where n % 5 == 0: return "Buzz"
case n: return "$n"
}

fn sum(_ xs: [Int]) -> Int {
case []: return 0
case [x, ...rest]: return x + sum(rest)
}

fn both(_ a: Bool, _ b: Bool) -> String {
case (true, true): return "both"
case (true, false), (false, true): return "one"
case (false, false): return "none"
}

fn main() {
  var out: [String] = []
  for i in 1..<16 {
    out.push(fizz(i))
  }
  print(out.join(" "))
  print("${sum([1, 2, 3, 4])} ${both(true, false)}")
}
```

`rill run case_functions.rl`

<!-- include: examples/case_functions.out -->
```text
1 2 Fizz 4 Buzz Fizz 7 8 Fizz Buzz 11 Fizz 13 14 FizzBuzz
10 one
```

[Index](README.md)
