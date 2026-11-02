import "github.com/ada/textkit"
import "github.com/ada/textkit/wrap"

fn main() {
  let title = "Packages in Rill: A Hands-On Tour"
  print("/posts/${textkit.slug(title)} (${textkit.words(title)} words)")
  for line in wrap.lines(title, width: 16) {
    print("  $line")
  }
}
