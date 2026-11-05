# 5. Scripts

Three small chores that would otherwise be a shell or Python one-off, written as Rill
scripts: a file that starts with `#!/usr/bin/env rill`, made executable, run by name. No
project, no `rill.mod`, no build step.

Files: [`scripts/`](scripts). Run the commands from that directory, with `rill` on your
`PATH`.

## How a script runs

`#!/usr/bin/env rill` makes the system call `rill todo.rl notes` for `./todo.rl notes`;
a first argument that ends in `.rl` is short for `rill run`. The first run compiles. Later
runs of the unchanged file start the binary `rill run` kept in `~/.cache/rill/run`, without
compiling. A changed file compiles again, reusing the functions that did not change.

What that costs, measured on an M-series Mac for `todo.rl` below (medians):

| | time |
|---|---|
| first run (empty cache) | 258 ms |
| next runs, file unchanged | 14 ms |
| after editing a comment | 86 ms |
| for comparison: `python3` walking the same directory | 18 ms |
| for comparison: `grep -rn` | 8 ms |

Scripts use the standard library ([chapter 15](../book/15-standard-library.md)): `std/fs`
for files, `std/os` for arguments and processes, `std/json`, `std/time`. A script still has
a `fn main()`, and errors go through `T!` and `?` like in any program.

## 1. Find every TODO: files

`todo.rl` prints each line with `TODO` in the `.md` and `.txt` files below a directory:

<!-- include: scripts/todo.rl -->
```swift
#!/usr/bin/env rill
// todo: every TODO line in the text files below a directory, as path:line: text.
import "std/fs"
import "std/os"
import "std/path"
import "std/strings"

fn main() -> Void! {
  let args = os.args()
  let root = if args.len() > 0 { args[0] } else { "." }
  var found = 0
  for file in fs.walk(root)? {
    if path.ext(file) != ".md" && path.ext(file) != ".txt" {
      continue
    }
    let lines = fs.readFile(file)?.lines()
    for i in 0..<lines.len() {
      if strings.contains(lines[i], "TODO") {
        print("$file:${i + 1}: ${lines[i].trim()}")
        found += 1
      }
    }
  }
  print("$found TODOs")
}
```

`fs.walk` lists every file below a directory, sorted; `main() -> Void!` lets `?` end the
script with the error if a file cannot be read.

<!-- include: scripts/sessions/todo.txt -->
```text
$ ./todo.rl notes
notes/2026/november.md:3: TODO: renew the passport
notes/2026/november.md:4: TODO: back up the photos
notes/shopping.txt:3: TODO bread (the good one)
notes/trip.md:4: - TODO: ask Linus about the tent
4 TODOs
$ rill todo.rl notes/2026
notes/2026/november.md:3: TODO: renew the passport
notes/2026/november.md:4: TODO: back up the photos
2 TODOs
```

## 2. Tidy file names: a dry run first

`tidy.rl` renames files to lower case with dashes. Without `--apply` it only shows what it
would do; a name that already exists is skipped instead of overwritten. The renaming rule
is a function with a `test` block, so `rill test` checks it:

<!-- include: scripts/tidy.rl -->
```swift
#!/usr/bin/env rill
// tidy: file names in lower case with dashes instead of spaces. Shows what it would
// do; --apply renames.
import "std/fs"
import "std/os"
import "std/slices"
import "std/strings"

fn tidyName(_ name: String) -> String = strings.replace(strings.toLower(name.trim()), " ", "-")

test "tidyName" {
  expect(tidyName("Beach Day 01.JPG") == "beach-day-01.jpg")
  expect(tidyName("ok.png") == "ok.png")
}

fn main() -> Void! {
  var apply = false
  var dir = "."
  for a in os.args() {
    if a == "--apply" {
      apply = true
    } else {
      dir = a
    }
  }
  var changes = 0
  let names = fs.readDir(dir)?
  for name in names {
    let tidy = tidyName(name)
    if tidy == name {
      continue
    }
    // the listing, not fs.exists: on macOS `IMG.HEIC` and `img.heic` are one file
    if slices.contains(names, tidy) {
      print("skip $name: $tidy exists")
      continue
    }
    print("$name -> $tidy")
    if apply {
      fs.rename("$dir/$name", "$dir/$tidy")?
    }
    changes += 1
  }
  if !apply && changes > 0 {
    print("(dry run: --apply renames)")
  }
}
```

<!-- include: scripts/sessions/tidy.txt -->
```text
$ rill test tidy.rl
ok    tidy.rl    1 test   0.00s

result: ok. 1 passed; 1 module in 0.00s
$ ./tidy.rl photos
skip Beach Day 01.JPG: beach-day-01.jpg exists
Beach Day 02.JPG -> beach-day-02.jpg
IMG_0042.HEIC -> img_0042.heic
(dry run: --apply renames)
$ ./tidy.rl --apply photos
skip Beach Day 01.JPG: beach-day-01.jpg exists
Beach Day 02.JPG -> beach-day-02.jpg
IMG_0042.HEIC -> img_0042.heic
$ ls photos
Beach Day 01.JPG
beach-day-01.jpg
beach-day-02.jpg
img_0042.heic
sunset.jpg
```

The check against the directory listing instead of `fs.exists` matters on macOS: there
`IMG_0042.HEIC` and `img_0042.heic` are the same file, and `fs.exists` would call the
rename a conflict.

## 3. A task runner: JSON and processes

`tasks.rl` reads a list of commands from `tasks.json`, runs them in order with `os.run`
(the command's output goes straight to the terminal), times each one and stops at the first
that fails, with its exit code:

<!-- include: scripts/tasks.json -->
```json
{
  "tasks": [
    { "name": "list notes", "run": ["ls", "notes"] },
    { "name": "count todos", "run": ["grep", "-c", "TODO", "notes/trip.md"] },
    { "name": "missing file", "run": ["cat", "notes/nope.md"] },
    { "name": "never runs", "run": ["echo", "unreachable"] }
  ]
}
```

<!-- include: scripts/tasks.rl -->
```swift
#!/usr/bin/env rill
// tasks: runs the commands of tasks.json in order and stops at the first that fails,
// with the time each one took.
import "std/fs"
import "std/json"
import "std/os"
import "std/time"

fn main() -> Void! {
  let args = os.args()
  let file = if args.len() > 0 { args[0] } else { "tasks.json" }
  let tasks = json.parse(fs.readFile(file)?)?
  for t in json.items(json.get(tasks, "tasks")) {
    let name = json.str(json.get(t, "name")) ?? "?"
    let argv = json.items(json.get(t, "run")).map { a in json.str(a) ?? "" }
    let start = time.monotonic()
    let code = os.run(argv)?
    print("== $name: exit $code in ${time.text(time.since(start))}")
    if code != 0 {
      os.exit(code)
    }
  }
}
```

<!-- include: scripts/sessions/tasks.txt -->
```text
$ ./tasks.rl
2026
shopping.txt
trip.md
== list notes: exit 0 in <time>
1
== count todos: exit 0 in <time>
cat: notes/nope.md: No such file or directory
== missing file: exit 1 in <time>
[exit 1]
```

`os.runCapture` returns the output as a string instead, when the script needs to read it.

## Limits today

- The file needs the `.rl` suffix: `./deploy` without it does not run.
- A script is a program: `fn main()`, `import` lines for the standard library.
- No networking yet: `std/net` comes with v0.5, HTTP with v0.7 ([roadmap](https://github.com/rillang/rill/blob/main/docs/ROADMAP.md)).

## Exercises

- `todo.rl`: take the word to look for from a `--word` argument.
- `tidy.rl`: also replace `_` with `-`, and add the case to its `test` block.
- `tasks.rl`: a `"dir"` field per task (hint: `sh -c "cd dir && …"` through `os.run`).

Back to the [tutorials](README.md).
