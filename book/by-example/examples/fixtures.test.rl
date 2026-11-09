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
  testing.cleanup { print("second") }
  testing.cleanup { print("first") }
  print("body")
}
