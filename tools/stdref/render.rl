// The pages of the std reference, from the JSON of `rill doc --json`.
import "std/json"
import "std/strings"

/// A runnable example of a doc comment and the output it prints.
pub struct Example { label: String, body: String, output: String }

/// A declaration of a module: its signature, doc comment and examples.
pub struct Item {
  kind: String,
  name: String,
  signature: String,
  doc: String,
  examples: [Example],
  links: [Link],
}

/// A std module as `rill doc --json` describes it.
pub struct Module {
  path: String,
  overview: String,
  examples: [Example],
  links: [Link],
  items: [Item],
}

fn field(_ j: json.Json, _ key: String) -> String = json.str(json.get(j, key)) ?? ""

fn parseExamples(_ j: json.Json) -> [Example] {
  var out: [Example] = []
  for e in json.items(json.get(j, "examples")) {
    out.push(Example(label: field(e, "label"), body: field(e, "body"), output: field(e, "output")))
  }
  return out
}

/// The `links` array; a compiler that does not emit it has none.
fn parseLinks(_ j: json.Json) -> [Link] {
  var out: [Link] = []
  for l in json.items(json.get(j, "links")) {
    out.push(Link(text: field(l, "text"), module: field(l, "module"), item: field(l, "item")))
  }
  return out
}

/// The module `rill doc --json` printed in `s`.
pub fn parseModule(_ s: String) -> Module! {
  let j = json.parse(s)?
  let path = field(j, "module")
  if path == "" {
    return fail("no module in the JSON")
  }
  var items: [Item] = []
  for i in json.items(json.get(j, "items")) {
    items.push(Item(kind: field(i, "kind"), name: field(i, "name"), signature: field(i, "signature"), doc: field(i, "doc"), examples: parseExamples(i), links: parseLinks(i)))
  }
  return Module(path: path, overview: field(j, "overview"), examples: parseExamples(j), links: parseLinks(j), items: items)
}

fn renderExamples(_ sb: inout StringBuilder, _ examples: [Example]) {
  for e in examples {
    if e.label != "" {
      sb.add("*${e.label}*\n\n")
    }
    sb.add("```swift\n${e.body}\n```\n\n")
    if e.output != "" {
      sb.add("*Output*\n\n```text\n${e.output}\n```\n\n")
    }
  }
}

/// The page of a module: overview, examples, then every item with an anchor of its name
/// (a method of a type: `Type.method`).
pub fn modulePage(_ m: Module) -> String {
  let page = pagePath(m.path)
  var sb = StringBuilder()
  sb.add("# ${m.path}\n\n")
  if m.overview != "" {
    sb.add(rewriteLinks(m.overview, m.links, page) + "\n\n")
  }
  renderExamples(&sb, m.examples)
  for it in m.items {
    sb.add("<a id=\"${it.name}\"></a>\n\n## ${it.kind} ${it.name}\n\n")
    sb.add("```swift\n${it.signature}\n```\n\n")
    if it.doc != "" {
      sb.add(rewriteLinks(it.doc, it.links, page) + "\n\n")
    }
    renderExamples(&sb, it.examples)
  }
  return sb.build()
}

/// The first sentence of an overview, on one line, brackets of doc links removed.
pub fn firstSentence(_ overview: String) -> String {
  var para = strings.split(overview, "\n\n")[0]
  para = strings.replace(para, "\n", " ")
  if let i = strings.index(para, ". ") {
    para = para.slice(0, i + 1)
  }
  return rewriteLinks(strings.trim(para), [], "")
}

/// The index page of a version: the modules with their first sentence, a search box.
pub fn indexPage(_ version: String, _ mods: [Module]) -> String {
  var sb = StringBuilder()
  sb.add("# Rill standard library $version\n\n")
  sb.add("<input id=\"stdref-q\" type=\"search\" placeholder=\"Search modules and items\" autocomplete=\"off\">\n")
  sb.add("<ul id=\"stdref-hits\"></ul>\n\n")
  sb.add(searchScript)
  sb.add("\n")
  for m in mods {
    sb.add("- [${m.path}](${pagePath(m.path)}.md): ${firstSentence(m.overview)}\n")
  }
  return sb.build()
}

/// The search box: filters search.json (fetched on the first keystroke).
let searchScript = strings.join([
  "<script>",
  "(function () {",
  "  var q = document.getElementById('stdref-q'), hits = document.getElementById('stdref-hits'), all = null;",
  "  function show() {",
  "    var s = q.value.trim().toLowerCase();",
  "    hits.textContent = '';",
  "    if (!s || !all) return;",
  "    all.filter(function (e) { return e.n.toLowerCase().indexOf(s) >= 0; }).slice(0, 40).forEach(function (e) {",
  "      var li = document.createElement('li'), a = document.createElement('a');",
  "      a.href = e.u; a.textContent = e.n;",
  "      li.appendChild(a); li.appendChild(document.createTextNode(' ' + e.k));",
  "      hits.appendChild(li);",
  "    });",
  "  }",
  "  q.addEventListener('input', function () {",
  "    if (all) return show();",
  "    fetch('search.json').then(function (r) { return r.json(); }).then(function (d) { all = d; show(); });",
  "  });",
  "})();",
  "</script>",
  ], "\n")

fn entry(_ name: String, _ kind: String, _ url: String) -> json.Json {
  return json.object(["n", "k", "u"], [json.Json.str(name), json.Json.str(kind), json.Json.str(url)])
}

/// search.json: every module and item with the page (as served: `.html`) and anchor.
pub fn searchJson(_ mods: [Module]) -> String {
  var all: [json.Json] = []
  for m in mods {
    let url = pagePath(m.path) + ".html"
    all.push(entry(m.path, "module", url))
    for it in m.items {
      all.push(entry("${m.path}.${it.name}", it.kind, url + "#" + it.name))
    }
  }
  return json.stringify(json.Json.arr(all)) + "\n"
}
