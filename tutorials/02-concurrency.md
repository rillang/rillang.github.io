# 2. Concurrency: hashing a directory tree

We build `hashtree`: it computes the SHA-256 of every file below a directory, on all
cores, and prints `hash  path` lines in a stable order (like `shasum -a 256`). First
sequentially, then with `parMap`, then with a pool of worker tasks connected by channels,
with shared statistics behind a `Mutex`. We measure each version with `std/time`.

Files: [`concurrency/`](concurrency). Run the commands from that directory.

## Step 1: sequential

<!-- include: concurrency/hash1.rl -->
```swift
// Step 1: hash every file below a directory, one after the other.
import "std/os"
import "std/fs"
import "std/hash/sha256"
import "std/time"

struct Entry { path: String, hash: String, size: Int }

fn hashFile(_ p: String) -> Entry! {
  let data = fs.readFile(p)?
  return Entry(path: p, hash: sha256.sum(data), size: data.len())
}

fn main() -> Void! {
  let args = os.args()
  if args.len() != 1 {
    return fail("usage: hash1 <dir>")
  }
  let start = time.monotonic()
  var bytes = 0
  for f in fs.walk(args[0])? {
    let e = hashFile(f)?
    bytes += e.size
    print("${e.hash}  ${e.path}")
  }
  eprint("$bytes bytes in ${time.text(time.since(start))}")
}
```

- `fs.walk(dir)` returns every file below `dir`, sorted, as paths starting with `dir`.
- `sha256.sum(s)` hashes a `String` (strings are bytes, so a file's contents are a fine
  input) and returns lower-case hex.
- `time.monotonic()` is a clock reading for measuring; `time.since(start)` is the
  `Duration` since then and `time.text` formats it (`"417.218ms"`). Timing goes to standard
  error, so standard output stays the clean list.

<!-- include: concurrency/sessions/step1.txt -->
```text
$ rill run hash1.rl testdata
ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad  testdata/abc.txt
5891b5b522d5df086d0ff0b110fbd9d21bb4fc7163af34d08286a2e846f6be03  testdata/hello.txt
da81937d4f93a5a66ab373527413914cbaff9955c01e61404e142939343263b9  testdata/sub/deep.txt
21 bytes in <time>
```

(`ba7816bf…` is the well-known SHA-256 of `abc`. Durations in these transcripts are
replaced by `<time>`, since they differ on every run.)

Three files are no workload. [`gen.rl`](concurrency/gen.rl) writes a deterministic tree of
400 files, 12 MB in all. Then we build all three versions of this tutorial and check that
they print exactly the same thing:

<!-- include: concurrency/sessions/gen.txt -->
```text
$ rill run gen.rl tree 400
wrote 400 files, 12362088 bytes
$ rill build hash1.rl && rill build hash2.rl && rill build hashtree.rl
$ ./hash1 tree 2>/dev/null | tail -2
f351d07c910e86b972e16a353bb836dfff2d6afc44fcab596bacdd181f625ed1  tree/d03/f0398.txt
2c57273ec0d3f32236f0c303fbe8705d5082e76ac2d0117802084217af6b512b  tree/d03/f0399.txt
$ ./hash1 tree 2>/dev/null | cksum
3511771960 34000
$ ./hash2 tree 2>/dev/null | cksum
3511771960 34000
$ ./hashtree tree 2>/dev/null | cksum
3511771960 34000
```

## Step 2: `parMap`

The loop body is independent per file, which is exactly what `parMap` is for: `map` on all
cores, results in input order.

<!-- include: concurrency/hash2.rl -->
```swift
// Step 2: the same with parMap: every core hashes, the order stays.
import "std/os"
import "std/fs"
import "std/hash/sha256"
import "std/time"

struct Entry { path: String, hash: String, size: Int }

fn hashFile(_ p: String) -> Entry! {
  let data = fs.readFile(p)?
  return Entry(path: p, hash: sha256.sum(data), size: data.len())
}

fn main() -> Void! {
  let args = os.args()
  if args.len() != 1 {
    return fail("usage: hash2 <dir>")
  }
  let start = time.monotonic()
  let files = fs.walk(args[0])?
  // [String] -> [Entry!]: an error is a value like any other
  let results = files.parMap { hashFile($) }
  var bytes = 0
  for r in results {
    let e = r?
    bytes += e.size
    print("${e.hash}  ${e.path}")
  }
  eprint("$bytes bytes in ${time.text(time.since(start))}")
}
```

`files.parMap { hashFile($) }` turns a `[String]` into `[Entry!]`. The errors travel as
values; the loop afterwards decides what to do with them (here: `r?` stops at the first).
Because the order is kept, the output is identical to step 1 (the `cksum` lines above).

## Step 3: a worker pool with channels

`parMap` needs the whole input up front and returns everything at the end. A pipeline
streams instead: one task feeds paths into a channel, `N` workers hash them, and `main`
collects results as they come. Statistics are shared through a `Mutex`.

<!-- include: concurrency/hashtree.rl -->
```swift
// hashtree [-j N] <dir>: hashes every file below <dir> with N worker tasks.
import "std/os"
import "std/fs"
import "std/hash/sha256"
import "std/time"

struct Entry { path: String, hash: String, size: Int }

struct Stats { files: Int, bytes: Int, failed: [String] }

fn hashFile(_ p: String) -> Entry! {
  let data = fs.readFile(p)?
  return Entry(path: p, hash: sha256.sum(data), size: data.len())
}

fn main() -> Void! {
  var args = os.args()
  var workers = 4
  if args.len() == 3 && args[0] == "-j" {
    workers = args[1].toInt() ?? 0
    args = args.slice(2, 3)
  }
  if args.len() != 1 || workers < 1 {
    return fail("usage: hashtree [-j N] <dir>")
  }
  let start = time.monotonic()
  let files = fs.walk(args[0])?
  let jobs = Channel<String>(capacity: 64)
  let results = Channel<Entry>(capacity: 64)
  let stats = Mutex(Stats(files: 0, bytes: 0, failed: []))
  let n = workers
  var entries: [Entry] = []
  group {
    // producer and workers; when they are all done, nothing more can arrive
    spawn {
      group {
        spawn {
          for f in files {
            jobs.send(f)
          }
          jobs.close()
        }
        for _ in 0..<n {
          spawn {
            for p in jobs {
              switch hashFile(p) {
              case .ok(e):
                stats.lock { s in
                  s.files += 1
                  s.bytes += e.size
                }
                results.send(e)
              case .err(err):
                stats.lock { s in s.failed.push(err.msg) }
              }
            }
          }
        }
      }
      results.close()
    }
    // meanwhile main collects
    for e in results {
      entries.push(e)
    }
  }
  // workers finish in any order: sort for a stable output
  let sorted = entries.sortBy { a, b in a.path < b.path }
  for e in sorted {
    print("${e.hash}  ${e.path}")
  }
  let s = stats.get()
  for msg in s.failed {
    eprint("hashtree: $msg")
  }
  eprint("${s.files} files, ${s.bytes} bytes, $n tasks, ${time.text(time.since(start))}")
}
```

How it fits together:

- **Structured concurrency.** `spawn` only works lexically inside a `group`, and a `group`
  ends when all its tasks have ended. The inner `group` holds the producer and the
  workers; once it ends, no task can send a result any more, so the task around it closes
  `results`. Meanwhile `main` drains `results` in the outer group. When the outer group
  ends, all tasks are done: nothing outlives `main`.
- **Channels** are shared handles. `jobs.send(f)` waits while the buffer (64) is full;
  `for p in jobs` receives until the channel is closed and empty, so every worker stops
  by itself after `jobs.close()`.
- **The `Mutex`** owns its value. `stats.lock { s in … }` is the only way to reach it,
  with exclusive access; `stats.get()` returns a copy. Inside a lock block you cannot use
  channels, spawn or lock another mutex (E0026), so `results.send(e)` comes after the
  block, never inside it. That rules out the classic deadlocks.
- **Ordering.** Workers finish in any order, so `main` sorts by path before printing:
  same output as before.

### Values cross task boundaries as copies

A task may capture `let` values only, and gets a **deep copy** of each when it starts.
The producer works on its own copy of `files`; `Entry` values sent through `results`
arrive as copies too. No task can ever see another task change a value under it, so there
are no data races on ordinary values; sharing is explicit (`Channel`, `Mutex`, `Atomic`).

That is why the program copies `var workers` into `let n` before spawning. Capturing the
`var` directly is a compile error, because two tasks could then race on it:

<!-- include: concurrency/sessions/capture.txt -->
```text
$ sed "s/0..<n {/0..<workers {/" hashtree.rl >capture.rl
$ rill build capture.rl
error[E0025]: 'spawn' cannot capture 'var' workers: tasks would share it; capture a 'let' copy
  --> capture.rl:35:11
   |
35 |     spawn {
   |           ^
[exit 1]
```

### Errors keep flowing

A file that cannot be read becomes an entry in `Stats.failed` instead of ending the run:

<!-- include: concurrency/sessions/failure.txt -->
```text
$ chmod 000 testdata/hello.txt
$ ./hashtree testdata
ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad  testdata/abc.txt
da81937d4f93a5a66ab373527413914cbaff9955c01e61404e142939343263b9  testdata/sub/deep.txt
hashtree: cannot open file: testdata/hello.txt
2 files, 15 bytes, 4 tasks, <time>
$ chmod 644 testdata/hello.txt
```

## Measuring

<!-- include: concurrency/sessions/timing.txt -->
```text
$ ./hash1 tree >/dev/null
12362088 bytes in <time>
$ ./hash2 tree >/dev/null
12362088 bytes in <time>
$ ./hashtree -j 1 tree >/dev/null
400 files, 12362088 bytes, 1 tasks, <time>
$ ./hashtree -j 4 tree >/dev/null
400 files, 12362088 bytes, 4 tasks, <time>
```

On a 10-core Apple M-series Mac the real numbers were about: sequential 415 ms,
`parMap` 190 ms, one worker 425 ms, four workers 145 ms, ten workers 150–230 ms. The
speed-up stops at about three: hashing allocates (`sha256.sum` turns the string into an
array with one `Int` per byte), and allocation and garbage collection are shared by all
tasks. More workers than that only add contention. Measure before you pick a number;
`RILL_WORKERS` sets how many OS threads run tasks (default: the number of cores).

## Exercises

- Skip files above a size limit (`fs.stat(p)?.size`).
- Report duplicates: group entries by hash in a `Map<String, [String]>`.
- Replace the `Mutex` counters with two `Atomic(0)`s (`add`, `load`).

Next: [3. A JSON configuration](03-json-config.md).
