#let script-size = 7.75pt
#let footnote-size = 8.5pt
#let small-size = 10pt
#let normal-size = 11pt
#let large-size = 12pt

#let sans-serif = "DM Sans"
#let serif = "STIX Two Text"
#let monospace = "DM Mono"

#let tu-green = rgb(132, 184, 23)

#let ieee(
  // The paper's title.
  title: "Paper Title",

  author: none,
  deadline: none,

  // The paper's abstract. Can be omitted if you don't have one.
  abstract: none,

  // A list of index terms to display after the abstract.
  index-terms: (),

  // The article's paper size. Also affects the margins.
  paper-size: "us-letter",

  // The path to a bibliography file if you want to cite some external
  // works.
  bibliography-file: none,

  examiners: (),

  thesis-type: "Bachelor Thesis",

  // The paper's content.
  body
) = {
  // Set document metadata.
  set document(title: title, author: author)

  // Set the body font.
  set text(font: serif, size: normal-size)

  show link: it => {
    if type(it.dest) == "string" {
      underline[#text(font: monospace, it)]
    } else {
        it
    }
  }

  let section_title = state("section_title", [])

  // Configure the page.
  set page(
    paper: paper-size,
    margin: 1.75in,
    header: locate(loc => {
      let sec = counter(heading).at(loc).first(); 
      if sec > 0 {
        align(right, text(
          font: serif,
          size: large-size,
          weight: "semibold",
          style: "italic", 
          [Section #sec. #section_title.display()]
        ))
      }
      counter(footnote).update(0)
    }),
    footer: align(horizon, locate(loc => {
      // Centered page numbers
      let page_nr = counter(page).at(loc).first()
      align(center, text(size: script-size, [#page_nr]))
    })),
  )

  show footnote.entry: set text(size: footnote-size)

  show outline: it => box(inset: 3em, it)

  // Configure equation numbering and spacing.
  set math.equation(numbering: "(1)")
  show math.equation: set block(spacing: 0.65em)

  // Configure lists.
  set enum(indent: 10pt, body-indent: 9pt)
  set list(indent: 10pt, body-indent: 9pt)

  // Configure headings
  set heading(numbering: "1.1")
  show heading : it => locate(loc => {
    let c = counter(heading)
    set par(first-line-indent: 0em)
    text(font: sans-serif, {
      if not it.outlined {
        it
      } else if it.level == 1 {
        section_title.update(it.body)
        h(0.3em)
        box(
          fill: tu-green,
          outset: 0.3em,
          width: normal-size,
          height: normal-size,
          //baseline: 20%,
          radius: 10%,
          text(fill: white, {align(center + horizon, [#c.display()])})
        )  
        h(0.8em)
        it.body
      } else {
        c.display()
        h(0.8em)
        it.body
      }
    })
    if it.level == 1 {
      v(10pt)
    } else {
      v(5pt)
    }
    hide(it)
    v(-2em)
  }) 

  show figure: it => align(center, box(inset: (y: 1em), {
    it.body
    box(inset: (x: 1em), align(left, {
      text(font: sans-serif, [*#it.supplement #it.counter.display()*])
      [ ]
      [#it.caption]
    }))
  }))

  // Theorems
  show figure.where(kind: "theorem"): it => block(above: 11.5pt, below: 11.5pt, {
    show par: set block(spacing: 0.58em)
     
    //let head-counter = counter(heading).at(loc).first()
    //counter("theorem").step()
    //let theorem-counter = counter("theorem").at(loc).first()
    //it.counter.update((head-counter, theorem-counter))
    text(
      font: sans-serif,
      [
        #text(fill: rgb("666666"), baseline: -0.13em, [#sym.triangle.filled.r])
        #strong({
          [ ]
          it.supplement
          if it.numbering != none {
            [ ]
            it.counter.display(it.numbering)
          }
        })
      ]
    )
    
    if it.caption != none {
      [ (#it.caption)]
    }
    h(5pt)
    emph(it.body)
  })


  grid(
    columns: (50%, 50%),
    rows: 1,
    image("gfx/tu_logo_pdf.svg", height: 2em),
    align(right, image("gfx/fi_logo_pdf.svg", height: 2em))
  )

  // Display the paper's title.
  v(5em)
  align(center, [
    #thesis-type \ #v(5pt)
    #text(18pt, title)
    #v(2em, weak: true)
    #if author != none [
      #text(large-size, author) #linebreak()
    ]
    #if deadline != none [
      #deadline #linebreak()
    ]
  ])

  v(40pt, weak: true)
  
  align(bottom, {
    set par(first-line-indent: 0em)
    strong([Examiners:])
    linebreak()
    for examiner in examiners [
      #emph(examiner) \
    ]
    v(3em)
    [
      Technische Universität Dortmund \
      Department of Computer Science \
      Algorithm Engineering (LS-11) \
      #text(size: small-size, link("https://ls11-www.cs.tu-dortmund.de"))
    ]
  })
  
  pagebreak()


  // Start two column mode and configure paragraph properties.
  //show: columns.with(2, gutter: 12pt)
  set par(justify: true, first-line-indent: 1em)
  //show par: set block(spacing: 0.65em)

  // Display abstract and index terms.
  if abstract != none [
    #set text(weight: 700)
    #h(1em) _Abstract_---#abstract

    #if index-terms != () [
      #h(1em)_Index terms_---#index-terms.join(", ")
    ]
    #v(2pt)
  ]

  // Display the paper's contents.
  body

  // Display bibliography.
  if bibliography-file != none {
    show bibliography: set text(8pt)
    set heading(outlined: false)
    pagebreak(weak: true)
    bibliography(bibliography-file, title: text(10pt)[References], style: "ieee")
  }
}
