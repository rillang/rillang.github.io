# 4. Packages: a library and an app

We write a library module, `github.com/ada/textkit`, publish two versions of it from a Git
repository, and use it from an app, `github.com/ada/greeter`. On the way: `rill mod init`,
directory modules, `pub`, `internal/`, `rill get`, `rill.sum`, `rill mod tidy`, `rill api`,
`rill release` with a changelog, and retiring a function with `/// deprecated:` and
`rill fix`.

Files: [`packages/`](packages/) (copy commands below run from `docs/tutorials`). Everything else happens in your home directory: the two
projects in `~/src`, and a bare Git repository in `~/remote` that plays GitHub. To keep your
real `~` clean, run the tutorial with a throw-away one:

```sh
export HOME=$(mktemp -d)    # in a new shell; check.sh does the same
```

## Setup: GitHub on your disk

Rill fetches `github.com/ada/textkit` with Git from `https://github.com/ada/textkit`. Git's
`insteadOf` rewrites that URL to a local directory, so the tutorial needs no network and no
GitHub account:

<!-- include: packages/sessions/setup.txt -->
```text
$ export RILL_MOD_TEST=1
$ git config --global url."file://$HOME/remote/".insteadOf "https://github.com/ada/"
$ git config --global init.defaultBranch main
$ git config --global user.name Ada && git config --global user.email ada@example.com
```

`RILL_MOD_TEST=1` lets Rill accept the resulting `file://` URL. Normally Rill runs Git
with only the `https` and `ssh` protocols allowed (and without hooks or filters), so
**set this variable only for local experiments like this one**, never for real builds.

## The library

A module is a directory with a `rill.mod` file. Each directory in it is a package: all
`.rl` files of a directory form one namespace, and only `pub` declarations are visible to
importers. `textkit` has three:

```text
~/src/textkit/
  rill.mod                 written by rill mod init
  CHANGELOG.md
  textkit.rl               import "github.com/ada/textkit"
  wrap/wrap.rl             import "github.com/ada/textkit/wrap"
  internal/ascii/ascii.rl  only for code inside textkit
```

<!-- include: packages/textkit/textkit.rl -->
```swift
// textkit: small text helpers.
import "internal/ascii"

/// `s` as a URL slug: lower-case letters and digits, runs of anything else as one "-".
pub fn slug(_ s: String) -> String {
  var sb = StringBuilder()
  var gap = false
  for i in 0..<s.len() {
    let b = s.byteAt(i)
    if ascii.isLetter(b) || ascii.isDigit(b) {
      if gap && sb.len() > 0 {
        sb.add("-")
      }
      sb.addByte(ascii.lower(b))
      gap = false
    } else {
      gap = true
    }
  }
  return sb.build()
}

/// The number of words (runs of letters and digits) in `s`.
pub fn words(_ s: String) -> Int {
  var n = 0
  var inWord = false
  for i in 0..<s.len() {
    let b = s.byteAt(i)
    let w = ascii.isLetter(b) || ascii.isDigit(b)
    if w && !inWord {
      n += 1
    }
    inWord = w
  }
  return n
}

test "slug" {
  expect(slug("Hello, World!") == "hello-world")
  expect(slug("  Rill 0.1  ") == "rill-0-1")
}

test "words" {
  expect(words("one, two;three") == 3)
  expect(words("") == 0)
}
```

<!-- include: packages/textkit/wrap/wrap.rl -->
```swift
// wrap: a second package of the module (import "github.com/ada/textkit/wrap").

/// The words of `s` as lines of at most `width` bytes (longer words get a line each).
pub fn lines(_ s: String, width: Int) -> [String] {
  var out: [String] = []
  var line = ""
  for w in s.split(" ") {
    if w == "" {
      continue
    }
    if line == "" {
      line = w
    } else if line.len() + 1 + w.len() <= width {
      line = line + " " + w
    } else {
      out.push(line)
      line = w
    }
  }
  if line != "" {
    out.push(line)
  }
  return out
}

test "lines" {
  expect(lines("a bb ccc dddd", width: 6) == ["a bb", "ccc", "dddd"])
  expect(lines("", width: 3).len() == 0)
}
```

<!-- include: packages/textkit/internal/ascii/ascii.rl -->
```swift
// Byte classes. Under internal/: only textkit itself may import this.

pub fn isLetter(_ b: Int) -> Bool = (b >= 'a' && b <= 'z') || (b >= 'A' && b <= 'Z')

pub fn isDigit(_ b: Int) -> Bool = b >= '0' && b <= '9'

pub fn lower(_ b: Int) -> Int {
  if b >= 'A' && b <= 'Z' {
    return b + 32
  }
  return b
}

test "classes" {
  expect(isLetter('q') && isLetter('Q') && !isLetter('1'))
  expect(isDigit('7') && !isDigit('x'))
  expect(lower('A') == 'a' && lower('-') == '-')
}
```

Inside the module, imports are relative to the module root (`import "internal/ascii"`).
Packages under `internal/` can only be imported by the module that contains them, so
`ascii` can change at any time without breaking anybody.

Copy [`packages/textkit`](packages/textkit) to `~/src/textkit` (`mkdir -p ~/src && cp -R
packages/textkit ~/src/`), then:

<!-- include: packages/sessions/lib.txt -->
```text
$ cd ~/src/textkit
$ rill mod init github.com/ada/textkit
$ cat rill.mod
module github.com/ada/textkit
rill 0.1
$ rill test . && rill test wrap && rill test internal/ascii
ok   slug
ok   words
2 passed, 0 failed
ok   lines
1 passed, 0 failed
ok   classes
1 passed, 0 failed
$ rill api
fn slug(_ s: String) -> String
fn words(_ s: String) -> Int
```

`rill test <dir>` runs the tests of one package. `rill api` prints the public surface of
the module's root package: what callers may depend on. `ascii.lower` is `pub` but not part
of the API, because it is internal.

## Publishing v1.0.0

A version is a Git tag `vMAJOR.MINOR.PATCH`. `rill release` makes that tag after some
checks: the working tree is committed, `CHANGELOG.md` has a section for the version, and
the version fits the API change (it compares `rill api` with the previous tag).

<!-- include: packages/textkit/CHANGELOG.md -->
```markdown
# Changelog

## [1.0.0] - 2026-11-02
### Added
- `slug`, `words`, and the `wrap` package.
```

<!-- include: packages/sessions/release1.txt -->
```text
$ git init -q && git add -A && git commit -qm "textkit 1.0"
$ rill release --dry-run
error[E0111]: CHANGELOG.md has no section for v0.1.0 (## [0.1.0] - YYYY-MM-DD)
[exit 1]
$ rill release v1.0.0 --unsigned
release v1.0.0 (previous: none, API change: minor)
created tag v1.0.0; publish it with: git push origin v1.0.0
$ git init -q --bare ~/remote/textkit && git -C ~/remote/textkit config uploadpack.allowFilter true
$ git remote add origin ~/remote/textkit && git push -q origin main v1.0.0
```

- Without a version, `rill release` picks one: `v0.1.0` for the first release, otherwise
  the smallest bump the API change allows. Our changelog says 1.0.0, so we name it.
- Release tags are signed by default (Git's signing setup, for example SSH keys);
  `--unsigned` skips that here. Consumers can require signed tags with a `signers` line in
  their `rill.mod`.
- `uploadpack.allowFilter` lets the bare repository serve partial clones (Rill fetches
  only the files of one version); GitHub does that already.

## The app

[`packages/greeter/main.rl`](packages/greeter/main.rl):

<!-- include: packages/greeter/main.rl -->
```swift
import "github.com/ada/textkit"
import "github.com/ada/textkit/wrap"

fn main() {
  let title = "Packages in Rill: A Hands-On Tour"
  print("/posts/${textkit.slug(title)} (${textkit.words(title)} words)")
  for line in wrap.lines(title, width: 16) {
    print("  $line")
  }
}
```

Copy it to `~/src/greeter/main.rl` (`cp -R packages/greeter ~/src/`), then:

<!-- include: packages/sessions/app.txt -->
```text
$ cd ~/src/greeter
$ rill mod init github.com/ada/greeter
$ rill run .
error[E0017]: cannot import 'github.com/ada/textkit': no requirement provides it (run: rill get <module>)
 --> main.rl:1:1
  |
1 | import "github.com/ada/textkit"
  | ^

error[E0017]: cannot import 'github.com/ada/textkit/wrap': no requirement provides it (run: rill get <module>)
 --> main.rl:2:1
  |
2 | import "github.com/ada/textkit/wrap"
  | ^
[exit 1]
$ rill get github.com/ada/textkit
rill get: github.com/ada/textkit v1.0.0
$ cat rill.mod
module github.com/ada/greeter
rill 0.1
require github.com/ada/textkit v1.0.0
$ cat rill.sum
github.com/ada/textkit v1.0.0 commit=3b6f18f015ebdcbf6838ccaff5815f8c167208cf tree=sha256:f75fc8b671037c0ca4eb525b1d7ddbec1124415734e089f0a024ee2861b4fa3b
github.com/ada/textkit v1.0.0/rill.mod sha256:a4bb9152af35730505a7f44d294036a9b92d4e1e9060be1a578e9d97c6d7a17a
$ rill run .
/posts/packages-in-rill-a-hands-on-tour (7 words)
  Packages in
  Rill: A Hands-On
  Tour
$ rill lsp --check main.rl
$ ls ~/.rill/mod/github.com/ada
textkit@v1.0.0
```

- Builds never touch the network: an import that no requirement provides is an error
  (E0017) that says what to run.
- `rill get <module>` resolves the newest version tag, downloads that version into the
  module cache (`~/.rill/mod`, read-only), and records it.
- `rill.mod` gets a `require` line. With several modules requiring the same dependency,
  the highest required version wins (minimal version selection): no ranges, no solver,
  the same build every time.
- `rill.sum` pins the commit of the tag and a SHA-256 of the files. A tag that later
  points at another commit is refused when downloading, and `rill mod verify` notices a
  changed file in the cache. Commit both files.
- `rill run .` builds the directory as one program. `rill lsp --check` sees packages from
  the cache too, so editors resolve them.

### `internal/` is enforced

<!-- include: packages/snippets/peek.rl -->
```swift
import "github.com/ada/textkit/internal/ascii"

fn main() {
  print("${ascii.isLetter('x')}")
}
```

<!-- include: packages/sessions/internal.txt -->
```text
$ rill run peek.rl
error[E0038]: cannot import 'github.com/ada/textkit/internal/ascii': only modules under 'github.com/ada/textkit' may
 --> peek.rl:1:1
  |
1 | import "github.com/ada/textkit/internal/ascii"
  | ^
[exit 1]
$ rm peek.rl
```

## v1.1.0: a new function, an old one deprecated

`slug` always joins with `-`; we want any separator. Adding `slugify(s, sep:)` is a
compatible change. `slug` stays (removing it would break callers and need v2.0.0), but it
is now deprecated, and implemented by calling `slugify`:

<!-- include: packages/v1.1/textkit.rl -->
```swift
// textkit: small text helpers.
import "internal/ascii"

/// `s` as a slug: lower-case letters and digits, runs of anything else as one `sep`.
pub fn slugify(_ s: String, sep: String) -> String {
  var sb = StringBuilder()
  var gap = false
  for i in 0..<s.len() {
    let b = s.byteAt(i)
    if ascii.isLetter(b) || ascii.isDigit(b) {
      if gap && sb.len() > 0 {
        sb.add(sep)
      }
      sb.addByte(ascii.lower(b))
      gap = false
    } else {
      gap = true
    }
  }
  return sb.build()
}

/// `s` as a URL slug.
/// deprecated: use slugify(s, sep: "-")
/// fix: inline
pub fn slug(_ s: String) -> String = slugify(s, sep: "-")

/// The number of words (runs of letters and digits) in `s`.
pub fn words(_ s: String) -> Int {
  var n = 0
  var inWord = false
  for i in 0..<s.len() {
    let b = s.byteAt(i)
    let w = ascii.isLetter(b) || ascii.isDigit(b)
    if w && !inWord {
      n += 1
    }
    inWord = w
  }
  return n
}

test "slugify" {
  expect(slugify("Hello, World!", sep: "_") == "hello_world")
  expect(slug("  Rill 0.1  ") == "rill-0-1")
}

test "words" {
  expect(words("one, two;three") == 3)
  expect(words("") == 0)
}
```

- `/// deprecated: <message>` makes every call of `slug` in other modules warn (W0001).
- `/// fix: inline` tells `rill fix` to replace each call with the function's body, with
  the arguments substituted. That only works for a function whose body is one
  expression, as here.

Replace `~/src/textkit/textkit.rl` with [`packages/v1.1/textkit.rl`](packages/v1.1/textkit.rl):

<!-- include: packages/sessions/release2.txt -->
```text
$ cd ~/src/textkit
$ rill lsp --check textkit.rl && rill test .
ok   slugify
ok   words
2 passed, 0 failed
$ rill api diff v1.0.0 .
+ fn slugify(_ s: String, sep: String) -> String
change: minor
$ git commit -qam "slugify; slug deprecated" && rill release --dry-run
error[E0111]: CHANGELOG.md has no section for v1.1.0 (## [1.1.0] - YYYY-MM-DD)
[exit 1]
$ git commit -qam "changelog for 1.1.0" && rill release --dry-run
release v1.1.0 (previous: v1.0.0, API change: minor)
+ fn slugify(_ s: String, sep: String) -> String
dry run: would create the signed tag v1.1.0
$ rill release --unsigned
release v1.1.0 (previous: v1.0.0, API change: minor)
+ fn slugify(_ s: String, sep: String) -> String
created tag v1.1.0; publish it with: git push origin v1.1.0
$ git push -q origin main v1.1.0
```

`rill api diff v1.0.0 .` compares the tagged version with the working tree: one function
added, a minor change. A changed signature, a removed function, a new enum case, a new
struct field or interface method would be breaking, and `rill release` would refuse
anything below the next major version (v2 also needs a new module path ending in `/v2`).
The release waits for the changelog section
([`packages/v1.1/CHANGELOG.md`](packages/v1.1/CHANGELOG.md)):

<!-- include: packages/v1.1/CHANGELOG.md -->
```markdown
# Changelog

## [1.1.0] - 2026-11-02
### Added
- `slugify(s, sep:)`: slugs with any separator.
### Deprecated
- `slug(s)`: use `slugify(s, sep: "-")`; `rill fix` rewrites the calls.

## [1.0.0] - 2026-11-02
### Added
- `slug`, `words`, and the `wrap` package.
```

Note: `rill api` and the release check cover the module's root package only. Changes to
`wrap` are not compared, so review those yourself.

## Upgrading the app

<!-- include: packages/sessions/upgrade.txt -->
```text
$ cd ~/src/greeter
$ rill get github.com/ada/textkit
rill get: github.com/ada/textkit v1.1.0
$ rill run .
warning[W0001]: 'slug' is deprecated: use slugify(s, sep: "-") (rill fix rewrites this call)
 --> main.rl:6:31
  |
6 |   print("/posts/${textkit.slug(title)} (${textkit.words(title)} words)")
  |                               ^
/posts/packages-in-rill-a-hands-on-tour (7 words)
  Packages in
  Rill: A Hands-On
  Tour
$ rill build --deny-warnings . -o greeter
error[W0001]: 'slug' is deprecated: use slugify(s, sep: "-") (rill fix rewrites this call)
 --> main.rl:6:31
  |
6 |   print("/posts/${textkit.slug(title)} (${textkit.words(title)} words)")
  |                               ^
[exit 1]
$ rill fix --list
main.rl:6: textkit.slug(title) -> textkit.slugify(title, sep: "-")
$ rill fix
main.rl: rewrote 1 call(s)
$ cat main.rl
import "github.com/ada/textkit"
import "github.com/ada/textkit/wrap"

fn main() {
  let title = "Packages in Rill: A Hands-On Tour"
  print("/posts/${textkit.slugify(title, sep: "-")} (${textkit.words(title)} words)")
  for line in wrap.lines(title, width: 16) {
    print("  $line")
  }
}
$ rill build --deny-warnings . -o greeter && ./greeter
/posts/packages-in-rill-a-hands-on-tour (7 words)
  Packages in
  Rill: A Hands-On
  Tour
$ rill mod tidy && rill mod verify
all modules verified
```

- `rill get github.com/ada/textkit` (or `…@v1.1.0`) moves the requirement to the newest
  version; `rill.mod` and `rill.sum` change accordingly.
- The deprecation is a warning, so the build still works; `--deny-warnings` (CI) turns it
  into an error.
- `rill fix --list` shows the rewrites, `rill fix` applies them (and removes imports that
  are no longer used).
- `rill mod tidy` makes the requirements follow the imports: it adds missing ones and
  removes unused ones (nothing to do here). `rill mod verify` re-checks the cache against
  `rill.sum`.

The same mechanism moves callers across a major version: a last v1 release can implement
its functions by calling the v2 module and mark them `fix: inline`, so `rill fix` rewrites
callers to v2.

## More

- `rill mod graph` (the requirement graph), `rill mod download` (fill the cache, e.g. in
  CI), `rill mod vendor` (copy dependencies into `vendor/`).
- `replace github.com/ada/textkit => ../textkit` in `rill.mod`, or a `rill.work` file with
  `use ./greeter` and `use ./textkit`, builds against a local checkout while you work on
  both.
- The [Modules chapter](../book/07-modules.md) of the book has the reference.

Back to the [tutorials](README.md).
