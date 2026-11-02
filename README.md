# rillang.github.io

The website, the book and the tutorials of the [Rill](https://github.com/rillang/rill)
programming language, published with GitHub Pages at <https://rillang.github.io>.

| Directory | What |
|---|---|
| [`site/`](site) | the website: plain HTML and CSS, no build step |
| [`book/`](book) | The Rill Book and Rill by Example; every example runs |
| [`tutorials/`](tutorials) | hands-on tutorials; every command's output is checked |

The Markdown pages need no front matter: GitHub Pages renders them with
[`_layouts/doc.html`](_layouts/doc.html) (the website's header, `site/style.css` and
`site/site.js`, a sidebar and previous/next links). The page order comes from the index
pages (`book/README.md`, `book/by-example/README.md`, `tutorials/README.md`):
after adding or reordering a page there, run `sh tools/nav.sh` to regenerate
[`_data/nav.yml`](_data/nav.yml); `sh tools/nav.sh --check` (run by CI) fails when a page
is not linked from its index or nav.yml is stale. Rill code is fenced as `swift` (or
`rill`), program output and shell sessions as `text`, commands as `sh`.

## Checking against the compiler

Every code sample is a file that is compiled, run and compared with its expected output,
so the docs cannot drift from the language. The checks need a Rill compiler: by default a
checkout of [rillang/rill](https://github.com/rillang/rill) next to this one
(`../rill`, built with `sh bootstrap.sh`), or `RILL=/path/to/rill`.

```sh
sh book/check.sh          # the book, by-example and the website's samples
sh tutorials/check.sh     # the tutorials (replays their shell sessions)
UPDATE=1 sh book/check.sh # after an intended change: rewrite expected output, review the diff
sh book/sync.sh           # copy examples into the pages
sh tools/nav.sh           # regenerate the navigation after changing an index page
```

CI runs both checks on every pull request and nightly against the newest compiler; a
nightly failure opens an issue. Pages are deployed from `main`.

## License

MIT OR Apache-2.0, like Rill itself.
