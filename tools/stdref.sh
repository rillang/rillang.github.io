#!/bin/sh
# Generates the std reference: one Markdown page per std module, from `rill doc --json`.
#
# Usage: sh tools/stdref.sh <version>   write std/<version>/ (README.md index, search.json,
#                                       one page per module; not committed, see README.md)
#        sh tools/stdref.sh --check     generate std/strings and compare it with
#                                       tools/stdref/testdata/strings.md (CI runs this)
#        UPDATE=1 sh tools/stdref.sh --check   rewrite the snapshot (review the diff!)
#
# RILL=... names the compiler (default ../rill/out/rill); RILL_SRC=... the checkout whose std/
# is documented (default ../rill, or the compiler's own checkout when RILL is set).
cd "$(dirname "$0")/.." || exit 1
export RILL_AGENT=0
RILL=${RILL:-../rill/out/rill}
case "$RILL" in */*) RILL="$(cd "$(dirname "$RILL")" && pwd)/$(basename "$RILL")" ;; esac
src=${RILL_SRC:-$(dirname "$(dirname "$RILL")")}
[ -d "$src/std" ] || src=../rill
src=$(cd "$src" && pwd) || exit 1
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
root=$(pwd)

if [ "$1" = --check ]; then
  mods=std/strings
  out=$tmp/out
elif [ -n "$1" ]; then
  # every directory of std/ with a non-test .rl file
  mods=$(cd "$src" && find std -name '*.rl' ! -name '*_test.rl' -exec dirname {} \; | sort -u)
  out=std/$1
else
  sed -n '2,11p' "$0" | sed 's/^# \{0,1\}//'
  exit 2
fi

files=
for m in $mods; do
  f=$tmp/$(echo "$m" | tr / _).json
  (cd "$src" && "$RILL" doc --json "$m") >"$f" || { echo "rill doc --json $m failed"; exit 1; }
  files="$files $f"
done
"$RILL" build tools/stdref -o "$tmp/stdref" || exit 1
rm -rf "$out"
"$tmp/stdref" "$out" "${1#--}" $files || exit 1

if [ "$1" = --check ]; then
  snap=tools/stdref/testdata/strings.md
  [ -n "$UPDATE" ] && cp "$out/strings.md" "$snap"
  if ! diff -u "$snap" "$out/strings.md"; then
    echo "$snap is out of date: UPDATE=1 sh tools/stdref.sh --check (review the diff)"
    exit 1
  fi
  echo "stdref snapshot ok"
else
  echo "wrote $(echo "$mods" | wc -w | tr -d ' ') modules to $root/$out"
fi
