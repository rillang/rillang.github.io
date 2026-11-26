# std/strings

Operations on strings beyond the built-in methods (`len`, `slice`, `split`, `trim`, ...). Strings
are bytes: every index and length counts bytes (only [padLeft](#padLeft) and [padRight](#padRight) count display
columns); std/utf8 and std/unicode work with characters. [join](#join), [split](#split), [replace](#replace), [index](#index),
[hasPrefix](#hasPrefix), [trimPrefix](#trimPrefix), [toUpper](#toUpper) and [padLeft](#padLeft) are the usual entry points.

[toUpper](#toUpper) and [toLower](#toLower) map ASCII letters only; [equalFold](#equalFold) folds Unicode simple cases, and
[unicode.toUpper](unicode.md#toUpper) maps one character. Tests: `strings_test.rl`.

```swift
let csv = "  name, age ,city  "
let parts = split(trim(csv), ",")
print(join(parts.map { p in trim(p) }, "|"))
```

*Output*

```text
name|age|city
```

<a id="join"></a>

## fn join

```swift
fn join(_ parts: [String], _ sep: String) -> String
```

The elements of `parts` with `sep` between them.

```swift
print(join(["a", "b"], ", "))
```

*Output*

```text
a, b
```

*empty*

```swift
let none: [String] = []
print("[" + join(none, ", ") + "]")
```

*Output*

```text
[]
```

<a id="repeat"></a>

## fn repeat

```swift
fn repeat(_ s: String, _ n: Int) -> String
```

`s` repeated `n` times ("" for n <= 0 or an empty `s`). Panics with
`strings: repeat output length overflow` when the result would be longer than an Int holds.

```swift
print(repeat("ab", 3))
```

*Output*

```text
ababab
```

<a id="split"></a>

## fn split

```swift
fn split(_ s: String, _ sep: String) -> [String]
```

The pieces of `s` between occurrences of `sep` (`sep` must not be empty).

```swift
print(join(split("a,b,,c", ","), "|"))
```

*Output*

```text
a|b||c
```

<a id="lines"></a>

## fn lines

```swift
fn lines(_ s: String) -> [String]
```

The lines of `s`, without their line endings.

```swift
print("${lines("one\ntwo\n").len()}")
```

*Output*

```text
2
```

<a id="trim"></a>

## fn trim

```swift
fn trim(_ s: String) -> String
```

`s` without leading and trailing whitespace.

```swift
print("[" + trim("  hi\t\n") + "]")
```

*Output*

```text
[hi]
```

<a id="hasPrefix"></a>

## fn hasPrefix

```swift
fn hasPrefix(_ s: String, _ prefix: String) -> Bool
```

Whether `s` starts with `prefix`.

```swift
print("${hasPrefix("rill.mod", "rill")} ${hasPrefix("rill.mod", "mod")}")
```

*Output*

```text
true false
```

<a id="hasSuffix"></a>

## fn hasSuffix

```swift
fn hasSuffix(_ s: String, _ suffix: String) -> Bool
```

Whether `s` ends with `suffix`.

```swift
print("${hasSuffix("main.rl", ".rl")} ${hasSuffix("main.rl", "main")}")
```

*Output*

```text
true false
```

<a id="trimPrefix"></a>

## fn trimPrefix

```swift
fn trimPrefix(_ s: String, _ prefix: String) -> String
```

`s` without `prefix`, if it starts with it.

```swift
print(trimPrefix("v1.2", "v"))
print(trimPrefix("1.2", "v"))
```

*Output*

```text
1.2
1.2
```

<a id="trimSuffix"></a>

## fn trimSuffix

```swift
fn trimSuffix(_ s: String, _ suffix: String) -> String
```

`s` without `suffix`, if it ends with it.

```swift
print(trimSuffix("main.rl", ".rl"))
```

*Output*

```text
main
```

<a id="contains"></a>

## fn contains

```swift
fn contains(_ s: String, _ sub: String) -> Bool
```

Whether `sub` occurs in `s`.

```swift
print("${contains("hello", "ell")} ${contains("hello", "xyz")}")
```

*Output*

```text
true false
```

<a id="index"></a>

## fn index

```swift
fn index(_ s: String, _ sub: String) -> Int?
```

Byte offset of the first occurrence of `sub` in `s`.

```swift
print("${opt(index("a.b.c", "."))} ${opt(index("abc", "x"))}")
```

*Output*

```text
1 nil
```

<a id="lastIndex"></a>

## fn lastIndex

```swift
fn lastIndex(_ s: String, _ sub: String) -> Int?
```

Byte offset of the last occurrence of `sub` in `s`.

```swift
print("${opt(lastIndex("a.b.c", "."))} ${opt(lastIndex("abc", "x"))}")
```

*Output*

```text
3 nil
```

<a id="replace"></a>

## fn replace

```swift
fn replace(_ s: String, _ old: String, _ new: String) -> String
```

`s` with every occurrence of `old` replaced by `new` (`old` must not be empty).

```swift
print(replace("a-b-c", "-", "+"))
```

*Output*

```text
a+b+c
```

<a id="toUpper"></a>

## fn toUpper

```swift
fn toUpper(_ s: String) -> String
```

`s` with ASCII letters in upper case.

```swift
print(toUpper("rill"))
```

*Output*

```text
RILL
```

<a id="toLower"></a>

## fn toLower

```swift
fn toLower(_ s: String) -> String
```

`s` with ASCII letters in lower case.

```swift
print(toLower("RiLL"))
```

*Output*

```text
rill
```

<a id="equalFold"></a>

## fn equalFold

```swift
fn equalFold(_ a: String, _ b: String) -> Bool
```

Whether `a` and `b` are equal after simple case folding of each character.

```swift
print("${equalFold("Rill", "rILL")} ${equalFold("a", "b")}")
```

*Output*

```text
true false
```

<a id="padLeft"></a>

## fn padLeft

```swift
fn padLeft(_ s: String, _ n: Int) -> String
```

`s` with spaces before it up to `n` display columns (`unicode.width`); a wider `s` is unchanged.

```swift
print("[" + padLeft("7", 3) + "]")
print("[" + padLeft("long", 2) + "]")
```

*Output*

```text
[  7]
[long]
```

<a id="padRight"></a>

## fn padRight

```swift
fn padRight(_ s: String, _ n: Int) -> String
```

`s` with spaces after it up to `n` display columns (`unicode.width`); a wider `s` is unchanged.

```swift
print("[" + padRight("7", 3) + "]")
```

*Output*

```text
[7  ]
```

