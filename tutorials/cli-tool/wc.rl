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
