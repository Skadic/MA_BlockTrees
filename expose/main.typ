#import "template.typ": *
#import "utils.typ": *
#show: ieee.with(
  title: "Parallel Block Tree Construction",
  author: "Etienne Palanga (201482)",
  examiners: ("Prof. Dr. Johannes Fischer", "Dr. Florian Kurpicz"),
  deadline: "November 2023",
  thesis-type: "Master Thesis",
  bibliography-file: "MA.bib",
)



#outline(
  indent: true,
)

#include "01_introduction.typ";
#include "02_preliminaries.typ";

#bibliography("MA.bib", title: text(10pt)[References], style: "ieee")
