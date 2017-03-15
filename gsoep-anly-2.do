*** Purpose: revised gsoep analysis
*** Author: S Bauldry
*** Date: March 15, 2016

*** loading data
use gsoep-data-2, replace


****** Main analysis ******

*** Regress personality dimensions on parent education
*** note: unweighted
eststo clear
foreach x of varlist agr05 con05 ext05 neu05 ope05 {
	regress `x' i.ped age fem west
	eststo m`x'
}

esttab magr05 mcon05 mext05 mneu05 mope05 using gsoep-2-tab2.csv, ///
  replace b(%9.2f) se(%9.2f) stat(N r2) nonum nogap nobase


*** Regress education on personality and parent education
ologit edu15 age05 fem west i.ped agr05 con05 ext05 neu05 ope05
margins , at(neu05 = (3(2)21))
marginsplot , legend(rows(1) order(5 "N" 6 "A" 7 "T" 8 "U"))     ///
  ytit("predicted probability") xtit("neuroticism") tit("") scheme(s1mono) ///
  ylab( ,angle(h)) saving(g1, replace)
  
margins , at(ope05 = (3(2)21))
marginsplot , legend(rows(1) order(5 "N" 6 "A" 7 "T" 8 "U"))     ///
  ytit("") xtit("openness") tit("") scheme(s1mono) ///
  ylab( ,angle(h)) saving(g2, replace)
  
graph combine g1.gph g2.gph, scheme(s1mono)
graph export gsoep-2-figX.pdf, replace


*** Interactions
* Check selected interactions
ologit edu15 age05 fem west i.ped agr05 con05 ext05 c.neu05 ope05 i.ped#c.neu05
ologit edu15 age05 fem west i.ped agr05 con05 ext05 neu05 c.ope05 i.ped#c.ope05

* Check all simultaneously with plots
ologit edu15 age05 fem west i.ped c.agr05 c.con05 c.ext05 c.neu05 c.ope05 ///
  i.ped#c.agr05 i.ped#c.con05 i.ped#c.ext05 i.ped#c.neu05 i.ped#c.ope05

margins , at(agr05 = (3(1)21) ped = (1 4)) predict(outcome(4))
marginsplot, scheme(s1mono) ytit("pred prob uni")

margins , at(con05 = (3(1)21) ped = (1 4)) predict(outcome(4))
marginsplot, scheme(s1mono) ytit("pred prob uni")

margins , at(ext05 = (3(1)21) ped = (1 4)) predict(outcome(4))
marginsplot, scheme(s1mono) ytit("pred prob uni")

margins , at(neu05 = (3(1)21) ped = (1 4)) predict(outcome(4))
marginsplot, scheme(s1mono) ytit("pred prob uni")

margins , at(ope05 = (3(1)21) ped = (1 4)) predict(outcome(4))
marginsplot, scheme(s1mono) ytit("pred prob uni")




****** Auxiliary analysis ******
