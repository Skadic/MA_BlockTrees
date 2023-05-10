#import "template.typ": sans-serif

#let theorem(body, numbered: true, supplement: [Theorem], title: none) = figure(
  kind: "theorem",
  supplement: supplement,
  numbering: if numbered { "1.1" },
  caption: title,
  body
)

#let definition(body, numbered: true, title: none) = theorem(
  numbered: numbered, 
  supplement: [Definition],
  title: title,
  body
)

#let example(body, numbered: true, title: none) = theorem(
  numbered: numbered, 
  supplement: [Example],
  title: title,
  body
)

#let todo(color: red, body) = box(width: 100%, inset: 0.5em, fill: color, radius: 0.2em,
  text(fill: white, font: sans-serif, [#strong( "TODO:") #body])
)