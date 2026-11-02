# rillang.github.io

The website, the book and the tutorials of the [Rill](https://github.com/rillang/rill)
programming language, published with GitHub Pages at <https://rillang.github.io>.

| Directory | What |
|---|---|
| [`site/`](site) | the website: plain HTML and CSS, no build step |
| [`book/`](book) | The Rill Book and Rill by Example; every example runs |
| [`tutorials/`](tutorials) | hands-on tutorials; every command's output is checked |

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
```

CI runs both checks on every pull request and nightly against the newest compiler; a
nightly failure opens an issue. Pages are deployed from `main`.

## License

MIT OR Apache-2.0, like Rill itself.
