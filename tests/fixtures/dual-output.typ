#import "../../template/0.3.0/template.typ": (
  with-rin-rules,
  definition,
  theorem,
  lemma,
  proof,
  diagram,
  node,
  edge,
)

#show: with-rin-rules

= First section

Forward reference: @second-theorem.

#definition(topic: [Group])[
  A group is a set with an associative operation, an identity, and inverses.
] <group-definition>

#theorem(topic: [Identity])[
  A group has a unique identity element.

  #proof[Suppose $e$ and $e'$ are identities. Then $e = e e' = e'$.]
] <first-theorem>

#theorem[
  Inverses in a group are unique.
] <inverse-theorem>

#lemma[
  For every group element $a$, $(a^(-1))^(-1) = a$.
] <first-lemma>

= Second section

#theorem(topic: [Cancellation])[
  If $a b = a c$, then $b = c$.
] <second-theorem>

#lemma[
  Left multiplication by a fixed group element is injective.
] <second-lemma>

#theorem(label: [定理], topic: [局部化])[
  The visible kind label can be localized by the consuming blog.

  #proof(label: [证明。])[The localized proof remains unnumbered.]
] <localized-theorem>

Backward references: @first-theorem, @inverse-theorem, @group-definition,
@first-lemma, @second-lemma, and @localized-theorem.

#diagram(
  node((0, 0), [A]),
  node((1, 0), [B]),
  node((1, 1), [C]),
  edge((0, 0), (1, 0), "->"),
  edge((1, 0), (1, 1), "->"),
  edge((0, 0), (1, 1), "->"),
  alt: "A commutative triangle with arrows from A to B, B to C, and A to C",
  caption: [A commutative triangle.],
)
