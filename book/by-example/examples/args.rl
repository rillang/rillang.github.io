// try: rill run args.rl one two

import "std/os"

fn main() {
  let a = os.args()
  if a.len() == 0 {
    eprint("usage: args <words...>")
    print("no arguments")
    return
  }
  print("${a.len()} arguments: ${a.join(", ")}")
}
