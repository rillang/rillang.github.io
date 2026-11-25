// Doc links: `[name]` in a doc comment becomes a Markdown link to the item's anchor.
import "std/strings"

/// One entry of the `links` array of `rill doc --json`: the text of a `[name]` and what it
/// names. A builtin has the module "".
pub struct Link { text: String, module: String, item: String }

/// The page of a module below `std/<version>/`, without `.md`: `std/encoding/hex` is `encoding/hex`.
pub fn pagePath(_ module: String) -> String = strings.trimPrefix(module, "std/")

/// The `.md` link from the page `from` to the page `to` (both as pagePath gives them).
pub fn relPath(_ from: String, _ to: String) -> String {
  let a = strings.split(from, "/")
  let b = strings.split(to, "/")
  var i = 0
  while i < a.len() - 1 && i < b.len() - 1 && a[i] == b[i] {
    i += 1
  }
  var parts: [String] = []
  for _ in i..<(a.len() - 1) {
    parts.push("..")
  }
  for k in i..<b.len() {
    parts.push(b[k])
  }
  return strings.join(parts, "/") + ".md"
}

/// The URL a link points to from the page `from`, nil for a builtin.
fn linkUrl(_ l: Link, _ from: String) -> String? {
  if l.module == "" {
    return nil
  }
  let page = pagePath(l.module)
  var url = relPath(from, page)
  if page == from {
    url = ""
  }
  if l.item != "" {
    url += "#" + l.item
  }
  return url
}

fn isNameByte(_ c: Int) -> Bool = (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_' || c == '.'

fn isLetter(_ c: Int) -> Bool = (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_'

/// How `[name]` reads: a link to its anchor, `name` in code for a builtin, plain `name` when
/// the compiler resolved nothing.
fn renderName(_ name: String, _ links: [Link], _ from: String) -> String {
  for l in links {
    if l.text != name {
      continue
    }
    if let url = linkUrl(l, from) {
      return "[$name]($url)"
    }
    return "`$name`"
  }
  return name
}

fn rewriteLine(_ line: String, _ links: [Link], _ from: String) -> String {
  var sb = StringBuilder()
  let n = line.len()
  var i = 0
  while i < n {
    let c = line.byteAt(i)
    if c == '`' {
      // inline code: copy up to the closing run of as many backticks
      var j = i
      while j < n && line.byteAt(j) == '`' {
        j += 1
      }
      let run = line.slice(i, j)
      var end = n
      if let k = strings.index(line.slice(j, n), run) {
        end = j + k + run.len()
      }
      sb.add(line.slice(i, end))
      i = end
      continue
    }
    if c == '[' && i + 1 < n && isLetter(line.byteAt(i + 1)) {
      var j = i + 1
      while j < n && isNameByte(line.byteAt(j)) {
        j += 1
      }
      // `[text](url)` is a Markdown link already
      if j < n && line.byteAt(j) == ']' && !(j + 1 < n && line.byteAt(j + 1) == '(') {
        sb.add(renderName(line.slice(i + 1, j), links, from))
        i = j + 1
        continue
      }
    }
    sb.addByte(c)
    i += 1
  }
  return sb.build()
}

/// `text` with every `[name]` rewritten, as seen from the page `from`. Code stays as it is:
/// fenced blocks, blocks indented by four spaces or a tab, and inline code.
pub fn rewriteLinks(_ text: String, _ links: [Link], _ from: String) -> String {
  var out: [String] = []
  var fence = false
  for line in strings.split(text, "\n") {
    if strings.hasPrefix(strings.trim(line), "```") {
      fence = !fence
      out.push(line)
    } else if fence || strings.hasPrefix(line, "    ") || strings.hasPrefix(line, "\t") {
      out.push(line)
    } else {
      out.push(rewriteLine(line, links, from))
    }
  }
  return strings.join(out, "\n")
}
