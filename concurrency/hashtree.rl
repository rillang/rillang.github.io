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
