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
  print("${geometry.length2(v)}")
  let s: geometry.Shape = .rect(2, 5)
  print("${geometry.area(s)} ${geometry.area(geometry.Shape.square(3))}")
  // UFCS looks in the current module only: v.length2() would not find geometry.length2
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
  UFCS (`v.length2()`) does not find functions of another module; call them as
  `geometry.length2(v)`.
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

**Planned** ([spec](https://github.com/rillang/rill/blob/main/docs/specs/2026-11-02-rill-packages-stdlib-design.md)): `rill mod
outdated`, `rill update` (changelog and API diff of an upgrade, then `rill fix`, build and
tests), `rill mod audit` (retractions, security advisories).

Next: [Testing](08-testing.md).
