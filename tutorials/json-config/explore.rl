// Step 1: parse a JSON file and look at its top level.
import "std/os"
import "std/fs"
import "std/json"

// The kind of a JSON value: a switch over the Json enum as the function body.
fn kind(_ j: json.Json) -> String = switch j {
  case .null: "null"
  case .bool(b): "bool $b"
  case .num(n): "number $n"
  case .str(s): "string \"$s\""
  case .arr(xs): "array of ${xs.len()}"
  case .obj(fields): "object with ${fields.len()} keys"
}

fn main() -> Void! {
  let doc = json.parse(fs.readFile(os.args()[0])?)?
  let fields = switch doc {
    case .obj(f): f
    default: return fail("expected an object, got ${kind(doc)}")
  }
  for key, value in fields {
    print("$key: ${kind(value)}")
  }
  // std/json's accessors return optionals: chain them with ??
  print("port: ${json.int(json.at(doc, "target.port")) ?? 22}")
}
