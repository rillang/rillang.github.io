# 16. Files and streams

**Partly planned.** `std/io` and files (`fs.File`) exist; buffered readers and writers
(`std/bufio`) come in a later phase of
[RFC 0019](https://github.com/rillang/rill/blob/main/docs/rfcs/0019-io-streams.md).

A stream moves bytes. `std/io` defines what readers and writers look like and a few
functions that work with any of them:

```swift
pub interface Reader { fn read(inout self, _ buf: inout Bytes) -> Int! }
pub interface Writer { fn write(inout self, _ b: Bytes) -> Int! }
pub interface Closer { fn close(inout self) -> Void! }
```

`inout self`: a stream changes as it is used, and a copy of a stream value never shares
that state. Calls need a `var`.

| Contract | |
|---|---|
| `read` | fills `buf[0..<n]` with `0 < n <= buf.len()`; `0` means the end of input; an empty `buf` panics |
| `write` | writes all of `b` or fails (`io.shortWrite`); returns `b.len()` |

## Buffer

`io.Buffer` is bytes in memory, read from the front and written at the end: a `Reader` and
a `Writer`. `io.buffer(bytes)` makes one, `io.bytes(b)` returns what is not read yet.
`io.copy` moves everything from a reader to a writer, `io.readAll` reads to the end,
`io.readFull` fills a buffer or fails with `io.unexpectedEof`, `io.writeString` writes a
`String`. Any function `read(_ x: inout T, _ buf: inout Bytes) -> Int!` makes `T` a reader.

<!-- include: examples/streams.rl -->
```swift
import "std/io"

fn text(_ b: Bytes) -> String = String(utf8: b) ?? "?"

// A custom Reader: two bytes per call, to show that readers may return short counts.
// A type is a Reader when a function `read(_ x: inout T, _ buf: inout Bytes) -> Int!` exists.
struct Trickle {
  data: Bytes
  pos: Int
}

fn read(_ t: inout Trickle, _ buf: inout Bytes) -> Int! {
  var n = t.data.len() - t.pos
  if n > 2 {
    n = 2
  }
  for i in 0..<n {
    buf[i] = t.data[t.pos + i]
  }
  t.pos += n
  return n
}

fn main() -> Void! {
  var src = io.buffer("hello, streams".bytes())
  var dst = io.buffer(Bytes(0))
  let n = io.copy(&dst, &src)?
  print("copied $n: ${text(io.bytes(dst))}")

  var slow = Trickle(data: "trickle".bytes(), pos: 0)
  let all = io.readAll(&slow)?
  print("readAll ${text(all)}")

  var short = io.buffer("abc".bytes())
  var four = Bytes(4)
  switch io.readFull(&short, &four) {
  case .ok(_): print("readFull: ok")
  case .err(e): print("readFull: ${e.is(io.unexpectedEof)}")
  }
}
```

<!-- include: examples/streams.out -->
```text
copied 14: hello, streams
readAll trickle
readFull: true
```

A `Buffer` never compacts: bytes already read stay in memory until the buffer goes.
`io.copy` uses one 32 KiB buffer; a reader that returns short counts (pipes, terminals)
costs one 32 KiB allocation per short read.

## Files

`fs.open` opens a file for reading, `fs.create` for writing (empty, mode 0644 before the
umask), `fs.append` for writing at the end (created when missing). Each returns a `File`:
a `Reader`, a `Writer` and a `Closer`. Close it on every exit with `defer`; `close` is
idempotent. A `File` is a descriptor: copies share it and its closed state, so closing one
closes all.

<!-- include: examples/files.rl -->
```swift
import "std/fs"
import "std/io"

// Writes a file, reads it back and copies it to stdout. defer closes the file at every exit.
fn save(_ path: String, _ text: String) -> Void! {
  var f = fs.create(path)?
  defer { let _ = f.close() }
  io.writeString(&f, text)?
}

fn show(_ path: String) -> Void! {
  var f = fs.open(path)?
  defer { let _ = f.close() }
  var out = io.stdout()
  io.copy(&out, &f)?
}

fn main() -> Void! {
  let dir = fs.tempDir("files")?
  let path = "$dir/hello.txt"
  save(path, "hello, files\n")?
  show(path)?

  // errors name the operation and the file and carry the fs sentinel as cause
  switch fs.open("$dir/missing.txt") {
  case .ok(_): print("opened?")
  case .err(e): print("notFound: ${e.is(fs.notFound)}")
  }

  // a closed file reports io.closed
  var f = fs.open(path)?
  f.close()?
  var buf = Bytes(8)
  switch f.read(&buf) {
  case .ok(_): print("read?")
  case .err(e): print("closed: ${e.is(io.closed)}")
  }
}
```

<!-- include: examples/files.out -->
```text
hello, files
notFound: true
closed: true
```

Every error of a `File` names the operation and the file (`open /tmp/x: no such file`). When
the operating system's error has a sentinel it is the cause (`fs.notFound`, `fs.permission`,
`fs.isDir`, `fs.notDir`), so `e.is(fs.notFound)` works through the context. A read or write
after `close` fails with `fs.closed`; `io.closed` is the same value.

## Standard streams

`io.stdin()`, `io.stdout()` and `io.stderr()` are `File`s on descriptors 0, 1 and 2 (also
`fs.stdin()` and so on). They are functions because a top-level `let` must be a constant.
Each call returns a new `File`, and closing one closes the process's descriptor: close a
standard stream at most once, or not at all. `cat` is three lines:

```swift
import "std/io"

fn main() -> Void! {
  var i = io.stdin()
  var o = io.stdout()
  io.copy(&o, &i)?
}
```

A task blocked reading standard input does not stop the other tasks. `print` is unchanged
and unbuffered; `os.readStdin` still works, but prefer `io.stdin()` for streaming.
