# 9. Concurrency

Rill runs lightweight tasks on all cores. Concurrency is **structured**: a task is always
started inside a `group`, and the group waits for all its tasks. No task outlives the
code that started it, and `main` returning means everything is done.

## group and spawn

<!-- include: examples/group.rl -->
```swift
fn fib(_ n: Int) -> Int {
  if n < 2 {
    return n
  }
  return fib(n - 1) + fib(n - 2)
}

fn main() {
  let results = Channel<Int>(capacity: 8)
  // group waits until every task spawned inside it has finished
  group {
    for i in 0..<4 {
      spawn { results.send(fib(20 + i)) }
    }
  }
  results.close()
  var sum = 0
  for r in results {
    sum += r
  }
  print("sum $sum")
}
```

<!-- include: examples/group.out -->
```text
sum 64079
```

- `spawn { … }` starts a task. It must appear lexically inside a `group { … }` (loops and
  `if`s in between are fine; a nested function or closure is not), otherwise E0024.
- `group { … }` ends when its body and every task spawned in it have finished. Groups nest.
- `return`, `break` or `?` cannot leave a `group` block (E0024).
- A panic in any task ends the program with exit code 101.

## Values crossing into tasks

A task may capture `let` values. They are **deep-copied** when the task starts, so a task
never sees another task's changes. Capturing a `var` is a compile error, because two tasks
could then race on it:

<!-- include: examples/capture_var.err.rl -->
```swift
fn main() {
  var total = 0
  total += 1
  group {
    spawn { print("$total") }
  }
}
```

<!-- include: examples/capture_var.err -->
```text
error[E0025]: 'spawn' cannot capture 'var' total: tasks would share it; capture a 'let' copy
 --> docs/book/examples/capture_var.err.rl:5:11
  |
5 |     spawn { print("$total") }
  |           ^
```

Copy the value into a `let` first, or share it through a `Mutex`, an `Atomic` or a
channel. A value that cannot be copied (a closure capturing something that cannot cross,
a `StringBuilder`) cannot cross a task boundary either (E0025).

## Channels

<!-- include: examples/channels.rl -->
```swift
fn main() {
  // a pipeline: producer -> squarer -> main
  let numbers = Channel<Int>(capacity: 4)
  let squares = Channel<Int>(capacity: 4)
  group {
    spawn {
      for i in 1..<6 {
        numbers.send(i)
      }
      numbers.close()
    }
    spawn {
      for n in numbers {
        squares.send(n * n)
      }
      squares.close()
    }
    var total = 0
    for s in squares {
      total += s
    }
    print("total $total")
  }

  // capacity 0 is a rendezvous; recv returns nil once closed and drained
  let left = Channel<String>(capacity: 2)
  left.send("a")
  left.send("b")
  left.close()
  print("${left.recv() ?? "-"} ${left.recv() ?? "-"} ${left.recv() ?? "-"}")
}
```

<!-- include: examples/channels.out -->
```text
total 55
a b -
```

| Operation | Behaviour |
|---|---|
| `Channel<T>(capacity: n)` | a channel buffering `n` values; `0` makes every send wait for a receiver |
| `ch.send(x)` | waits while the buffer is full; sends a deep copy; panics if the channel is closed |
| `ch.recv()` | waits for a value; returns `nil` once the channel is closed and empty |
| `ch.close()` | no more sends; receivers drain what is left |
| `for x in ch` | receives until the channel is closed and empty |

Channels themselves are shared handles: tasks capture the same channel. There is no
`select` and no timeout yet.

## parMap

<!-- include: examples/parmap.rl -->
```swift
fn collatz(_ start: Int) -> Int {
  var n = start
  var steps = 0
  while n != 1 {
    if n % 2 == 0 {
      n = n / 2
    } else {
      n = 3 * n + 1
    }
    steps += 1
  }
  return steps
}

fn main() {
  var xs: [Int] = []
  for i in 1..<10001 {
    xs.push(i)
  }
  // parMap spreads the work over all cores and keeps the order
  let steps = xs.parMap { collatz($) }
  var best = 0
  for i in 0..<steps.len() {
    if steps[i] > steps[best] {
      best = i
    }
  }
  print("${xs[best]} takes ${steps[best]} steps")
}
```

<!-- include: examples/parmap.out -->
```text
6171 takes 261 steps
```

`xs.parMap { f($) }` is `map` on all cores: the input is split into chunks (four per
worker), each chunk is a task, and the results keep the input order. Elements and results
are copied in and out. A closure returning `U!` gives `[U!]`: errors are values like any
other.

## Mutex and Atomic

<!-- include: examples/shared_state.rl -->
```swift
struct Stats { hits: Int, names: [String] }

fn main() {
  let stats = Mutex(Stats(hits: 0, names: []))
  let counter = Atomic(0)
  group {
    for i in 0..<4 {
      spawn {
        for _ in 0..<1000 {
          let _ = counter.add(1)
        }
        // the value exists only inside the lock block
        stats.lock { s in
          s.hits += 1
          s.names.push("task$i")
        }
      }
    }
  }
  print("${counter.load()}")
  // get() returns a copy
  let snap = stats.get()
  print("${snap.hits} ${snap.names.len()}")
  print("${counter.compareSwap(4000, 0)} ${counter.load()}")
}
```

<!-- include: examples/shared_state.out -->
```text
4000
4 4
true 0
```

- `Mutex(value)` owns a value. `m.lock { v in … }` gives the block exclusive, `inout`
  access; the value cannot escape the block (values flowing in or out are copied).
  `m.get()` returns a copy.
- Inside a `lock` block you cannot use a channel, lock another mutex, `spawn`, start a
  `group`, or leave the block with `return`/`break`/`?` (E0026). This rules out the
  classic ways to deadlock while holding a lock.
- `Atomic(0)` and `Atomic(false)` hold an `Int` or `Bool` (E0027 for other types):
  `load`, `store`, `compareSwap(old, new) -> Bool`, and `add(n)` for `Int`, which returns
  the new value.

## How it runs

Tasks are green threads, scheduled Go-style (tasks, processors, OS threads) with work
stealing and preemption, on `RILL_WORKERS` threads (default: number of cores). Each task
gets a 1 MiB stack reservation (`RILL_STACK`) with a guard page; a stack overflow is a
panic. Blocking system calls hand their processor to another thread. Details:
[GC and concurrency design](../specs/2026-11-01-rill-gc-concurrency-design.md).

Next: [Memory](10-memory.md).
