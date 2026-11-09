# Test fixtures

`testing.tempDir()` gives a fresh directory, `testing.setenv(name, value)` sets a variable, and
`testing.cleanup { ... }` runs a closure when the test ends. Tempdir and setenv clean up after
themselves.

<!-- include: examples/fixtures.test.rl -->
```swift
import "std/fs"
import "std/os"
import "std/testing"

fn greeting() -> String {
  return "hello, ${os.env("FIXTURE_NAME") ?? "nobody"}"
}

test "temp dir" {
  let dir = testing.tempDir()
  let path = "$dir/note.txt"
  fs.writeFile(path, "draft")?
  expect(fs.readFile(path)? == "draft")
}

test "environment" {
  testing.setenv("FIXTURE_NAME", "Ada")
  expect(greeting() == "hello, Ada")
}

test "environment is restored" {
  expect(greeting() == "hello, nobody")
}

test "cleanup" {
  fs.writeFile("fixtures.lock", "held")?
  testing.cleanup {
    let _ = fs.remove("fixtures.lock")
  }
  expect(fs.exists("fixtures.lock"))
}

test "cleanup ran" {
  expect(!fs.exists("fixtures.lock"))
}
```

`rill test fixtures.test.rl`

<!-- include: examples/fixtures.test.out -->
```text
ok    book/by-example/examples/fixtures.test.rl    5 tests   0.00s

result: ok. 5 passed; 1 module in 0.00s
```

Cleanups run in reverse order, before the verdict, also when the test failed. A failing
`expect` in a cleanup fails the test. Fixtures belong to tests: outside one they panic.

[Index](README.md)
