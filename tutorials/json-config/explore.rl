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
