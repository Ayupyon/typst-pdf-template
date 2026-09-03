#let normal_font = (
  "Libertinus Serif",
  "Noto Serif SC",
)
#let code_font = ("FiraCode Nerd Font", "Alibaba PuHuiTi 3.0")

#let conf(
  title: none,
  name: none,
  doc,
) = {
  set text(font: normal_font)
  set heading(numbering: "1.")
  show raw: set text(font: code_font)
  show raw.where(block: true): set block(
    fill: luma(240),
    inset: 1em,
    radius: 0.5em,
    width: 100%,
  )
  show link: underline
  show heading: set block(below: 1em)

  let heading = []
  if title != none {
    heading += text(20pt, title)
  }
  if name != none {
    heading += [#parbreak()]
    heading += [#name]
  }

  if heading != none {
    align(center)[
      #heading
    ]
  }
  doc
}

#let math_block(
  bg_color,
  title,
  description,
  content,
) = {
  let description = if description != "" [(#description)] else [#description]
  block(
    fill: bg_color,
    inset: 1em,
    radius: 0.5em,
    width: 100%,
  )[
    *#title #description*: #content
  ]
}

#let definition(
  description,
  content,
) = {
  math_block(
    rgb(0x7f, 0xdb, 0xff, 20%),
    "Definition",
    description,
    content,
  )
}

#let theorem(
  description,
  content,
) = {
  math_block(
    rgb(0x7f, 0xdb, 0xff, 20%),
    "Theorem",
    description,
    content,
  )
}

#let corollary(
  description,
  content,
) = {
  math_block(
    rgb(0x7f, 0xdb, 0xff, 20%),
    "Corollary",
    description,
    content,
  )
}

#let convention(
  description,
  content,
) = {
  math_block(
    rgb(0x00, 0x74, 0xd9, 20%),
    "Convention",
    description,
    content,
  )
}

#let pseudo_code(
  title,
  content,
) = {
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
    *#title*:

    #text(font: code_font)[#content]
  ]
}

#let aside(
  content,
) = {
  block(
    fill: rgb(0x7f, 0xdb, 0xff, 20%),
    inset: 1em,
    radius: 0.5em,
    width: 100%,
  )[
    #content
  ]
}

