# 10. Memory

Two rules cover what a Rill programmer needs to know about memory:

1. **Everything is a value.** Assigning, passing and returning never create a shared,
   mutable alias. This holds for `Int`s, structs, enums, strings, arrays and maps alike.
2. **Memory is reclaimed automatically** by a garbage collector. There is no `free`, no
   ownership annotation and no lifetime.

## Value semantics

<!-- include: examples/value_semantics.rl -->
```swift
struct Team { name: String, members: [String] }

fn withMember(_ t: Team, _ m: String) -> Team {
  var copy = t
  copy.members.push(m)
  return copy
}

fn addMember(_ t: inout Team, _ m: String) {
  t.members.push(m)
}

fn main() {
  // arrays are values: b keeps its own elements
  var a = [1, 2, 3]
  let b = a
  a.push(4)
  print("a=${a.len()} b=${b.len()}")

  // the same holds inside structs and maps, at any depth
  let red = Team(name: "red", members: ["ana"])
  let bigger = withMember(red, "bo")
  print("${red.members.len()} ${bigger.members.len()}")

  var grid = [[1, 2], [3, 4]]
  let snapshot = grid
  grid[0].push(9)
  print("${grid[0].len()} ${snapshot[0].len()}")

  // inout is the one way to change a caller's value
  var blue = Team(name: "blue", members: [])
  addMember(&blue, "cy")
  print("${blue.members.len()}")
}
```

<!-- include: examples/value_semantics.out -->
```text
a=4 b=3
1 2
3 2
1
```

Arrays and maps are copied **lazily**: an assignment shares the storage and marks it
shared; the first write to a shared array or map copies it (copy on write). Passing a large
array to a function costs nothing unless one side changes it.

What is shared:

- `Channel`, `Mutex` and `Atomic` values are handles: every copy refers to the same
  channel, lock or counter. That is their purpose.
- `inout` parameters write through to the caller's variable for the duration of the call.

Closures capture values when they are created ([chapter 2](02-basics.md#closures)). Values
crossing into a task are deep copies ([chapter 9](09-concurrency.md)).

## The garbage collector

- Non-moving, **conservative** mark and sweep: any word that looks like a pointer into the
  heap keeps its object alive. No stack maps are needed, which keeps the compiler simple.
- Marking runs in parallel on all workers (in the style of Go's "Green Tea" collector:
  spans are queued and scanned in address order). Sweeping is lazy.
- Allocation goes through per-processor caches of size-class spans without locks.
- Memory without pointers (string bytes, arrays of numbers, flags and structs made of
  them) lives in "noscan" spans: the collector marks it but never reads it.
- Freed page runs merge with their free neighbours, so large objects reuse them.
- A collection starts when the heap has grown by `RILL_GC` percent (default 100) since the
  last one. `RILL_GC=off` disables collection, `RILL_GC=stress:N` collects every N
  allocations and poisons freed memory (for testing the runtime). A program can set the
  percentage itself with `runtime.setGcPercent` (`std/runtime`); the compiler uses 200.
- `RILL_GCTRACE=1` prints every collection, `RILL_ALLOCPROF=1` the allocation sites with
  the most bytes at exit.

Costs today, from [`docs/perf.md`](https://github.com/rillang/rill/blob/main/docs/perf.md):
the compiler compiling itself (30 000 lines) allocates about 1 GB, keeps at most ~60 MB
live and spends about a third of a second in the collector, with a peak of ~330 MB
resident memory. Memory is not yet returned to the operating system.

## Unsafe code

The runtime (`runtime/rt_*.rl`) is written in Rill with an unsafe dialect (raw pointers,
loads and stores, system calls). It is allowed only under `runtime/` (E0023 elsewhere).
Ordinary programs cannot use it.

Next: [Tooling](11-tooling.md).
