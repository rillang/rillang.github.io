#!/usr/bin/env rill
// tidy: file names in lower case with dashes instead of spaces. Shows what it would
// do; --apply renames.
import "std/fs"
import "std/os"
import "std/slices"
import "std/strings"

fn tidyName(_ name: String) -> String = strings.replace(strings.toLower(name.trim()), " ", "-")

test "tidyName" {
  expect(tidyName("Beach Day 01.JPG") == "beach-day-01.jpg")
  expect(tidyName("ok.png") == "ok.png")
}

fn main() -> Void! {
  var apply = false
  var dir = "."
  for a in os.args() {
    if a == "--apply" {
      apply = true
    } else {
      dir = a
    }
  }
  var changes = 0
  let names = fs.readDir(dir)?
  for name in names {
    let tidy = tidyName(name)
    if tidy == name {
      continue
    }
    // the listing, not fs.exists: on macOS `IMG.HEIC` and `img.heic` are one file
    if slices.contains(names, tidy) {
      print("skip $name: $tidy exists")
      continue
    }
    print("$name -> $tidy")
    if apply {
      fs.rename("$dir/$name", "$dir/$tidy")?
    }
    changes += 1
  }
  if !apply && changes > 0 {
    print("(dry run: --apply renames)")
  }
}
