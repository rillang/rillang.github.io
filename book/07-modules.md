# 7. Modules

## A directory is a module

<!-- include: examples/lib/geometry/geometry.rl -->
```swift
// A module: one file. Only `pub` items are visible to importers.

pub struct Vec2 { x: Int, y: Int }

pub enum Shape {
  case square(Int)
  case rect(Int, Int)
}

pub fn area(_ s: Shape) -> Int {
  switch s {
  case .square(n): return square(n)
  case .rect(w, h): return w * h
  }
}

pub fn square(_ n: Int) -> Int = n * n

pub fn length2(_ v: Vec2) -> Int = square(v.x) + square(v.y)

fn helper() -> Int = 1

test "area of a square" {
  expect(area(.square(3)) == 9)
  expect(helper() == 1)
}
```

<!-- include: examples/modules.rl -->
```swift
// the path is relative to this file, without .rl
import "lib/geometry"

fn main() {
  let v = geometry.Vec2(x: 3, y: 4)
  print("${v.length2()}") // UFCS: length2 is pub in the module declaring Vec2
  let s: geometry.Shape = .rect(2, 5)
  print("${geometry.area(s)} ${geometry.area(geometry.Shape.square(3))}")
  let f: (geometry.Vec2) -> Int = geometry.length2
  print("${f(v)}")
}
```

<!-- include: examples/modules.out -->
```text
25
10 9
25
```

- `import "lib/geometry"` loads the directory `lib/geometry/`: every `.rl` file in it
  belongs to the module and sees the others' names. The path is relative to the nearest
  `rill.mod` above the program, or to the program's own directory if there is none. The
  module's name is the last path segment (`geometry`); `import "lib/geometry" as geo`
  picks another one.
- Paths under `internal/` (`a/internal/b`) can only be imported from inside `a/`.
- Only `pub` declarations are visible outside the module (E0016 otherwise). Inside a module,
  order does not matter: everything can use everything.
- Imported names are always qualified: `geometry.area(s)`, `geometry.Vec2(x: 3, y: 4)`.
  UFCS (`v.length2()`) looks in the current module first, then among the `pub` functions
  of the module that declares the receiver's type; any other module's function is called as
  `module.f(x)`. That module need not be imported: a value's type brings its functions along.
  Plain calls (`length2(v)`) always need the prefix.
- Import cycles are an error (E0017).
- `test` blocks in a module run with `rill test lib/geometry` and can see private
  functions.

## The standard library

`import "std/strings"`, `std/fs`, `std/os`, … are embedded in the compiler; see
[chapter 15](15-standard-library.md).

## Packages

Modules from Git repositories, named by their path (Go style):

```sh
rill mod init github.com/you/app     # writes rill.mod
rill get github.com/acme/lib         # newest release into rill.mod, hashes into rill.sum
rill run .                           # import "github.com/acme/lib" works offline
rill mod tidy                        # requirements follow the imports
```

- `rill.mod` lists requirements (`require github.com/acme/lib v1.1.0`); `rill.sum` pins the
  commit and a content hash of every version. A changed hash or a moved tag is an error.
- Minimal version selection: every module comes in the highest version that anyone
  requires; no ranges, no solver.
- Builds never fetch: a missing module is E0101 (`rill mod download`). `rill mod vendor`
  copies the build's modules into `vendor/`.
- Major versions >= 2 have their own path: `import "github.com/acme/lib/v2"`.
- `signers <module> "ssh-ed25519 …"` in `rill.mod` requires signed tags.
- `replace <module> => ../dir` or a `rill.work` file (`use ./app`, `use ./lib`) puts a local
  directory in place of a module.

## Evolving an API

- `rill api` prints the module's public surface; `rill api diff v1.2.0 .` says what changed
  and whether it breaks callers (a removed or changed item, a new enum case, a new struct
  field or interface method).
- `rill release` picks the next version from that diff, refuses a bump that is too small,
  needs a `CHANGELOG.md` section for the version and creates a signed tag.
- `/// deprecated: use parseStrict` above a function makes its callers' builds warn
  (W0001); with `/// fix: inline` as well, `rill fix` rewrites every call into the
  function's body. A last v1 release can implement its API by calling v2, so `rill fix`
  moves callers to the new major version.

### Staying up to date

```sh
rill mod outdated                 # newest patch, minor and major release per requirement
rill update                       # newest minor releases: changelog, API diff, rill fix, build, tests
rill update github.com/a/yaml --patch
rill update --pr                  # the same on a new branch, as a pull request (gh)
rill update --major github.com/a/lib   # to lib/v2: the v1 wrappers migrate your calls
rill mod audit                    # retracted versions and security advisories
```

`rill update` shows the changelog sections between your version and the new one and the
API diff, marking breaking changes to functions your code calls. It then runs `rill fix`
(deprecated calls migrate), builds and runs your tests; `--dry-run` only shows the plan.

An author withdraws a bad release with a `retract` line in a newer release's `rill.mod`
(`retract v1.0.3 "parse loops on empty input"`, `retract [v1.1.0, v1.1.4] security
"…"`). Retracted versions are never picked as `latest`, and `outdated`, `update` and
`audit` point at them. `rill mod audit` also reads advisories in the
[OSV](https://ossf.github.io/osv-schema/) format from `RILL_VULNDB` (a directory or an
`https` URL); an advisory that names symbols (`yaml.parse`) is "reachable" only if your
code's call graph reaches one, otherwise "present, not called". It exits 1 when something
needs action.

Next: [Testing](08-testing.md).
