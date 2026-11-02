// try: rill run args.rl one two
fn main() {
  let a = args()
  if a.len() == 0 {
    eprint("usage: args <words...>")
    print("no arguments")
    return
  }
  print("${a.len()} arguments: ${a.join(", ")}")
}
