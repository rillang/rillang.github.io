# 3. A JSON configuration

We build `cfg`, the configuration loader of an imaginary backup tool. It reads a JSON file
with `std/json`, takes the value tree apart with pattern matching, fills in defaults,
collects **every** problem instead of stopping at the first, and prints the effective
configuration as pretty JSON.

Files: [`json-config/`](json-config). Run the commands from that directory.

The configuration we want to accept:

<!-- include: json-config/backup.json -->
```json
{
  "name": "nightly",
  "sources": ["/home/ada/docs", "/home/ada/photos"],
  "target": { "host": "backup.example.com", "port": 2222 },
  "retention": { "daily": 14 },
  "compress": true,
  "exclude": ["*.tmp", ".cache"]
}
```

Only `name`, `sources` and `target.host` are required; `target.port` defaults to 22,
`retention` to 7 daily and 4 weekly copies, `compress` to `false`, `exclude` to nothing.

## Step 1: the `Json` enum

`json.parse` returns `Json!`, a value of this enum or an error:

```swift
pub enum Json {
  case null
  case bool(Bool)
  case num(Float)
  case str(String)
  case arr([Json])
  case obj(Map<String, Json>)
}
```

Everything else is pattern matching:

<!-- include: json-config/explore.rl -->
```swift
// Step 1: parse a JSON file and look at its top level.
import "std/os"
import "std/fs"
import "std/json"

// The kind of a JSON value: a function made of cases over the Json enum.
fn kind(_ j: json.Json) -> String {
case .null: return "null"
case .bool(b): return "bool $b"
case .num(n): return "number $n"
case .str(s): return "string \"$s\""
case .arr(xs): return "array of ${xs.len()}"
case .obj(fields): return "object with ${fields.len()} keys"
}

fn main() -> Void! {
  let doc = json.parse(fs.readFile(os.args()[0])?)?
  guard case .obj(fields) = doc else {
    return fail("expected an object, got ${kind(doc)}")
  }
  for key, value in fields {
    print("$key: ${kind(value)}")
  }
  // std/json's accessors return optionals: chain them with ??
  print("port: ${json.int(json.at(doc, "target.port")) ?? 22}")
}
```

- `kind` is a **function made of cases**: its body starts with `case`, so it matches its
  parameter. The compiler checks that all six cases are covered.
- The enum is `json.Json` outside its module. Inside a pattern the type is known, so
  `.obj(fields)` needs no prefix.
- `guard case .obj(fields) = doc else { … }` refuses anything but an object and keeps
  `fields` in scope after the guard.
- `for key, value in fields` walks the map. Objects keep their keys in file order.
- `json.at(doc, "target.port")` follows a path and returns `Json?`; `json.int` turns that
  into `Int?` (nil for anything but a whole number). There is no optional chaining, so
  accessors take optionals and the chain ends with `?? default`.

<!-- include: json-config/sessions/explore.txt -->
```text
$ rill run explore.rl backup.json
name: string "nightly"
sources: array of 2
target: object with 2 keys
retention: object with 1 keys
compress: bool true
exclude: array of 2
port: 2222
$ rill run explore.rl broken.json
error: invalid JSON at byte 58
[exit 1]
```

A syntax error is an ordinary `Error` (the trailing comma in
[`broken.json`](json-config/broken.json)); the message gives the byte offset.

## Step 2: defaults and validation

<!-- include: json-config/cfg.rl -->
```swift
// cfg <file.json>: loads a backup configuration, fills in defaults, reports every
// problem at once, and prints the effective configuration.
import "std/os"
import "std/fs"
import "std/json"
import "std/slices"
import "std/strings"

struct Target { host: String, port: Int }

struct Config {
  name: String,
  sources: [String],
  target: Target,
  keepDaily: Int,
  keepWeekly: Int,
  compress: Bool,
  exclude: [String],
}

fn kind(_ j: json.Json) -> String {
case .null: return "null"
case .bool(_): return "a boolean"
case .num(_): return "a number"
case .str(_): return "a string"
case .arr(_): return "an array"
case .obj(_): return "an object"
}

// The fields of an object, or none (with a problem) for anything else.
fn object(_ j: json.Json?, _ at: String, _ problems: inout [String]) -> Map<String, json.Json> {
  switch j {
  case nil: return [:]
  case .obj(fields)?: return fields
  case other?:
    problems.push("$at: expected an object, got ${kind(other)}")
    return [:]
  }
}

fn text(_ o: Map<String, json.Json>, _ at: String, _ key: String, def: String?, _ problems: inout [String]) -> String {
  switch o[key] {
  case .str(s)?:
    if s == "" {
      problems.push("$at$key: must not be empty")
    }
    return s
  case nil:
    if def == nil {
      problems.push("$at$key: missing")
    }
    return def ?? ""
  case other?:
    problems.push("$at$key: expected a string, got ${kind(other)}")
    return ""
  }
}

fn int(_ o: Map<String, json.Json>, _ at: String, _ key: String, def: Int, low: Int, high: Int, _ problems: inout [String]) -> Int {
  guard let j = o[key] else {
    return def
  }
  guard let n = json.int(j) else {
    problems.push("$at$key: expected a whole number, got ${json.stringify(j)}")
    return def
  }
  if n < low || n > high {
    problems.push("$at$key: must be in $low...$high, got $n")
  }
  return n
}

fn flag(_ o: Map<String, json.Json>, _ key: String, def: Bool, _ problems: inout [String]) -> Bool {
  switch o[key] {
  case nil: return def
  case .bool(b)?: return b
  case other?:
    problems.push("$key: expected true or false, got ${kind(other)}")
    return def
  }
}

fn texts(_ o: Map<String, json.Json>, _ key: String, required: Bool, _ problems: inout [String]) -> [String] {
  var out: [String] = []
  guard let j = o[key] else {
    if required {
      problems.push("$key: missing")
    }
    return out
  }
  guard case .arr(items) = j else {
    problems.push("$key: expected an array of strings, got ${kind(j)}")
    return out
  }
  for i in 0..<items.len() {
    switch items[i] {
    case .str(s): out.push(s)
    case other: problems.push("$key[$i]: expected a string, got ${kind(other)}")
    }
  }
  if required && items.len() == 0 {
    problems.push("$key: must not be empty")
  }
  return out
}

fn unknownKeys(_ o: Map<String, json.Json>, _ at: String, _ known: [String], _ problems: inout [String]) {
  for key, _ in o {
    if !slices.contains(known, key) {
      problems.push("$at$key: unknown key (known: ${strings.join(known, ", ")})")
    }
  }
}

// The configuration in `doc`, or one error listing every problem.
fn load(_ doc: json.Json) -> Config! {
  var problems: [String] = []
  let root = object(doc, "config", &problems)
  unknownKeys(root, "", ["name", "sources", "target", "retention", "compress", "exclude"], &problems)
  let target = object(root["target"], "target", &problems)
  if !root.has("target") {
    problems.push("target: missing")
  }
  unknownKeys(target, "target.", ["host", "port"], &problems)
  let retention = object(root["retention"], "retention", &problems)
  unknownKeys(retention, "retention.", ["daily", "weekly"], &problems)
  let c = Config(
    name: text(root, "", "name", def: nil, &problems),
    sources: texts(root, "sources", required: true, &problems),
    target: Target(
      host: text(target, "target.", "host", def: nil, &problems),
      port: int(target, "target.", "port", def: 22, low: 1, high: 65535, &problems),
    ),
    keepDaily: int(retention, "retention.", "daily", def: 7, low: 1, high: 365, &problems),
    keepWeekly: int(retention, "retention.", "weekly", def: 4, low: 0, high: 52, &problems),
    compress: flag(root, "compress", def: false, &problems),
    exclude: texts(root, "exclude", required: false, &problems),
  )
  if problems.len() > 0 {
    return fail(strings.join(problems, "\n"))
  }
  return c
}

fn strs(_ xs: [String]) -> json.Json = .arr(xs.map { json.Json.str($) })

// The effective configuration as JSON: every default spelled out.
fn toJson(_ c: Config) -> json.Json {
  let target = json.object(["host", "port"], [.str(c.target.host), .num(Float(c.target.port))])
  let retention = json.object(["daily", "weekly"], [.num(Float(c.keepDaily)), .num(Float(c.keepWeekly))])
  return json.object(
    ["name", "sources", "target", "retention", "compress", "exclude"],
    [.str(c.name), strs(c.sources), target, retention, .bool(c.compress), strs(c.exclude)],
  )
}

fn main() -> Void! {
  let args = os.args()
  if args.len() != 1 {
    return fail("usage: cfg <file.json>")
  }
  let file = args[0]
  let doc = json.parse(fs.readFile(file)?)?
  switch load(doc) {
  case .ok(c): print(json.pretty(toJson(c)))
  case .err(e):
    eprint("$file: invalid configuration:")
    for line in e.msg.lines() {
      eprint("  $line")
    }
    os.exit(1)
  }
}

fn problemsIn(_ text: String) -> String {
  switch load(json.parse(text) ?? .null) {
  case .ok(_): return ""
  case .err(e): return e.msg
  }
}

test "defaults" {
  let c = load(json.parse("{\"name\": \"n\", \"sources\": [\"/a\"], \"target\": {\"host\": \"h\"}}") ?? .null)
  if case .ok(conf) = c {
    expect(conf.target.port == 22 && conf.keepDaily == 7 && !conf.compress)
  } else {
    expect(false)
  }
}

test "problems" {
  expect(problemsIn("[]") == "config: expected an object, got an array\ntarget: missing\nname: missing\nsources: missing\ntarget.host: missing")
  expect(strings.contains(problemsIn("{\"target\": {\"host\": \"h\", \"port\": 0}}"), "target.port: must be in 1...65535, got 0"))
}
```

The pieces:

- **One problem list, passed `inout`.** Every reader takes `_ problems: inout [String]`,
  and the call sites pass `&problems`. Each reader returns a usable value even on error
  (the default, or `""`), so loading carries on and finds the next problem too. At the end
  `load` either returns the `Config` or one `fail(…)` with all problems, one per line.
  Errors are messages in Rill (`Error` has only `msg`), so a multi-line message is the
  simple way to carry a list.
- **Patterns on optionals.** `o[key]` on a map is `Json?`. `case nil:` is the missing
  key, `case .str(s)?:` a present string, `case other?:` anything else, which the message
  then names with `kind(other)`. The `switch` is exhaustive without a `default`.
- **Unknown keys** catch typos such as `compres`: every key of an object must be in its
  list of known keys (`slices.contains`).
- **Building JSON.** `json.object(keys, values)` builds an object with the keys in that
  order, `.num(Float(n))` a number (JSON numbers are `Float`s; whole numbers print without
  a fraction), and `xs.map { json.Json.str($) }` an array. `json.pretty` indents by two
  spaces, `json.stringify` writes compact JSON.
- **Tests** call `load` on JSON text directly. `?` is not allowed in test blocks, so
  `json.parse(…) ?? .null` stands in, and `if case .ok(conf) = …` looks inside the result.

<!-- include: json-config/sessions/test.txt -->
```text
$ rill test cfg.rl
ok   defaults
ok   problems
2 passed, 0 failed
```

The minimal configuration, with every default spelled out:

<!-- include: json-config/sessions/good.txt -->
```text
$ rill build cfg.rl
$ ./cfg minimal.json
{
  "name": "quick",
  "sources": [
    "/srv"
  ],
  "target": {
    "host": "nas.local",
    "port": 22
  },
  "retention": {
    "daily": 7,
    "weekly": 4
  },
  "compress": false,
  "exclude": []
}
```

And a file with many mistakes:

<!-- include: json-config/bad.json -->
```json
{
  "name": "",
  "sources": ["/home/ada", 42],
  "target": { "port": 70000 },
  "retention": { "daily": 2.5, "weekly": -1 },
  "compres": true
}
```

<!-- include: json-config/sessions/bad.txt -->
```text
$ ./cfg bad.json
bad.json: invalid configuration:
  compres: unknown key (known: name, sources, target, retention, compress, exclude)
  name: must not be empty
  sources[1]: expected a string, got a number
  target.host: missing
  target.port: must be in 1...65535, got 70000
  retention.daily: expected a whole number, got 2.5
  retention.weekly: must be in 0...52, got -1
[exit 1]
```

## Exercises

- Expand a leading `~/` in `sources` with `os.env("HOME")`.
- Turn the byte offset of a syntax error into a line and column (count `'\n'` bytes
  before it).
- Suggest the closest known key for an unknown one (edit distance).

Next: [4. Packages](04-packages.md).
