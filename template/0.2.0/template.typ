#import "@preview/typsidian:0.0.3": *

#let normal_font = ("Libertinus Serif", "Noto Serif CJK SC")
#let code_font = ("FiraCode Nerd Font", "Alibaba PuHuiTi 3.0")
#let math_font = "New Computer Modern Math"

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

  #make-title(show-outline: false, show-author: true, justify: "center")

  #body
]
