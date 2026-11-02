#!/bin/sh
# Copies example sources and outputs into the pages that show them, so pages never drift
# from the files check.sh runs. A page marks a copied block with an include comment; the
# block right after it is replaced (path relative to the page):
#
#   Markdown:                          HTML:
#   <!-- include: examples/x.rl -->    <!-- include: ../docs/book/examples/x.rl -->
#   ```swift                           <pre><code class="rill">…
#   …                                  …</code></pre>
#   ```
#
# In HTML the content starts on the <pre> line and ends with </code></pre>; it is escaped.
# Usage: sh docs/book/sync.sh            rewrite the pages
#        sh docs/book/sync.sh --check    only report pages that are out of date
cd "$(dirname "$0")/../.." || exit 1
status=0
tmp=$(mktemp -d)

sync_page() {
  page="$1"
  dir=$(dirname "$page")
  awk -v dir="$dir" -v html="$2" '
    function esc(s) {
      gsub(/&/, "\\&amp;", s); gsub(/</, "\\&lt;", s); gsub(/>/, "\\&gt;", s)
      return s
    }
    function emit(path,   line, n, r) {
      n = 0
      while ((r = (getline line < path)) > 0) {
        if (html) {
          line = esc(line)
          if (n == 0) { printf "%s", line } else { printf "\n%s", line }
        } else {
          print line
        }
        n++
      }
      if (r < 0) {
        print "sync.sh: cannot read " path > "/dev/stderr"
        exit 2
      }
      close(path)
    }
    {
      if (state == "") {
        print
        if (match($0, /<!-- include: [^ ]+ -->/)) {
          path = $0
          sub(/.*<!-- include: /, "", path)
          sub(/ -->.*/, "", path)
          path = dir "/" path
          state = "open"
        }
        next
      }
      if (state == "open") {
        if (html) {
          # opening tag line: keep everything up to and including <code ...>
          if (match($0, /<pre[^>]*><code[^>]*>/)) {
            printf "%s", substr($0, 1, RSTART + RLENGTH - 1)
            emit(path)
            print "</code></pre>"
            state = ($0 ~ /<\/code><\/pre>/) ? "" : "skip"
          } else {
            print
          }
        } else {
          print
          if ($0 ~ /^```/) {
            emit(path)
            state = "skip"
          }
        }
        next
      }
      if (state == "skip") {
        if (html && $0 ~ /<\/code><\/pre>/) {
          state = ""
        } else if (!html && $0 ~ /^```/) {
          print
          state = ""
        }
        next
      }
    }
  ' "$page" >"$tmp/page" || { status=1; return; }
  if ! cmp -s "$page" "$tmp/page"; then
    if [ "$check" = 1 ]; then
      echo "$page"
      status=1
    else
      cp "$tmp/page" "$page"
      echo "updated $page"
    fi
  fi
}

check=0
[ "$1" = "--check" ] && check=1
for page in $(grep -rl '<!-- include: ' docs/book site 2>/dev/null | grep -E '\.(md|html)$'); do
  case "$page" in
    *.html) sync_page "$page" 1 ;;
    *) sync_page "$page" 0 ;;
  esac
done
rm -rf "$tmp"
exit $status
