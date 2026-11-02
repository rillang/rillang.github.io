fn csvRow(_ cells: [Int]) -> String {
  var sb = StringBuilder()
  for i in 0..<cells.len() {
    if i > 0 {
      sb.addByte(',')
    }
    sb.addInt(cells[i])
  }
  return sb.build()
}

fn main() {
  print(csvRow([1, 22, 333]))
  var sb = StringBuilder()
  for i in 0..<1000 {
    sb.add("line $i\n")
  }
  print("${sb.len()} bytes")
}
