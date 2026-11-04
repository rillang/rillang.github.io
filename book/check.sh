#!/bin/sh
# Checks every example of the book, Rill by Example and the website:
#   - runs it and compares the output with the expected file next to it
#   - rill fmt --check and rill lsp --check on every source
#   - the code blocks copied into pages are up to date (sync.sh --check)
#
# File conventions (as in tests/, AGENTS.md):
#   name.rl       + name.out   run, exit 0, stdout
#   name.test.rl  + name.out   rill test, stdout (failing tests are allowed: they are examples)
#   name.panic.rl + name.err   run, exit 101, stderr
#   name.fail.rl  + name.err   run, exit 1, stderr
#   name.err.rl   + name.err   build, exit 1, stderr (a compile error)
#   lib/*.rl                   modules imported by examples; their test blocks must pass
#   name.err.rl   + name.json  also build --json, stderr (site/examples only)
#
# The website's examples run from a copy under their plain name (shapes.rl, not
# site/examples/shapes.err.rl), so the output on the landing page reads as a session.
#
# Usage: sh book/check.sh            (RILL=... for another compiler, default ../rill/out/rill)
#        UPDATE=1 sh book/check.sh   rewrite the expected files (review the diff!)
cd "$(dirname "$0")/.." || exit 1
RILL=${RILL:-../rill/out/rill} # the compiler: a checkout of rillang/rill next to this one
case "$RILL" in */*) RILL="$(cd "$(dirname "$RILL")" && pwd)/$(basename "$RILL")" ;; esac
tmp=$(mktemp -d)
pass=0
fail=0
dirs="book/examples book/by-example/examples site/examples"

ok() {
  pass=$((pass + 1))
}

bad() {
  echo "FAIL $1"
  fail=$((fail + 1))
}

# "run" builds into $tmp and runs that binary, so parallel checks never share one.
# $6: the directory to run in (default: the repository root).
check() {
  if [ "$2" = run ]; then
    if (cd "${6:-.}" && "$RILL" build "$1" -o "$tmp/bin") >"$tmp/out" 2>"$tmp/err"; then
      "$tmp/bin" >"$tmp/out" 2>"$tmp/err"
    fi
  else
    (cd "${6:-.}" && RILL_TEST_NOTIME=1 "$RILL" $2 "$1") >"$tmp/out" 2>"$tmp/err"
  fi
  code=$?
  if [ -n "$UPDATE" ]; then
    cp "$tmp/$4" "$5"
  fi
  if [ "$3" != any ] && [ "$code" != "$3" ]; then
    bad "$1 (exit $code, want $3)"
    sed 's/^/  | /' "$tmp/err" | head -10
  elif [ ! -f "$5" ]; then
    bad "$1 (missing $5)"
  elif diff -u "$5" "$tmp/$4" >"$tmp/diff"; then
    ok
  else
    bad "$1"
    sed 's/^/  /' "$tmp/diff" | head -20
  fi
}

for d in $dirs; do
  for f in "$d"/*.rl; do
    [ -e "$f" ] || continue
    base="${f%.rl}"
    src="$f"
    where=.
    if [ "$d" = site/examples ]; then
      name=$(basename "$f" .rl)
      mkdir -p "$tmp/site"
      cp "$f" "$tmp/site/${name%.*}.rl"
      src="${name%.*}.rl"
      where="$tmp/site"
    fi
    case "$f" in
      *.test.rl) check "$src" "test --count 1" any out "$base.out" "$where" ;;
      *.panic.rl) check "$src" run 101 err "$base.err" "$where" ;;
      *.fail.rl) check "$src" run 1 err "$base.err" "$where" ;;
      *.err.rl)
        check "$src" "build -o $tmp/bin" 1 err "${f%.err.rl}.err" "$where"
        if [ -f "${f%.err.rl}.json" ]; then
          check "$src" "build --json -o $tmp/bin" 1 err "${f%.err.rl}.json" "$where"
        fi
        ;;
      *) check "$src" run 0 out "$base.out" "$where" ;;
    esac
  done
  for f in "$d"/lib/*.rl; do
    [ -e "$f" ] || continue
    grep -q '^test "' "$f" || continue
    if "$RILL" test "$f" >"$tmp/out" 2>&1; then ok; else bad "$f (tests)"; fi
  done
done

srcs=$(ls book/examples/*.rl book/examples/lib/*.rl book/by-example/examples/*.rl \
  book/by-example/examples/lib/*.rl site/examples/*.rl 2>/dev/null)
if "$RILL" fmt --check $srcs >"$tmp/out" 2>&1; then ok; else
  bad "formatting (run rill fmt on these):"
  sed 's/^/  /' "$tmp/out"
fi
if "$RILL" lsp --check $(echo "$srcs" | grep -v '\.err\.rl$') >"$tmp/out" 2>&1; then ok; else
  bad "language server diagnostics:"
  sed 's/^/  /' "$tmp/out"
fi
if sh book/sync.sh --check >"$tmp/out" 2>&1; then ok; else
  bad "pages out of date (run sh book/sync.sh):"
  sed 's/^/  /' "$tmp/out"
fi

rm -rf "$tmp"
echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ]
