*** Purpose: descriptives for gsoep analysis
*** Author: S Bauldry
*** Date: September 8, 2016

*** loading data
use gsoep-data-2.dta, replace


*** socioeconomic measures
qui tab edu09, gen(ed)
qui tab emp09, gen(em)
qui tab ped, gen(pe)

bysort female: sum ed1-ed4 em1-em3 lnnwg09 mps09 aut09 pe1-pe4


*** personality measures
lab def f 0 "male" 1 "female"
lab val female f
tempfile g1 g2 g3 g4 g5
hist agr05, scheme(lean2) by(female) discrete tit("agr") saving(`g1')
hist con05, scheme(lean2) by(female) discrete tit("con") saving(`g2')
hist ext05, scheme(lean2) by(female) discrete tit("ext") saving(`g3')
hist neu05, scheme(lean2) by(female) discrete tit("neu") saving(`g4')
hist ope05, scheme(lean2) by(female) discrete tit("ope") saving(`g5')
graph combine "`g1'" "`g2'" "`g3'" "`g4'" "`g5'", scheme(lean2)
graph export gsoep-memo-2-fig1.pdf, replace

