//! stdref: the std reference pages of the website, one Markdown page per std module.
//!
//!     stdref <dir> <version> <module.json>...
//!
//! Each file is the output of `rill doc --json std/<module>`. Writes <dir>/<module below
//! std>.md, <dir>/README.md (the index of the version) and <dir>/search.json. Normally run
//! through `sh tools/stdref.sh <version>`.

import "std/fs"
import "std/os"
import "std/path"
import "std/slices"

fn write(_ dir: String, _ name: String, _ content: String) -> Void! {
  let file = path.join(dir, name)
  fs.mkdirAll(path.dir(file))?
  fs.writeFile(file, content)?
}

fn generate(_ args: [String]) -> Void! {
  var rest = args
  if rest.len() > 0 && rest[0] == "--" {
    rest = rest.slice(1, rest.len())
  }
  if rest.len() < 3 {
    return fail("usage: stdref <dir> <version> <module.json>...")
  }
  var mods: [Module] = []
  for f in rest.slice(2, rest.len()) {
    mods.push(parseModule(fs.readFile(f)?)?)
  }
  mods = slices.sortBy(mods) { a, b in a.path < b.path }
  for m in mods {
    write(rest[0], pagePath(m.path) + ".md", modulePage(m))?
  }
  write(rest[0], "README.md", indexPage(rest[1], mods))?
  write(rest[0], "search.json", searchJson(mods))?
}

fn main() -> Void! {
  generate(os.args())?
}
