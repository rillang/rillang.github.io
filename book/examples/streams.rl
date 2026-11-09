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
