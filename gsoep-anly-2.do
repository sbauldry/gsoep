*** Purpose: revised gsoep analysis
*** Author: S Bauldry
*** Date: March 15, 2016

*** loading data
use gsoep-data-2, replace

****** Primary Analysis ******

*** Regress personality dimensions on parent education
eststo clear
postutil clear

postfile pf1 str3 dv iv es se using d1, replace
foreach x of varlist agr con ext neu ope {	
	
	qui regress `x' i.ped age fem west [pw = wgt]
	eststo m`x'
	
	mat b = e(b)
	mat v = e(V)
	forval i = 2/7 {
		post pf1 ("`x'") (`i') (b[1,`i']) (v[`i',`i'])
	}
	
}
postclose pf1

esttab magr mcon mext mneu mope using gsoep-2-tab2.csv, replace b(%9.2f) ///
  se(%9.2f) stat(N r2) nonum nogap nobase

preserve
use d1
gen ub = es + 1.96*sqrt(se)
gen lb = es - 1.96*sqrt(se)

capture program drop GraphEst1
program GraphEst1
	args dv tit sv
	
	graph twoway (rspike ub lb iv if dv == "`dv'", hor)                     ///
				 (dot es iv if dv == "`dv'", hor msiz(small) mc(black)      ///
				  ndot(1)), scheme(s1mono) xline(0, lp(shortdash))          ///
				 ytit("") xlab(-2(2)6) tit("`tit'") legend(off)             ///
                 ylab(2 "par edu: app"  3 "par edu: tech" 4 "par edu: uni"  ///
                      5 "age" 6 "female"  7 "west", angle(h))               ///
		         xtit("estimate") saving(`sv', replace)
end

GraphEst1 agr Agreeableness g1
GraphEst1 con Consientiousness g2
GraphEst1 ext Extraversion g3
GraphEst1 neu Neuroticism g4
GraphEst1 ope Openness g5

graph combine g1.gph g2.gph g3.gph g4.gph g5.gph, scheme(s1mono)
graph export figX1.pdf, replace
restore
  

*** Regress outcomes on personality and parent education
eststo clear
postutil clear

postfile pf2 str3 md str3 dv iv es se using d2, replace

ologit edu agr con ext neu ope [pw = wgt]
eststo m1edu
mat b1 = e(b)
mat v1 = e(V)

forval i = 1/5 {
	post pf2 ("m1") ("edu") (`i') (b1[1,`i']) (v1[`i',`i'])
}

ologit edu agr con ext neu ope age fem west i.ped [pw = wgt]
eststo m2edu
mat b2 = e(b)
mat v2 = e(V)

forval i = 1/5 {
	post pf2 ("m2") ("edu") (`i') (b2[1,`i']) (v2[`i',`i'])
}

regress inc agr con ext neu ope [pw = wgt]
eststo m1inc
mat b1 = e(b)
mat v1 = e(V)

forval i = 1/5 {
	post pf2 ("m1") ("inc") (`i') (b1[1,`i']) (v1[`i',`i'])
}

regress inc agr con ext neu ope age fem west i.ped [pw = wgt]
eststo m2inc
mat b2 = e(b)
mat v2 = e(V)

forval i = 1/5 {
	post pf2 ("m2") ("inc") (`i') (b2[1,`i']) (v2[`i',`i'])
}

postclose pf2

esttab m1edu m2edu m1inc m2inc using gsoep-2-tab3.csv, replace b(%9.2f) ///
  se(%9.2f) stat(N r2) nonum nogap nobase
  
 
  
  
  
  
  
  
  
*** Regress outcomes on personality and parent education
eststo clear
ologit edu age fem west i.ped agr con ext neu ope
eststo m1edu

ologit edu age fem west i.ped agr con ext neu ope [pw = wgt]
eststo m2edu

foreach x of varlist inc pst {
	regress `x' age fem west i.ped agr con ext neu ope
	eststo m1`x'
	
	regress `x' age fem west i.ped agr con ext neu ope [pw = wgt]
	eststo m2`x'
}
esttab m1edu m2edu m1inc m2inc m1pst m2pst using gsoep-2-tab3.csv, ///
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

*** 1. restrict sample to ages 24 and lower
eststo clear
foreach x of varlist agr05 con05 ext05 neu05 ope05 {
	regress `x' i.ped age fem west if age < 25
	eststo m`x'
}

esttab magr05 mcon05 mext05 mneu05 mope05, ///
  replace b(%9.2f) se(%9.2f) stat(N r2) nonum nogap nobase
  
ologit edu15 age05 fem west i.ped agr05 con05 ext05 neu05 ope05 if age < 25


*** 2. stratify by sex
* male
eststo clear
foreach x of varlist agr05 con05 ext05 neu05 ope05 {
	regress `x' i.ped age west if fem == 0
	eststo m`x'
}

esttab magr05 mcon05 mext05 mneu05 mope05, ///
  replace b(%9.2f) se(%9.2f) stat(N r2) nonum nogap nobase
  
ologit edu15 age05 west i.ped agr05 con05 ext05 neu05 ope05 if fem == 0

* female
eststo clear
foreach x of varlist agr05 con05 ext05 neu05 ope05 {
	regress `x' i.ped age west if fem == 1
	eststo m`x'
}

esttab magr05 mcon05 mext05 mneu05 mope05, ///
  replace b(%9.2f) se(%9.2f) stat(N r2) nonum nogap nobase
  
ologit edu15 age05 west i.ped agr05 con05 ext05 neu05 ope05 if fem == 1


*** 3. stratify by region
* west
eststo clear
foreach x of varlist agr05 con05 ext05 neu05 ope05 {
	regress `x' i.ped age fem if west == 1
	eststo m`x'
}

esttab magr05 mcon05 mext05 mneu05 mope05, ///
  replace b(%9.2f) se(%9.2f) stat(N r2) nonum nogap nobase
  
ologit edu15 age05 fem i.ped agr05 con05 ext05 neu05 ope05 if west == 1

* east
eststo clear
foreach x of varlist agr05 con05 ext05 neu05 ope05 {
	regress `x' i.ped age fem if west == 0
	eststo m`x'
}

esttab magr05 mcon05 mext05 mneu05 mope05, ///
  replace b(%9.2f) se(%9.2f) stat(N r2) nonum nogap nobase
  
ologit edu15 age05 fem i.ped agr05 con05 ext05 neu05 ope05 if west == 0
