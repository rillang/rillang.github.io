# 16. Files and streams

**Partly planned.** `std/io` (this page) exists; buffered readers and writers (`std/bufio`),
file handles and `stdin`/`stdout` as streams come in later phases of
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
