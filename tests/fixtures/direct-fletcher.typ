#import "@preview/fletcher:0.5.8": diagram, node, edge
#diagram(
  node((0, 0), [A]),
  node((1, 0), [B]),
  node((1, 1), [C]),
  edge((0, 0), (1, 0), "->"),
  edge((1, 0), (1, 1), "->"),
  edge((0, 0), (1, 1), "->"),
)
