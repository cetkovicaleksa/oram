#import "template/lib.typ": appendices, bibliography, thesis


#import sys.inputs.at("style", default: "thesis.style.typ") as style
#let meta = yaml(sys.inputs.at("meta", default: "thesis.yml"))


#show: thesis.with(
  physical: auto,
  ..meta,
  style: style,
  abstract: include "content/abstract.typ",
  bibliography: bibliography("thesis.bib"),
  bio: include "content/biography.typ",
  glossary: yaml("thesis.gls.yml"),
  glossary-links: true,
  glossary-all: true,

  en: (
    physical: auto,
    ..meta.en,
    abstract: include "content/abstract.en.typ",
  ),
)

= Увод

#lorem(100)

#show: appendices

= Додатак

#lorem(100)
