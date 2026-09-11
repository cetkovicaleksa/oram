#import "template/lib.typ": style as default

#import default: *

#let form = default.form.with(
  body-size: 10pt,
)

#let form-heading(body) = {
  show: default.form-heading.with(
    body-size: 9.3pt,
  )

  show heading: set text(size: 1.4 * 10pt)

  body
}

#let cover(body) = {
  let body-size = 11pt

  show: default.cover.with(
    body-size: body-size,
    body-font: "Arial",
    sans-font: "Times New Roman",
    title-size: 16pt,
    margin: if "spiral" in sys.inputs {
      (inside: 2cm, outside: 1cm, y: 1.5cm)
    } else {
      1.5cm
    },
  )

  show title: set block(width: 100%, inset: (x: 3%))
  show title: set text(spacing: 99% + 0pt)

  show "Алекса Ћетковић": set text(size: 12pt)

  show "ORAM": smallcaps[oram]

  body
}

#let base(body, ..args) = {
  show: default.base.with(..args)

  show bibliography: set par(justify: false, spacing: 1em)
  show bibliography: it => {
    show regex("\[\d+\]"): set text(number-width: "tabular", number-type: "lining") // only way i could think of at the moment
    it
  }

  body
}
