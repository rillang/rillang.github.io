import "std/regexp"

fn main() -> Void! {
  let email = regexp.compile("(?P<user>[\\w.]+)@(?P<host>\\w+\\.\\w+)")?
  let text = "write to ada@example.org or bob@test.dev"
  print("${regexp.matches(email, text)}")
  for c in regexp.capturesAll(email, text) {
    print("${regexp.named(c, "user") ?? ""} at ${regexp.named(c, "host") ?? ""}")
  }
  print(regexp.replaceAll(email, text, with: "<\${user}>"))
  let words = regexp.compile("\\s*,\\s*")?
  print("${regexp.split(words, "a, b ,c").len()} parts")
}
