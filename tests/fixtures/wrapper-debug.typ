#import "@preview/fletcher:0.5.8": diagram, node, edge
#let w(..args) = context { diagram(..args) }
#w(
  node((0, 0), [A]),
  node((1, 0), [B]),
  edge((0, 0), (1, 0), "->"),
)
