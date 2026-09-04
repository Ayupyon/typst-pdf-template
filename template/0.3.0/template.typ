#import "@preview/typsidian:0.0.3": *
#import "@preview/showybox:2.0.4": showybox
#import "@preview/fletcher:0.5.8" as fletcher

#let normal_font = ("Libertinus Serif", "Noto Serif CJK SC")
#let code_font = ("Fira Code", "FiraCode Nerd Font", "Alibaba PuHuiTi 3.0")
#let math_font = "New Computer Modern Math"

// Public Fletcher primitives. The `diagram` function below remains the only
// public diagram renderer, so target-specific rendering stays encapsulated.
#let node = fletcher.node
#let edge = fletcher.edge

#let fmt-num = (sec, n) => if sec <= 0 { str(n) } else {
  str(sec) + "." + str(n)
}

// A dedicated section counter advances for every level-one heading, including
// unnumbered web headings. This avoids coupling block numbers to whether the
// consuming HTML theme visually numbers article headings.
#let rin-section-counter = counter("rin-section")

#let sec-n = n => context {
  fmt-num(rin-section-counter.get().first(), n)
}

// This registry is the source of truth for labels, accents, counter kinds,
// and the stable HTML modifier class used by every theorem-like block.
#let block-kinds = (
  "definition": (
    label: "Definition",
    color: rgb("#2563eb"),
    class: "rin-block--definition",
  ),
  "theorem": (
    label: "Theorem",
    color: rgb("#7c3aed"),
    class: "rin-block--theorem",
  ),
  "lemma": (
    label: "Lemma",
    color: rgb("#0d9488"),
    class: "rin-block--lemma",
  ),
)

#let _block-rules(body) = [
  #show heading.where(level: 1): it => {
    rin-section-counter.step()
    for (k, _) in block-kinds {
      counter(figure.where(kind: k)).update(0)
    }
    it
  }

  #show figure.where(numbering: sec-n): set block(breakable: true)

  // Resolve both parts of a block number at the labelled figure's location.
  // `link(loc, ...)` gives HTML references a stable fragment destination and
  // preserves PDF links without exposing target-specific author syntax.
  #show ref: it => {
    let el = it.element
    if el == none or el.func() != figure {
      return it
    }

    let k = el.kind
    if k not in block-kinds.keys() or it.form == "page" {
      return it
    }

    let loc = el.location()
    let n = counter(figure.where(kind: k)).at(loc).first()
    let sec = rin-section-counter.at(loc).first()
    let num = fmt-num(sec, n)
    let supp = if it.supplement == auto { el.supplement } else { it.supplement }
    link(loc, [#supp #num])
  }

  #body
]

// Integration hook for a blog/page template. It installs Rin's counter and
// reference rules without applying any paged layout and is intentionally
// separate from the end-user block surface.
#let with-rin-rules(body) = _block-rules(body)

#let _date-content(value) = if type(value) == datetime {
  value.display("[year]-[month padding:zero]-[day padding:zero]")
} else {
  value
}

// Typsidian 0.0.3 hard-codes datetime.today() in `make-title`. Preserve that
// legacy default, but render the same title structure locally when an explicit
// publication date is supplied so repeat builds contain deterministic text.
#let _deterministic-title(title, course, author, date) = pad(
  top: 4pt,
  align(center)[
    #block(text(size: 2em, weight: "semibold", [#course -- #title]))
    #text(
      fill: rgb("#6a6a6a"),
      size: 1.2em,
      [#h(0.5em) #author #h(1em) #_date-content(date)],
    )
    #line(length: 100%, stroke: 0.1em + black)
    #v(1em)
  ],
)

#let _paged-conf(title, course, author, date, body) = typsidian(
  title: title,
  author: author,
  course: course,
  text-args: (
    main: (font: normal_font),
    mono: (font: code_font),
    headings: (font: normal_font),
    math: (font: math_font),
  ),
)[
  #show math.equation.where(block: true): eq => {
    block(width: 100%, inset: 0pt, align(center, eq))
  }
  #show math.equation: set block(breakable: true)

  #if date == none {
    make-title(show-outline: false, show-author: true, justify: "center")
  } else {
    _deterministic-title(title, course, author, date)
  }

  #_block-rules(body)
]

// Legacy `conf(...)` remains a paged-document entry point. HTML integrations
// apply `with-rin-rules` inside their own article template instead.
#let conf(
  title: "Example Title",
  course: "Example Course",
  author: "Example Author",
  date: none,
  body,
) = _paged-conf(title, course, author, date, body)

#let _paged-block(spec, key, label, body, topic: none) = context {
  let num = counter(figure.where(kind: key)).display(sec-n)
  let title = if topic == none {
    [#label #num]
  } else {
    [#label #num (#topic)]
  }
  showybox(
    frame: (
      title-color: spec.color,
      body-color: spec.color.lighten(90%),
      border-color: spec.color,
    ),
    title-style: (color: white, weight: "bold"),
    title: title,
    breakable: true,
    body,
  )
}

#let _html-block(spec, key, label, body, topic: none) = context {
  let num = counter(figure.where(kind: key)).display(sec-n)
  let title = if topic == none {
    [#label #num]
  } else {
    [#label #num (#topic)]
  }
  html.elem(
    "section",
    attrs: (
      class: "rin-block " + spec.class,
      "data-rin-kind": key,
    ),
    html.elem("div", attrs: (class: "rin-block__heading"), title)
      + html.elem("div", attrs: (class: "rin-block__body"), body),
  )
}

// Retain a shared outer figure/counter/reference model. Only its inner renderer
// changes by target; labels at call sites attach to this figure in both forms.
#let _block(key, body, topic: none, label: none) = {
  let spec = block-kinds.at(key)
  let label = if label == none { spec.label } else { label }
  figure(
    kind: key,
    supplement: [#label],
    numbering: sec-n,
    caption: none,
    outlined: false,
    placement: none,
    context {
      if target() == "html" {
        _html-block(spec, key, label, body, topic: topic)
      } else {
        _paged-block(spec, key, label, body, topic: topic)
      }
    },
  )
}

#let make-block = key => (topic: none, label: none, body) => _block(
  key,
  body,
  topic: topic,
  label: label,
)

#let proof(label: [Proof.], body) = context {
  if target() == "html" {
    html.elem(
      "section",
      attrs: (class: "rin-proof"),
      html.elem("div", attrs: (class: "rin-block__heading"), [#emph[#label]])
        + html.elem("div", attrs: (class: "rin-block__body"), [#body #sym.square]),
    )
  } else {
    let c = rgb("#64748b")
    showybox(
      frame: (
        title-color: c.lighten(55%),
        body-color: c.lighten(93%),
        border-color: c.lighten(55%),
      ),
      title-style: (color: c.darken(45%), weight: "bold"),
      breakable: true,
      [#emph[#label] #body #h(1fr) #sym.square],
    )
  }
}

#let _checked-alt(alt) = {
  assert(
    type(alt) == str and alt.trim() != "",
    message: "diagram requires non-empty alt text",
  )
  alt
}

// Positional and named Fletcher arguments are forwarded while this wrapper
// owns target dispatch and accessible HTML. Authors use the re-exported
// node/edge primitives but never call Fletcher's raw renderer directly.
#let diagram(
  ..args,
  alt: none,
  caption: none,
) = context {
  let alt = _checked-alt(alt)
  let rendered = fletcher.diagram(..args)
  if target() == "html" {
    html.elem(
      "figure",
      attrs: (
        class: "rin-diagram",
        role: "img",
        "aria-label": alt,
      ),
      html.elem(
        "div",
        attrs: (class: "rin-diagram__viewport"),
        html.frame(rendered),
      ) + if caption == none {
        none
      } else {
        html.elem("figcaption", attrs: (class: "rin-diagram__caption"), caption)
      },
    )
  } else {
    figure(rendered, caption: caption)
  }
}

#let definition = make-block("definition")
#let theorem = make-block("theorem")
#let lemma = make-block("lemma")
