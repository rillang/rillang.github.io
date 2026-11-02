#!/bin/sh
# Checks every tutorial: replays its shell steps in a scratch copy and compares what they
# print with the transcripts the pages show, then checks formatting, language server
# diagnostics and that the pages are in sync with the files.
#
#   <tutorial>/*.rl                 programs (and modules) of the tutorial
#   <tutorial>/sessions/*.txt       recorded transcripts: "$ command", its output, and
#                                   "[exit N]" when it fails
#   *.warn.rl, *.fmt.rl             deliberately unclean inputs (skipped by fmt/lsp checks)
#
# Commands run with `rill` on PATH (../rill/out/rill, or $RILL), in a copy of the tutorial directory,
# with HOME pointing into the scratch directory: nothing outside it is touched.
#
# Usage: sh tutorials/check.sh            (RILL=... for another compiler)
#        UPDATE=1 sh tutorials/check.sh   rewrite the transcripts (review the diff!)
cd "$(dirname "$0")/.." || exit 1
repo=$(pwd)
T="$repo/tutorials"
RILL=${RILL:-../rill/out/rill} # the compiler: a checkout of rillang/rill next to this one
case "$RILL" in /*) ;; *) RILL="$repo/$RILL" ;; esac
tmp=$(mktemp -d "${TMPDIR:-/tmp}/rill-tutorials.XXXXXX")
tmp=$(cd "$tmp" && pwd -P)
mkdir -p "$tmp/bin" "$tmp/home"
ln -s "$RILL" "$tmp/bin/rill"
export PATH="$tmp/bin:$PATH" HOME="$tmp/home"
# git: no user configuration leaks in, stable commits
export GIT_CONFIG_NOSYSTEM=1
export GIT_AUTHOR_NAME="Ada" GIT_AUTHOR_EMAIL="ada@example.com"
export GIT_COMMITTER_NAME="Ada" GIT_COMMITTER_EMAIL="ada@example.com"
export GIT_AUTHOR_DATE="2026-11-02T12:00:00Z" GIT_COMMITTER_DATE="2026-11-02T12:00:00Z"
pass=0
fail=0
cur=""

bad() {
  echo "FAIL $1"
  fail=$((fail + 1))
}

# session <tutorial>: a fresh copy of tutorials/<tutorial> becomes the current directory
session() {
  finish
  rm -rf "$tmp/work"
  mkdir -p "$tmp/work"
  cp -R "$T/$1" "$tmp/work/$1"
  rm -rf "$tmp/work/$1/sessions"
  cd "$tmp/work/$1" || exit 1
  name=$1
}

# expect <file>: the following x commands are recorded and compared with
# tutorials/<tutorial>/sessions/<file>.txt
expect() {
  finish
  cur="$name/sessions/$1.txt"
  : >"$tmp/transcript"
}

# finish: compares the transcript being recorded
finish() {
  [ -n "$cur" ] || return 0
  if [ -n "$UPDATE" ]; then
    mkdir -p "$(dirname "$T/$cur")"
    cp "$tmp/transcript" "$T/$cur"
  fi
  if [ ! -f "$T/$cur" ]; then
    bad "$cur (missing; run with UPDATE=1)"
  elif diff -u "$T/$cur" "$tmp/transcript" >"$tmp/diff"; then
    pass=$((pass + 1))
  else
    bad "$cur"
    sed 's/^/  /' "$tmp/diff" | head -30
  fi
  cur=""
}

# x '<command>': runs it with sh in the current directory and records it, its output
# (stdout and stderr) and a non-zero exit code. Scratch paths print as /work.
x() {
  printf '$ %s\n' "$1" >>"$tmp/transcript"
  sh -c "$1" >"$tmp/o" 2>&1
  code=$?
  sed -e "s#$HOME#~#g" -e "s#$tmp/work#/work#g" -e "s#$tmp#/scratch#g" "$tmp/o" >>"$tmp/transcript"
  [ "$code" = 0 ] || echo "[exit $code]" >>"$tmp/transcript"
}

# cdx <dir>: records "$ cd <dir>" and changes to it (~ is HOME)
cdx() {
  printf '$ cd %s\n' "$1" >>"$tmp/transcript"
  cd "$(echo "$1" | sed "s#^~#$HOME#")" || exit 1
}

# xenv NAME=value: records "$ export NAME=value" and exports it to later commands
xenv() {
  printf '$ export %s\n' "$1" >>"$tmp/transcript"
  export "${1?}"
}

# put <path under packages/> <destination>: what the reader creates in an editor (or
# copies); not recorded, the page shows the file
put() {
  mkdir -p "$(dirname "$2")"
  cp -R "$P/$1" "$2"
}

# xt '<command>': as x, with durations ("12ms", "1.5s") replaced by <time>
xt() {
  x "$1"
  sed -E 's/[0-9]+(\.[0-9]+)?(ns|µs|ms|s)([^a-z]|$)/<time>\3/g' "$tmp/transcript" >"$tmp/t2"
  mv "$tmp/t2" "$tmp/transcript"
}

# ---------------------------------------------------------------- 1. a command-line tool
session cli-tool
expect step1
x 'rill run wc1.rl testdata/fox.txt'
x 'rill run wc1.rl'
x 'rill run wc1.rl missing.txt'
expect step2
x 'rill test wc2.rl'
x 'rill run wc2.rl testdata/fox.txt testdata/rill.txt'
expect broken
x 'sed "s/c.words += 1/c.words += 2/" wc2.rl >broken.rl'
x 'rill test broken.rl'
expect test
x 'rill test wc.rl'
expect build
x 'rill build wc.rl'
x './wc testdata/fox.txt testdata/rill.txt'
x './wc -l testdata/fox.txt missing.txt'
x 'printf "one two\nthree\n" | ./wc -w'
x './wc -q'
expect warnings
x 'rill build warnings.warn.rl -o warnings'
x 'rill build --deny-warnings warnings.warn.rl -o warnings'
expect fmt
x 'rill fmt --check messy.fmt.rl'
x 'rill fmt --stdout messy.fmt.rl'

# ---------------------------------------------------------------- 2. concurrency
session concurrency
expect step1
xt 'rill run hash1.rl testdata'
expect gen
x 'rill run gen.rl tree 400'
x 'rill build hash1.rl && rill build hash2.rl && rill build hashtree.rl'
x './hash1 tree 2>/dev/null | tail -2'
x './hash1 tree 2>/dev/null | cksum'
x './hash2 tree 2>/dev/null | cksum'
x './hashtree tree 2>/dev/null | cksum'
expect timing
xt './hash1 tree >/dev/null'
xt './hash2 tree >/dev/null'
xt './hashtree -j 1 tree >/dev/null'
xt './hashtree -j 4 tree >/dev/null'
expect failure
x 'chmod 000 testdata/hello.txt'
xt './hashtree testdata'
x 'chmod 644 testdata/hello.txt'
expect capture
x 'sed "s/0..<n {/0..<workers {/" hashtree.rl >capture.rl'
x 'rill build capture.rl'

# ---------------------------------------------------------------- 3. a JSON configuration
session json-config
expect explore
x 'rill run explore.rl backup.json'
x 'rill run explore.rl broken.json'
expect test
x 'rill test cfg.rl'
expect good
x 'rill build cfg.rl'
x './cfg minimal.json'
expect bad
x './cfg bad.json'

# ---------------------------------------------------------------- 4. packages
# Everything happens below the scratch HOME (printed as ~): two projects in ~/src, a bare
# repository in ~/remote standing in for GitHub.
session packages
P="$T/packages"
expect setup
xenv RILL_MOD_TEST=1
x 'git config --global url."file://$HOME/remote/".insteadOf "https://github.com/ada/"'
x 'git config --global init.defaultBranch main'
x 'git config --global user.name Ada && git config --global user.email ada@example.com'
expect lib
put textkit ~/src/textkit
cdx '~/src/textkit'
x 'rill mod init github.com/ada/textkit'
x 'cat rill.mod'
x 'rill test . && rill test wrap && rill test internal/ascii'
x 'rill api'
expect release1
x 'git init -q && git add -A && git commit -qm "textkit 1.0"'
x 'rill release --dry-run'
x 'rill release v1.0.0 --unsigned'
x 'git init -q --bare ~/remote/textkit && git -C ~/remote/textkit config uploadpack.allowFilter true'
x 'git remote add origin ~/remote/textkit && git push -q origin main v1.0.0'
expect app
put greeter ~/src/greeter
cdx '~/src/greeter'
x 'rill mod init github.com/ada/greeter'
x 'rill run .'
x 'rill get github.com/ada/textkit'
x 'cat rill.mod'
x 'cat rill.sum'
x 'rill run .'
x 'rill lsp --check main.rl'
x 'ls ~/.rill/mod/github.com/ada'
expect internal
put snippets/peek.rl ~/src/greeter/peek.rl
x 'rill run peek.rl'
x 'rm peek.rl'
expect release2
cdx '~/src/textkit'
put v1.1/textkit.rl ~/src/textkit/textkit.rl
x 'rill lsp --check textkit.rl && rill test .'
x 'rill api diff v1.0.0 .'
x 'git commit -qam "slugify; slug deprecated" && rill release --dry-run'
put v1.1/CHANGELOG.md ~/src/textkit/CHANGELOG.md
x 'git commit -qam "changelog for 1.1.0" && rill release --dry-run'
x 'rill release --unsigned'
x 'git push -q origin main v1.1.0'
expect upgrade
cdx '~/src/greeter'
x 'rill get github.com/ada/textkit'
x 'rill run .'
x 'rill build --deny-warnings . -o greeter'
x 'rill fix --list'
x 'rill fix'
x 'cat main.rl'
x 'rill build --deny-warnings . -o greeter && ./greeter'
x 'rill mod tidy && rill mod verify'
finish

# ---------------------------------------------------------------- source checks
cd "$repo" || exit 1
srcs=$(find tutorials -name '*.rl' ! -name '*.warn.rl' ! -name '*.fmt.rl' | sort)
# the packages tutorial's app and v1.1 files resolve imports only in their session (above)
lspsrcs=$(echo "$srcs" | grep -v -e '/packages/greeter/' -e '/packages/snippets/' -e '/packages/v1.1/')
if "$RILL" fmt --check $srcs >"$tmp/out" 2>&1; then pass=$((pass + 1)); else
  bad "formatting (run rill fmt on these):"
  sed 's/^/  /' "$tmp/out"
fi
if "$RILL" lsp --check $lspsrcs >"$tmp/out" 2>&1; then pass=$((pass + 1)); else
  bad "language server diagnostics:"
  sed 's/^/  /' "$tmp/out"
fi
if sh tutorials/sync.sh --check >"$tmp/out" 2>&1; then pass=$((pass + 1)); else
  bad "pages out of date (run sh tutorials/sync.sh):"
  sed 's/^/  /' "$tmp/out"
fi

chmod -R u+w "$tmp" 2>/dev/null
rm -rf "$tmp"
echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ]
