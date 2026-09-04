#import "template/lib.typ": style as default

#import default: *

#let cover(body) = {
  show: default.cover.with(
    fill: navy,
    text-fill: gold,
    body-font: "Minion 3",
    sans-font: "Minion 3 Display",
    title-size: 16.98pt,
  )

  show "ORAM": set text(lang: "en", region: "UK")
  show "ORAM": smallcaps[oram]

  set text(stylistic-set: (
    3, // cyrl trapezoid variants (д, л and derivates)
    // 5, // cyrl serbian/macedonian alternates // typst supports locale-based auto-swapping so no need to explicitly set (since text lang is sr)
  ))

  body
}
