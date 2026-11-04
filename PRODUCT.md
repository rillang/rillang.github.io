# Product

<!-- impeccable:product-schema 1 -->

## Platform

web

## Users

Curious backend and tool developers who write services, command-line tools and scripts in
Go, TypeScript, Python or Swift today and are evaluating a new language, many of them
working with AI coding agents. They arrive from a link, read the landing page for a minute
and decide whether to install Rill or read the book.

## Product Purpose

The website, book and tutorials of the Rill programming language. The landing page makes
the case for trying Rill; the book and Rill by Example teach it; the roadmap says what is
done and what comes next. Success: a visitor understands what Rill is good for and starts
the install or the book.

## Positioning

Three claims together, none of them made by comparing with other languages or by numbers:

1. **Beautiful code, everything included:** code that reads well (enums, pattern matching,
   values, errors in the types) and one `rill` binary that is the whole toolchain (run,
   build, test, fuzz, coverage, benchmarks, profiles, formatter, language server, debugger,
   packages and updates) with a broad standard library embedded in it.
2. **Scripts to engines:** one language that grows with the program, from a script to a
   service to an engine (`nogc`, arenas and SIMD are planned).
3. **For people and AI agents:** one obvious way to write things, stable error codes,
   `--json` output, migrations as code (`rill fix`), a Claude Code plugin; an agent gets the
   same precise feedback as a person.

## Operating Context

Static GitHub Pages site (`site/` plain HTML and CSS, no build step; `book/` and
`tutorials/` as Markdown rendered by `_layouts/doc.html`). Every code sample is a file under
`site/examples/` compiled and run by `book/check.sh` against a Rill compiler checked out
next to this repository.

## Capabilities and Constraints

- Today: arm64 macOS and Linux only; experimental, no releases; built from source.
- Not built yet (must be marked planned or next): networking, HTTP, databases, x86-64,
  Windows, WebAssembly, `nogc`, FFI. Roadmap: `site/roadmap.html`.
- A browser playground or live demo comes after the WebAssembly backend.
- No web fonts, works offline, light and dark themes (`site/style.css`, `site/site.js`).

## Brand Commitments

Name "rill" (a small stream): the wave wordmark and the stream divider. Tagline from RFC
0008: "Code like Swift, build like Go, go as deep as Rust." Voice: plain, honest, specific;
no hype. Existing tokens in `site/style.css`.

## Evidence on Hand

Only real code and real output: the checked samples in `site/examples/`, real compiler
diagnostics, real `rill` sessions, and Rill's own programs (the self-hosting compiler; later
the module proxy). No users, companies, testimonials, logos, benchmarks or comparisons
exist or may be invented.

## Product Principles

1. Show, don't claim: every benefit is demonstrated by code or output that runs today.
2. Honest status: what is planned is labeled planned.
3. No comparisons and no number flexing.
4. One obvious way: the site's own voice is as plain as the language.
