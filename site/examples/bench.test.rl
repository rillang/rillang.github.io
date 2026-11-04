import "std/strings"

fn words(_ s: String) -> Int = s.split(" ").len()

bench "split a sentence" {
  let s = strings.repeat("the cat saw the dog ", 100)
  while loop() {
    let _ = words(s)
  }
}
