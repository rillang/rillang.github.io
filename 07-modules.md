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

## Planned: standard library, packages

The approved [packages and standard library spec](../specs/2026-11-02-rill-packages-stdlib-design.md)
adds the rest. Directory modules (above) are done; **the standard library and packages are not yet.** In short:

- **A standard library embedded in the compiler**: `import "std/strings"`, `std/fs`,
  `std/os`, `std/json`, `std/time`, `std/fmt`, `std/utf8`, `std/slices`, `std/math`,
  `std/path`, `std/hash/sha256`. Today's global builtins `readFile`, `writeFile`,
  `fileExists`, `mkdirAll`, `args`, `env`, `run`, `runCapture` move there.
- **Packages from Git URLs**, Go style: `rill.mod` lists requirements, `rill.sum` pins
  commit and content hashes, minimal version selection picks versions, `rill get` is the
  only command that touches the network, and no code of a dependency runs while it is
  fetched. Signed tags can be required per dependency.
- **Update tooling**: `rill api diff`, `rill release` (semver from the API diff, signed
  tag), `rill mod outdated`, `rill update` (changelog, API diff, automatic migration with
  `fix: inline`), `rill mod audit`.

Next: [Testing](08-testing.md).
