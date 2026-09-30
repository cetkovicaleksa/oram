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
  show: default.cover.with(
    body-size: 11pt,
    title-size: 14.494289pt,
    margin: if "spiral" in sys.inputs and "unspiral-cover" not in sys.inputs {
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
