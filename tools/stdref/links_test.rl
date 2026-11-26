let links = [
  Link(text: "strings.before", module: "std/strings", item: "before"),
  Link(text: "Reader", module: "std/io", item: "Reader"),
  Link(text: "Int", module: "", item: ""),
  Link(text: "hex", module: "std/encoding/hex", item: ""),
]

test "a link becomes a Markdown link to the anchor" {
  expect(rewriteLinks("see [strings.before] here", links, "json") == "see [strings.before](strings.md#before) here")
  expect(rewriteLinks("[Reader]", links, "encoding/json") == "[Reader](../io.md#Reader)")
}

test "a link to the same page is the anchor only" {
  expect(rewriteLinks("[strings.before]", links, "strings") == "[strings.before](#before)")
}

test "a link to a module has no anchor, relative from a nested page" {
  expect(rewriteLinks("[hex]", links, "encoding/json") == "[hex](hex.md)")
  expect(rewriteLinks("[hex]", links, "strings") == "[hex](encoding/hex.md)")
}

test "a builtin is inline code" {
  expect(rewriteLinks("an [Int] value", links, "strings") == "an `Int` value")
}

test "a name without an entry is plain text" {
  expect(rewriteLinks("the [nothing] here", links, "strings") == "the nothing here")
}

test "a Markdown link is left alone" {
  expect(rewriteLinks("[Reader](other.md) and [Reader](#x)", links, "strings") == "[Reader](other.md) and [Reader](#x)")
}

test "brackets that are not names stay" {
  expect(rewriteLinks("xs[0] and [1, 2] and [a b]", links, "strings") == "xs[0] and [1, 2] and [a b]")
}

test "inline code is left alone" {
  expect(rewriteLinks("use `[Reader]` or ``a [Reader] `b` `` then [Reader]", links, "strings") == "use `[Reader]` or ``a [Reader] `b` `` then [Reader](io.md#Reader)")
}

test "code blocks are left alone" {
  let text = "text [Reader]\n\n    let x = [Reader]\n\n```swift\n[Reader]\n```\n[Reader]"
  let want = "text [Reader](io.md#Reader)\n\n    let x = [Reader]\n\n```swift\n[Reader]\n```\n[Reader](io.md#Reader)"
  expect(rewriteLinks(text, links, "strings") == want)
}

test "relPath" {
  expect(relPath("strings", "io") == "io.md")
  expect(relPath("encoding/json", "io") == "../io.md")
  expect(relPath("encoding/json", "encoding/hex") == "hex.md")
  expect(relPath("hash/sha256", "testing/script") == "../testing/script.md")
}
