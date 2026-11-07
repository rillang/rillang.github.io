# 1. A command-line tool: `wc`

We build a small clone of `wc`: it counts the lines, words and bytes of files (or of
standard input), takes `-l`, `-w` and `-c` flags, prints a total for several files and
reports unreadable files without stopping. Along the way: `std/os`, `std/fs`, results
(`T!`) and `?`, `test` blocks, `rill build`, warnings and `rill fmt`.

All files are in [`cli-tool/`](cli-tool). Run the commands from that directory.

## Step 1: one file, its lines

<!-- include: cli-tool/wc1.rl -->
```swift
// Step 1: count the lines of one file named on the command line.
import "std/os"
import "std/fs"

fn main() -> Void! {
  let args = os.args()
  if args.len() != 1 {
    return fail("usage: wc1 <file>")
  }
  let text = fs.readFile(args[0])?
  print("${text.lines().len()} ${args[0]}")
}
```

- `os.args()` is the argument list without the program name.
- `fs.readFile` returns `String!`: the contents or an `Error`. The `?` after it returns
  the error from `main`, otherwise it is the string.
- `main` returns `Void!`, so an error that reaches its end is printed as `error: …` and
  the program exits with code 1. `return fail("…")` makes such an error yourself.

<!-- include: cli-tool/sessions/step1.txt -->
```text
$ rill run wc1.rl testdata/fox.txt
3 testdata/fox.txt
$ rill run wc1.rl
error: usage: wc1 <file>
[exit 1]
$ rill run wc1.rl missing.txt
error: read missing.txt: no such file
[exit 1]
```

`rill run` compiles to a temporary binary and runs it; arguments after the file go to the
program.

## Step 2: words and bytes, with tests

A word is a run of non-space bytes. We walk the bytes once (strings are bytes in Rill:
`len()` and `byteAt(i)`; character literals like `' '` are `Int`s) and keep the three
numbers in a struct:

<!-- include: cli-tool/wc2.rl -->
```swift
// Step 2: lines, words and bytes, with tests.
import "std/os"
import "std/fs"

struct Counts { lines: Int, words: Int, bytes: Int }

fn isSpace(_ b: Int) -> Bool = b == ' ' || b == '\n' || b == '\t' || b == '\r'

fn count(_ text: String) -> Counts {
  var c = Counts(lines: 0, words: 0, bytes: text.len())
  var inWord = false
  for i in 0..<text.len() {
    let b = text.byteAt(i)
    if b == '\n' {
      c.lines += 1
    }
    if isSpace(b) {
      inWord = false
    } else if !inWord {
      inWord = true
      c.words += 1
    }
  }
  return c
}

fn main() -> Void! {
  for f in os.args() {
    let c = count(fs.readFile(f)?)
    print("${c.lines} ${c.words} ${c.bytes} $f")
  }
}

test "count" {
  expect(count("") == Counts(lines: 0, words: 0, bytes: 0))
  expect(count("one two\nthree\n") == Counts(lines: 2, words: 3, bytes: 14))
  expect(count("  spaced   out  ") == Counts(lines: 0, words: 2, bytes: 16))
}
```

`count` is a pure function, so it is easy to test. `test` blocks live next to the code;
`rill test` runs them (and not `main`). Structs compare with `==` field by field, so
`expect(count(…) == Counts(…))` needs no helpers.

<!-- include: cli-tool/sessions/step2.txt -->
```text
$ rill test wc2.rl
ok    wc2.rl    1 test   0.00s

result: ok. 1 passed; 1 module in 0.00s
$ rill run wc2.rl testdata/fox.txt testdata/rill.txt
3 9 45 testdata/fox.txt
4 11 66 testdata/rill.txt
```

A broken `count` (every word counted twice) makes the tests fail with the line of each
failed `expect`; `rill test` exits with 1:

<!-- include: cli-tool/sessions/broken.txt -->
```text
$ sed "s/c.words += 1/c.words += 2/" wc2.rl >broken.rl
$ rill test broken.rl
FAIL  broken.rl    1 test   0.00s   (1 failed)

failures:

--- FAIL broken.rl: count
broken.rl:36: expect(count("one two\nthree\n") == Counts(lines: 2, words: 3, bytes: 14))
    left:  Counts(lines: 2, words: 6, bytes: 14)
    right: Counts(lines: 2, words: 3, bytes: 14)
broken.rl:37: expect(count("  spaced   out  ") == Counts(lines: 0, words: 2, bytes: 16))
    left:  Counts(lines: 0, words: 4, bytes: 16)
    right: Counts(lines: 0, words: 2, bytes: 16)

result: FAIL. 0 passed, 1 failed; 1 module in 0.00s
[exit 1]
```

`var c` is a value: `c.lines += 1` changes this function's copy only. Rill has value
semantics for structs and arrays everywhere, so passing `c` to another function can never
change it behind your back.

## Step 3: flags, several files, standard input

The finished tool:

<!-- include: cli-tool/wc.rl -->
```swift
// wc: counts lines, words and bytes of files (or standard input).
import "std/os"
import "std/fs"
import "std/fmt"

struct Counts { lines: Int, words: Int, bytes: Int }

struct Options { lines: Bool, words: Bool, bytes: Bool, files: [String] }

fn isSpace(_ b: Int) -> Bool = b == ' ' || b == '\n' || b == '\t' || b == '\r'

fn count(_ text: String) -> Counts {
  var c = Counts(lines: 0, words: 0, bytes: text.len())
  var inWord = false
  for i in 0..<text.len() {
    let b = text.byteAt(i)
    if b == '\n' {
      c.lines += 1
    }
    if isSpace(b) {
      inWord = false
    } else if !inWord {
      inWord = true
      c.words += 1
    }
  }
  return c
}

fn add(_ a: Counts, _ b: Counts) -> Counts = Counts(lines: a.lines + b.lines, words: a.words + b.words, bytes: a.bytes + b.bytes)

fn parseArgs(_ args: [String]) -> Options! {
  var o = Options(lines: false, words: false, bytes: false, files: [])
  for a in args {
    switch a {
    case "-l": o.lines = true
    case "-w": o.words = true
    case "-c": o.bytes = true
    default:
      if a.startsWith("-") {
        return fail("unknown flag $a (use -l, -w, -c)")
      }
      o.files.push(a)
    }
  }
  if !o.lines && !o.words && !o.bytes {
    o.lines = true
    o.words = true
    o.bytes = true
  }
  return o
}

fn row(_ c: Counts, _ name: String, _ o: Options) -> String {
  var cols: [String] = []
  if o.lines {
    cols.push(fmt.pad("${c.lines}", width: 7, align: .right))
  }
  if o.words {
    cols.push(fmt.pad("${c.words}", width: 7, align: .right))
  }
  if o.bytes {
    cols.push(fmt.pad("${c.bytes}", width: 7, align: .right))
  }
  if name != "" {
    cols.push(name)
  }
  return cols.join(" ")
}

fn readAllStdin() -> String {
  var sb = StringBuilder()
  while true {
    let chunk = os.readStdin(65536)
    if chunk == "" {
      break
    }
    sb.add(chunk)
  }
  return sb.build()
}

fn main() -> Void! {
  let o = parseArgs(os.args())?
  if o.files.len() == 0 {
    print(row(count(readAllStdin()), "", o))
    return
  }
  var total = Counts(lines: 0, words: 0, bytes: 0)
  var failed = false
  for f in o.files {
    switch fs.readFile(f) {
    case .ok(text):
      let c = count(text)
      total = add(total, c)
      print(row(c, f, o))
    case .err(e):
      eprint("wc: ${e.msg}")
      failed = true
    }
  }
  if o.files.len() > 1 {
    print(row(total, "total", o))
  }
  if failed {
    os.exit(1)
  }
}

test "count" {
  expect(count("") == Counts(lines: 0, words: 0, bytes: 0))
  expect(count("one two\nthree\n") == Counts(lines: 2, words: 3, bytes: 14))
  expect(count("  spaced   out  ") == Counts(lines: 0, words: 2, bytes: 16))
}

test "parseArgs" {
  let all = parseArgs(["a.txt"]) ?? Options(lines: false, words: false, bytes: false, files: [])
  expect(all.lines && all.words && all.bytes && all.files == ["a.txt"])
  let l = parseArgs(["-l", "x", "y"]) ?? Options(lines: false, words: false, bytes: false, files: [])
  expect(l.lines && !l.words && l.files.len() == 2)
  switch parseArgs(["-x"]) {
  case .ok(_): expect(false)
  case .err(e): expect(e.msg == "unknown flag -x (use -l, -w, -c)")
  }
}
```

What is new:

- **Parsing arguments** returns `Options!`. An unknown flag is an error made with
  `fail(…)`; `parseArgs(os.args())?` in `main` turns it into `error: …` and exit code 1.
  `switch` on a `String` matches literal cases; `default` takes the rest.
- **Handling an error instead of propagating it**: a missing file should not stop the
  others, so `main` takes the result of `fs.readFile` apart with `switch` (`.ok(text)` /
  `.err(e)`), prints `e.msg` to standard error with `eprint`, and exits with 1 at the end
  (`os.exit`). A result is an enum; `if let` would take the value and skip the error, but
  here the error must be reported, so `switch` looks inside (the test does it too).
- **Columns** come from `fmt.pad(s, width: 7, align: .right)` of `std/fmt`.
- **Standard input**: `os.readStdin(max)` returns up to `max` bytes and `""` at the end;
  a `StringBuilder` collects the chunks.
- In tests, `?` is not allowed, so `parseArgs(…) ?? fallback` gives a value to inspect.

<!-- include: cli-tool/sessions/test.txt -->
```text
$ rill test wc.rl
ok    wc.rl    2 tests   0.00s

result: ok. 2 passed; 1 module in 0.00s
```

## Build a binary

`rill build wc.rl` writes the executable `wc` (`-o name` picks another name). There is no
C toolchain involved: the compiler writes the Mach-O or ELF file itself. Add
`--target=linux-arm64` on a Mac for a static Linux binary.

<!-- include: cli-tool/sessions/build.txt -->
```text
$ rill build wc.rl
$ ./wc testdata/fox.txt testdata/rill.txt
      3       9      45 testdata/fox.txt
      4      11      66 testdata/rill.txt
      7      20     111 total
$ ./wc -l testdata/fox.txt missing.txt
      3 testdata/fox.txt
wc: read missing.txt: no such file
      3 total
[exit 1]
$ printf "one two\nthree\n" | ./wc -w
      3
$ ./wc -q
error: unknown flag -q (use -l, -w, -c)
[exit 1]
```

The output matches the system `wc` (which pads to 8 columns).

## Unused code and warnings

As in Go, an import that nothing uses and a local that is never read are errors:
[`unused.warn.rl`](cli-tool/unused.warn.rl) does not build.

<!-- include: cli-tool/unused.warn.rl -->
```swift
import "std/strings"
import "std/fs"

fn main() -> Void! {
  let unused = 42
  let text = fs.readFile("testdata/fox.txt")?
  print("${text.len()} bytes")
}
```

<!-- include: cli-tool/sessions/unused.txt -->
```text
$ rill build unused.warn.rl -o unused
error[E0043]: import "std/strings" is not used
 --> unused.warn.rl:1:1
  |
1 | import "std/strings"
  | ^

error[E0042]: 'unused' is never used (name it _unused if that is intended)
 --> unused.warn.rl:5:3
  |
5 |   let unused = 42
  |   ^
[exit 1]
```

Remove the import, and remove the local or name it `_unused` if it is there on purpose.

Other code that is probably a mistake gets a warning: the build still succeeds.
`--deny-warnings` turns warnings into errors, which is what you want in CI.
[`warnings.warn.rl`](cli-tool/warnings.warn.rl) declares a `var` it never changes:

<!-- include: cli-tool/warnings.warn.rl -->
```swift
import "std/fs"

fn main() -> Void! {
  var name = "fox.txt"
  let text = fs.readFile("testdata/" + name)?
  print("${text.len()} bytes")
}
```

<!-- include: cli-tool/sessions/warnings.txt -->
```text
$ rill build warnings.warn.rl -o warnings
warning[W0004]: 'name' is never changed: declare it with let
 --> warnings.warn.rl:4:3
  |
4 |   var name = "fox.txt"
  |   ^
$ rill build --deny-warnings warnings.warn.rl -o warnings
error[W0004]: 'name' is never changed: declare it with let
 --> warnings.warn.rl:4:3
  |
4 |   var name = "fox.txt"
  |   ^
[exit 1]
```

Fix it with `let name`, or silence a warning on purpose with `/// allow: W0004` above the
function. The full list of errors and warnings is in
[docs/errors.md](https://github.com/rillang/rill/blob/main/docs/errors.md).

## Formatting

`rill fmt` has one style and no options. `--check` lists files that are not formatted
(exit 1), `--stdout` prints the result, and without flags it rewrites the files in place:

<!-- include: cli-tool/sessions/fmt.txt -->
```text
$ rill fmt --check messy.fmt.rl
messy.fmt.rl
[exit 1]
$ rill fmt --stdout messy.fmt.rl
fn isSpace(_ b: Int) -> Bool = b == ' ' || b == '\n'
fn main() {
  var n = 0
  for b in [32, 65, 10] { if isSpace(b) { n += 1 } }
  print("$n")
}
```

`rill fmt` fixes indentation and spacing but does not re-break lines: the one-line `for`
stays one line. `rill lsp --check wc.rl` prints the diagnostics an editor would show
(errors and warnings) and is the other check to put in CI next to `rill fmt --check`.

## Exercises

- Add `-m` for the number of UTF-8 characters (`std/utf8` has `runeCount`).
- Print the longest line's length with `-L`.
- Count stdin when a file argument is `-`.

Next: [2. Concurrency](02-concurrency.md).
