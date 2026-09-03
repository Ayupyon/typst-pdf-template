#import "@preview/typsidian:0.0.3": *
#import "@preview/showybox:2.0.4": showybox

#let normal_font = ("Libertinus Serif", "Noto Serif CJK SC")
#let code_font = ("FiraCode Nerd Font", "Alibaba PuHuiTi 3.0")
#let math_font = "New Computer Modern Math"

// Format a theorem-like block's number as "<section>.<n>", or just
// "<n>" before the first level-1 heading. Shared by the showybox title
// and `ref` output (via `sec-n` and the `show ref` rule) so they can't
// drift.
#let fmt-num = (sec, n) => if sec <= 0 { str(n) } else {
  str(sec) + "." + str(n)
}

// Numbering function for theorem-like figures: <n> is the figure's own
// per-kind counter (restarted at each level-1 heading) and <section>
// the current level-1 heading number. Used for the showybox title,
// where it resolves at the figure's own location.
#let sec-n = n => context {
  fmt-num(counter(heading).get().first(), n)
}

// Registry of theorem-like block kinds: the single source of truth for
// which figures the heading reset and `show ref` rule treat as numbered
// blocks, and the label/color each renders with. Add a block by adding
// an entry here plus a one-line wrapper below.
#let block-kinds = (
  "definition": (label: "Definition", color: rgb("#2563eb")),
  "theorem": (label: "Theorem", color: rgb("#7c3aed")),
  "lemma": (label: "Lemma", color: rgb("#0d9488")),
)

#let conf(
  title: "Example Title",
  course: "Example Course",
  author: "Example Author",
  body,
) = typsidian(
  title: title,
  author: author,
  course: course,
  text-args: (
    main: (
      font: normal_font,
    ),
    mono: (
      font: code_font,
    ),
    headings: (
      font: normal_font,
    ),
    math: (
      font: math_font,
    ),
  ),
)[
  #show math.equation.where(block: true): eq => {
    block(width: 100%, inset: 0pt, align(center, eq))
  }
  #show math.equation: set block(breakable: true)

  // Reset each block kind's figure counter at every new level-1
  // heading so per-section numbering restarts. The kinds come from
  // `block-kinds`, so adding a block needs no change here.
  #show heading.where(level: 1): it => {
    for (k, _) in block-kinds {
      counter(figure.where(kind: k)).update(0)
    }
    it
  }

  // Let theorem-like figures break across pages, matching showybox's
  // own breakable behaviour. Scoped to figures numbered by `sec-n`
  // (i.e. those created by `_block`) so ordinary image/table figures
  // keep Typst's default non-breakable behaviour.
  #show figure.where(numbering: sec-n): set block(breakable: true)

  // Render references to theorem-like figures as
  // "<supplement> <section>.<n>". Both the section and the per-kind
  // index are read with `.at(el.location())` so they resolve at the
  // figure's position, not the citation site: the default `ref`
  // evaluates the figure's numbering in the citation's context, which
  // breaks cross-section references. Page-form refs fall through to
  // the default.
  #show ref: it => {
    let el = it.element
    if el == none or el.func() != figure {
      return it
    }

    let k = el.kind
    // `el.kind` is a string for our blocks but a function for
    // auto-detected figures (image, table, …). Dict `not in` errors on
    // non-string keys, so test against the keys array, whose `in` is
    // type-safe (`function == "theorem"` is simply false).
    if k not in block-kinds.keys() {
      return it
    }

    if it.form == "page" {
      return it
    }

    let loc = el.location()
    let n = counter(figure.where(kind: k)).at(loc).first()
    let sec = counter(heading).at(loc).first()
    let num = fmt-num(sec, n)
    let supp = if it.supplement == auto {
      el.supplement
    } else {
      it.supplement
    }
    link(loc, [#supp #num])
  }

  #make-title(show-outline: false, show-author: true, justify: "center")

  #body
]

// Shared renderer for the numbered theorem-like blocks.
//
// `label` is the visible kind ("Definition", "Theorem", "Lemma"),
// `key` the figure kind / counter key, `color` the accent color. The
// block is wrapped in a `figure` of kind `key` so a label written at
// the call site (`#theorem[...] <pythag>`) is referenceable via
// `@pythag`, which renders "<label> <section>.<n>". The statement is
// written first; an optional `#proof[...]` call may follow it inside
// the body.
#let _block(label, key, color, body, topic: none) = figure(
  kind: key,
  supplement: [#label],
  numbering: sec-n,
  caption: none,
  outlined: false,
  placement: none,
  context {
    let num = counter(figure.where(kind: key)).display(sec-n)
    let title = if topic == none {
      [#label #num]
    } else {
      [#label #num (#topic)]
    }
    showybox(
      frame: (
        title-color: color,
        body-color: color.lighten(90%),
        border-color: color,
      ),
      title-style: (
        color: white,
        weight: "bold",
      ),
      title: title,
      breakable: true,
      body,
    )
  },
)

// Build a block wrapper (`#theorem[...]`, etc.) from a `block-kinds`
// entry, so the label and color live in exactly one place.
#let make-block = key => {
  let s = block-kinds.at(key)
  (topic: none, body) => _block(s.label, key, s.color, body, topic: topic)
}

// Optional proof block, meant to be placed inside a `theorem` or
// `lemma` body, after the statement. Renders a subdued inner box
// ending with a right-aligned QED tombstone.
#let proof(body) = {
  let c = rgb("#64748b")
  showybox(
    frame: (
      title-color: c.lighten(55%),
      body-color: c.lighten(93%),
      border-color: c.lighten(55%),
    ),
    title-style: (
      color: c.darken(45%),
      weight: "bold",
    ),
    breakable: true,
    [_proof._ #body #h(1fr) #sym.square],
  )
}

// Block wrappers. Each is a one-liner over `make-block`; the label and
// color come from `block-kinds`. Add a new block by adding an entry to
// `block-kinds` above and one line here.
#let definition = make-block("definition")
#let theorem = make-block("theorem")
#let lemma = make-block("lemma")
