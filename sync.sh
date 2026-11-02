#!/bin/sh
# Copies source files and recorded transcripts into the tutorial pages, so pages never
# drift from what check.sh runs. A page marks a copied block with an include comment; the
# fenced block right after it is replaced (path relative to docs/tutorials/):
#
#   <!-- include: cli-tool/wc.rl -->
#   ```swift
#   …
#   ```
#
# Usage: sh docs/tutorials/sync.sh            rewrite the pages
#        sh docs/tutorials/sync.sh --check    only report pages that are out of date
cd "$(dirname "$0")" || exit 1
status=0
check=0
[ "$1" = "--check" ] && check=1
tmp=$(mktemp -d)

for page in *.md; do
  awk '
    function emit(path,   line, r) {
      while ((r = (getline line < path)) > 0) print line
      if (r < 0) {
        print "sync.sh: cannot read " path > "/dev/stderr"
        exit 2
      }
      close(path)
    }
    state == "" {
      print
      if (match($0, /<!-- include: [^ ]+ -->/)) {
        path = $0
        sub(/.*<!-- include: /, "", path)
        sub(/ -->.*/, "", path)
        state = "open"
      }
      next
    }
    state == "open" {
      print
      if ($0 ~ /^```/) {
        emit(path)
        state = "skip"
      }
      next
    }
    state == "skip" {
      if ($0 ~ /^```/) {
        print
        state = ""
      }
    }
  ' "$page" >"$tmp/page" || { status=1; continue; }
  if ! cmp -s "$page" "$tmp/page"; then
    if [ "$check" = 1 ]; then
      echo "docs/tutorials/$page"
      status=1
    else
      cp "$tmp/page" "$page"
      echo "updated docs/tutorials/$page"
    fi
  fi
done
rm -rf "$tmp"
exit $status
