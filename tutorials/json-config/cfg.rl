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
