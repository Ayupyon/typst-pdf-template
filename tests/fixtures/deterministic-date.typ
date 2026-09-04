#import "../../template/0.3.0/template.typ": conf

#show: conf.with(
  title: "Deterministic date",
  course: "Integration Test",
  author: "Ayupyon",
  date: datetime(year: 2026, month: 9, day: 4),
)

The explicit publication date above must not depend on the build day.
