import "std/strings"
import "std/fmt"
import "std/slices"
import "std/path"
import "std/json"
import "std/math"
import "std/time"

fn main() -> Void! {
  print(strings.replace("a-b-c", "-", " + "))
  print(fmt.pad("left", width: 8, align: .left) + "|" + fmt.pad("right", width: 8, align: .right))
  print(fmt.float(math.pi, prec: 3))
  print(strings.join(slices.sort(["pear", "apple", "fig"]), ", "))
  print(path.join("src/lib", "../main.rl"))
  let doc = json.parse("{\"name\": \"rill\", \"tags\": [\"fast\"]}")?
  print(json.str(json.get(doc, "name")) ?? "?")
  print(json.pretty(doc))
  print(time.text(time.milliseconds(1500)))
}
