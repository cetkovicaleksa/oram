#import "template/lib.typ": appendices, bibliography, thesis


#import sys.inputs.at("style", default: "thesis.style.typ") as style
#let meta = yaml(sys.inputs.at("meta", default: "thesis.yml"))


#show: thesis.with(
  duplex: "duplex" in sys.inputs,
  copy-for: sys.inputs.at("copy-for", default: none),
  cover-title: [
    Систем за приватну анализу графова над екстерно складиштеним \
    шифрованим подацима уз заштиту образаца приступа \
    примјеном ORAM механизма
  ],
  margin: if "spiral" in sys.inputs {
    (inside: 2.5cm, outside: 1.5cm, y: 2cm)
  } else {
    2cm // (x: 2cm, y: 2.5cm)
  },
  ..meta,
  style: style,
  abstract: [= Извод] + include "content/abstract.typ",
  bibliography: bibliography("thesis.bib"),
  bio: include "content/biography.typ",
  glossary: yaml("thesis.gls.yml"),
  glossary-links: true,
  glossary-all: true,
  url-footnotes: "no-url-footnotes" not in sys.inputs,

  en: (
    ..meta.en,
    abstract: [= Abstract] + include "content/abstract.en.typ",
  ),
)

= Увод

#lorem(100)

#show: appendices

= Додатак

#lorem(100)
