#let normal_font = ("Libertinus Serif", "Source Han Serif SC")
#let code_font = ("FiraCode Nerd Font", "Alibaba PuHuiTi 3.0")

#let conf(title, doc, name: none) = {
  // font setting
  set text(font: normal_font)
  show raw: set text(font: code_font)

  // style setting
  set heading(numbering: none)
  show heading: set block(below: 1em)
  show raw.where(block: true): set block(fill: luma(240), inset: 1em, radius: 0.5em, width: 100%)
  show math.equation.where(block: true): eq => {
    block(width: 100%, inset: 0pt, align(center, eq))
  }
  show math.equation: set block(breakable: true)

  let heading_content = text(20pt, title)
  if name != none {
    heading_content += [#parbreak() #name]
  }

  if heading_content != none {
    align(center)[#heading_content]
  }
  doc
}

#let corollary_counter = counter("corollary")
#let corollary(it, label: none) = {
  block(inset: 1em, radius: 0.5em, stroke: black)[
    #corollary_counter.step()
    #let cur = context corollary_counter.display()
    *Corollary #cur:* #it #label
  ]
}
#let corollary_link(label) = {
  link(label)[
    #let cur = context corollary_counter.at(label).at(0)
    Corollary #cur
  ]
}

#let proof(body) = block({
  [_Proof._ ]
  body
  box(width: 0pt)
  h(1fr)
  sym.wj
  sym.space.nobreak
  $qed$
})

#let pseudo_code(title: none, content) = {
  show raw.where(lang: "pseudo"): it => {
    set block(fill: white, inset: 0em, radius: 0em, width: 100%)
    show regex("\$(.*?)\$"): re => {
      eval(re.text, mode: "markup")
    }
    it
  }

  block(
    fill: white,
    stroke: black,
    inset: 1em,
    radius: 0.5em,
    width: 100%,
  )[
    #if title != none [
      *#title*:
    ]

    #text(font: code_font)[#content]
  ]
}
