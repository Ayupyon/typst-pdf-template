# Rin's Typst template

Rin 0.3 adds a dual-target theorem API while preserving the paged `conf(...)`
entry point used by 0.2.1 documents. Version 0.2.1 remains unchanged.

## Rin 0.3 highlights

- `definition`, `theorem`, `lemma`, and `proof` keep the existing Showybox PDF
  presentation and emit semantic, classed HTML when Typst's HTML target is used.
- Theorem-like numbering restarts at each level-one heading and references use
  the labelled block's section in both targets.
- `conf(date: ...)` accepts an explicit `datetime` or displayable content. If
  omitted, the legacy Typsidian build-date behavior is retained.
- `diagram` wraps Fletcher 0.5.8. Non-empty `alt` text is mandatory; HTML gets
  an inline SVG in a labelled figure and an optional caption.
- The block functions accept a `label` override, so a Chinese facade can bind
  `theorem.with(label: [定理])`, `definition.with(label: [定义])`,
  `lemma.with(label: [引理])`, and `proof.with(label: [证明。])` while the Rin
  defaults remain compatible with existing English documents.
- `with-rin-rules` is the integration wrapper for an HTML article template. It
  installs block counter/reset/reference behavior without paged layout; a blog
  facade should consume it internally rather than re-export it to post authors.

Fletcher nodes and edges are arguments to the wrapper, matching Fletcher's
native call shape:

```typ
#diagram(
  node((0, 0), [A]),
  node((1, 0), [B]),
  edge((0, 0), (1, 0), "->"),
  alt: "An arrow from A to B",
  caption: [A simple morphism.],
)
```

The stable HTML class contract is:

```text
.rin-block
.rin-block--definition
.rin-block--theorem
.rin-block--lemma
.rin-proof
.rin-block__heading
.rin-block__body
.rin-diagram
.rin-diagram__viewport
.rin-diagram__caption
```

The consuming site owns CSS for these classes. Wide diagram behavior should be
implemented on `.rin-diagram__viewport` with `max-width: 100%` and horizontal
overflow; the embedded SVG should use `max-width: 100%` and `height: auto`.

## Focused dual-output gate

Typst 0.15.1 and `pdftotext` are required. Run:

```sh
python3 tests/verify.py
```

The verifier compiles `tests/fixtures/dual-output.typ` to temporary PDF and HTML
outputs, compares visible section-based numbers, checks same-post links and
stable anchors, checks Fletcher accessibility and inline SVG output, rebuilds
HTML to detect unstable IDs, verifies a deterministic PDF date and localized
labels, and confirms that missing diagram alt text fails.

HTML export is experimental in Typst 0.15.1 and therefore uses
`typst compile --features html`.
