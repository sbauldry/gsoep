*** Purpose: descriptives for gsoep analysis
*** Author: S Bauldry
*** Date: November 14, 2016

*** loading data
use gsoep-data-2.dta, replace


*** sex distribution
tab fem 


*** age distributions
tempfile g1 g2
hist age05 if sam05, by(fem, note("")) discrete xlab(20(20)100) ///
  ylab(, angle(h)) xtit("age in 2005") scheme(s2mono) saving(`g1', replace) 
  
hist age09 if sam09, by(fem, note("")) discrete xlab(20(20)100) ///
  ylab(, angle(h)) xtit("age in 2009") scheme(s2mono) saving(`g2', replace) 
  
graph combine "`g1'" "`g2'", scheme(s2mono)
  

*** transition tables
tab ped edu05 if sam05
tab ped edu09 if sam09


*** personality distributions
tempfile gagr gcon gext gneu gope
foreach x in agr con ext neu ope {
	hist `x'05 if sam05, by(fem, note("")) discrete ylab(, angle(h)) ///
      xtit("`x' in 2005") scheme(s2mono) saving(`g`x'', replace) 
}
graph combine "`gagr'" "`gcon'" "`gext'" "`gneu'" "`gope'", scheme(s2mono)

tempfile gagr gcon gext gneu gope
foreach x in agr con ext neu ope {
	hist `x'09 if sam09, by(fem, note("")) discrete ylab(, angle(h)) ///
      xtit("`x' in 2009") scheme(s2mono) saving(`g`x'', replace) 
}
graph combine "`gagr'" "`gcon'" "`gext'" "`gneu'" "`gope'", scheme(s2mono)

