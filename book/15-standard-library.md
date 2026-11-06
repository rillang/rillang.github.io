# 15. The standard library

The standard library is embedded in the compiler: nothing to install, and its version is
the compiler's. Import a module by its path under `std/`:

<!-- include: examples/stdlib.rl -->

<!-- include: examples/stdlib.out -->

| Module | Contents |
|---|---|
| `std/strings` | `join`, `split`, `lines`, `trim`, `replace`, `index`, `lastIndex`, `contains`, `hasPrefix/Suffix`, `trimPrefix/Suffix`, `repeat`, `toUpper/Lower` (ASCII), `equalFold`, `padLeft`, `padRight` (to a display width) |
| `std/utf8` | `decode(s, i)` (rune and width), `encode`, `runes`, `runeCount`, `isValid` |
| `std/fmt` | `pad(s, width:, align:)`, `int(n, base:)`, `hex`, `zero(n, width:)`, `float(x, prec:)` |
| `std/slices` | `sort`, `sortBy`, `binarySearch`, `reverse`, `index`, `contains`, `unique`, `min`, `max` (generic) |
| `std/math` | `sqrt`, `floor`, `ceil`, `round`, `abs`, `powi`, `min`, `max`, `pi`, `e`, `inf`, `isNaN` |
| `std/path` | `join`, `dir`, `base`, `ext`, `stem`, `clean`, `isAbs` (text only) |
| `std/fs` | `readFile`, `writeFile`, `exists`, `mkdirAll`, `readDir`, `stat` (`FileInfo`), `remove`, `removeAll`, `rename`, `chmod`, `walk`, `tempDir` |
| `std/os` | `args`, `env`, `exit`, `cwd`, `run`, `runCapture`, `runCombined` (`Output`: exit code, stdout and stderr), `isTerminal`, `readStdin`, `writeStdout`, `platform` |
| `std/unicode` | `category` (`Category`), `is`, `inClass`, `isLetter`, `isDigit`, `isSpace`, `isUpper`, `isLower`, `isPunct`, `fold`, `toUpper`, `toLower`, `graphemes(s) -> [String]`, `width(s) -> Int` (Unicode 16.0) |
| `std/regexp` | `compile` (`Regex!`), `quote`, `matches`, `find`, `findAll` (`Match`), `captures`, `capturesAll` (`Captures`: `text`, `named`, `span`), `replace`, `replaceAll`, `replaceFunc`, `replaceAllFunc`, `split`, `groupNames`, `numGroups` |
| `std/time` | `now` (Unix ns), `monotonic`, `since`, `sleep`, `Duration` (`milliseconds`, `seconds`, `text`), `rfc3339` |
| `std/json` | `Json` (`null`, `bool`, `num(Float)`, `str`, `arr`, `obj(Map)`), `parse` (`Json!`), `stringify`, `pretty`, `get`, `at`, `str`, `int`, `num`, `bool`, `items`, `object` |
| `std/hash/sha256` | `sum(String)` (hex), `sumBytes`, `sumRange`, `hex` |
| `std/pprof` | `startCpu`, `stopCpu`, `writeHeap`, `setMemProfileRate`, `writeTasks`: profiles for `rill pprof` and Go's pprof ([tooling](11-tooling.md#profiling-rill-pprof)) |
| `std/runtime` | `setGcPercent` (the collector's target, returns the previous value), `numCpu` |

## Regular expressions

`std/regexp` uses RE2's syntax and matches in time linear in the input: there is no
backtracking, so no backreferences or lookaround. Offsets are byte offsets.

<!-- include: examples/regexp.rl -->

<!-- include: examples/regexp.out -->

Classes: `[a-z]`, `[^…]`, `[[:alpha:]]`, `\d \w \s` (ASCII), `\pL`, `\p{Lu}`, `\P{N}`
(Unicode general categories, not scripts). Flags: `(?i)` (Unicode case folding), `(?m)`,
`(?s)`, `(?U)`, also scoped as `(?i:…)`. Groups: `(…)`, `(?:…)`, `(?P<name>…)`. A
replacement template refers to groups as `$1`, `${1}` or `${name}`; `$$` is a `$`.

Every module has `///` documentation on its public declarations and its own tests
(`rill test std/strings` in the repository).

Next: back to the [contents](README.md).
