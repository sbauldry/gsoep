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
	
	qui regress `x' i.ped age fem west 
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
				 ytit("") xlab(-2(2)4) tit("`tit'") legend(off)             ///
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
graph export gsoep-2-figX1.pdf, replace
restore
  

*** Regress education on personality and parent education
eststo clear
postutil clear

postfile pf2 str3 md str3 dv iv es se using d2, replace

qui ologit edu agr con ext neu ope 
eststo m1edu
mat b1 = e(b)
mat v1 = e(V)

forval i = 1/5 {
	post pf2 ("m1") ("edu") (`i') (b1[1,`i']) (v1[`i',`i'])
}

qui ologit edu agr con ext neu ope i.ped age fem west 
eststo m2edu
mat b2 = e(b)
mat v2 = e(V)

forval i = 1/5 {
	post pf2 ("m2") ("edu") (`i') (b2[1,`i']) (v2[`i',`i'])
}

postclose pf2

esttab m1edu m2edu using gsoep-2-tab3.csv, replace b(%9.2f) se(%9.2f) ///
  stat(N r2) nonum nogap nobase
  
preserve
use d2
gen ub = es + 1.96*sqrt(se)
gen lb = es - 1.96*sqrt(se)
replace es = exp(es) if dv == "edu"
replace ub = exp(ub) if dv == "edu"
replace lb = exp(lb) if dv == "edu"

capture program drop GraphEst2
program GraphEst2
	args md dv tit sv xl xlb1 xlb2 xlb3
	
	graph twoway (rspike ub lb iv if dv == "`dv'" & md == "`md'", hor)      ///
				 (dot es iv if dv == "`dv'" & md == "`md'", hor msiz(small) ///
				  mc(black) ndot(1)), scheme(s1mono) tit("`tit'")           ///
                 ylab(1 "agr"  2 "con" 3 "ext" 4 "neu" 5 "ope", angle(h))   ///
		         xtit("estimate") xline(`xl', lp(shortdash))                ///
				 ytit("") legend(off) xlab(`xlb1'(`xlb2')`xlb3')            ///
				 saving(`sv', replace)
end

GraphEst2 m1 edu "Model 1" g1 1 0.8 0.1 1.2
GraphEst2 m2 edu "Model 2" g2 1 0.8 0.1 1.2
graph combine g1.gph g2.gph, scheme(s1mono) tit("Education")
graph export gsoep-2-figX2.pdf, replace
restore


*** Predicted levels of education
qui ologit edu agr con ext neu ope i.ped age fem west 
margins , at(neu = (3(2)21))
marginsplot , legend(rows(1) order(5 "N" 6 "A" 7 "T" 8 "U"))     ///
  ytit("predicted probability") xtit("neuroticism") tit("") scheme(s1mono) ///
  ylab( , angle(h)) saving(g1, replace)
  
margins , at(ope = (3(2)21))
marginsplot , legend(rows(1) order(5 "N" 6 "A" 7 "T" 8 "U"))     ///
  ytit("") xtit("openness") tit("") scheme(s1mono) ///
  ylab( , angle(h)) saving(g2, replace)
  
graph combine g1.gph g2.gph, scheme(s1mono)
graph export gsoep-2-figX3.pdf, replace


*** Interactions
* Check selected interactions
ologit edu age fem west i.ped agr con ext c.neu ope i.ped#c.neu
ologit edu age fem west i.ped agr con ext neu c.ope i.ped#c.ope

* Check all simultaneously with plots
ologit edu age fem west i.ped c.agr c.con c.ext c.neu c.ope ///
  i.ped#c.agr i.ped#c.con i.ped#c.ext i.ped#c.neu i.ped#c.ope

margins , at(agr = (3(1)21) ped = (1 4)) predict(outcome(4))
marginsplot, scheme(s1mono) ytit("pred prob uni")

margins , at(con = (3(1)21) ped = (1 4)) predict(outcome(4))
marginsplot, scheme(s1mono) ytit("pred prob uni")

margins , at(ext = (3(1)21) ped = (1 4)) predict(outcome(4))
marginsplot, scheme(s1mono) ytit("pred prob uni")

margins , at(neu = (3(1)21) ped = (1 4)) predict(outcome(4))
marginsplot, scheme(s1mono) ytit("pred prob uni")

margins , at(ope = (3(1)21) ped = (1 4)) predict(outcome(4))
marginsplot, scheme(s1mono) ytit("pred prob uni")



****** Auxiliary analysis ******
*** 1. restrict sample to ages 24 and younger
*** 2. stratify by sex
*** 3. stratify by region
*** 4. check income and occupational prestige
*** 5. check ability measures
*** 6. check mother's vs. father's education

eststo clear
postutil clear

postfile pf1 str3 aux str3 dv iv es se using d1, replace
foreach x of varlist agr con ext neu ope {	
	
	qui regress `x' i.ped age fem west if age < 24
	mat b = e(b)
	mat v = e(V)
	forval i = 2/4 {
		post pf1 ("age") ("`x'") (`i') (b[1,`i']) (v[`i',`i'])
	}
	
	qui regress `x' i.ped age west if fem == 0
	mat b = e(b)
	mat v = e(V)
	forval i = 2/4 {
		post pf1 ("mal") ("`x'") (`i') (b[1,`i']) (v[`i',`i'])
	}
	
	qui regress `x' i.ped age west if fem == 1
	mat b = e(b)
	mat v = e(V)
	forval i = 2/4 {
		post pf1 ("fem") ("`x'") (`i') (b[1,`i']) (v[`i',`i'])
	}
	
	qui regress `x' i.ped age fem if west == 0
	mat b = e(b)
	mat v = e(V)
	forval i = 2/4 {
		post pf1 ("eas") ("`x'") (`i') (b[1,`i']) (v[`i',`i'])
	}
	
	qui regress `x' i.ped age fem if west == 1
	mat b = e(b)
	mat v = e(V)
	forval i = 2/4 {
		post pf1 ("wst") ("`x'") (`i') (b[1,`i']) (v[`i',`i'])
	}
	
}
postclose pf1

preserve
use d1
gen ub = es + 1.96*sqrt(se)
gen lb = es - 1.96*sqrt(se)

capture program drop GraphEst1
program GraphEst1
	args aux dv tit sv
	
	graph twoway (rspike ub lb iv if dv == "`dv'" & aux == "`aux'", hor)    ///
				 (dot es iv if dv == "`dv'" & aux == "`aux'", hor           ///
				  msiz(small) mc(black) ndot(1)), scheme(s1mono)            ///
				 xline(0, lp(shortdash)) ytit("") xlab(-2(2)6) tit("`tit'") ///
                 ylab(2 "par edu: app"  3 "par edu: tech" 4 "par edu: uni"  ///
                      , angle(h))               ///
		         xtit("estimate") legend(off) saving(`sv', replace)
end

foreach x in age mal fem eas wst {
	GraphEst1 `x' agr Agreeableness g1
	GraphEst1 `x' con Consientiousness g2
	GraphEst1 `x' ext Extraversion g3
	GraphEst1 `x' neu Neuroticism g4
	GraphEst1 `x' ope Openness g5
	graph combine g1.gph g2.gph g3.gph g4.gph g5.gph, scheme(s1mono) tit("`x'")
	graph export gsoep-2-figX1-`x'.pdf, replace
}
restore



eststo clear
postutil clear

postfile pf2 str3 aux str3 dv iv es se using d2, replace

qui ologit edu agr con ext neu ope i.ped age fem west if age < 24 
mat b2 = e(b)
mat v2 = e(V)
forval i = 1/5 {
	post pf2 ("age") ("edu") (`i') (b2[1,`i']) (v2[`i',`i'])
}

qui ologit edu agr con ext neu ope i.ped age west if fem == 0
mat b2 = e(b)
mat v2 = e(V)
forval i = 1/5 {
	post pf2 ("mal") ("edu") (`i') (b2[1,`i']) (v2[`i',`i'])
}

qui ologit edu agr con ext neu ope i.ped age west if fem == 1
mat b2 = e(b)
mat v2 = e(V)
forval i = 1/5 {
	post pf2 ("fem") ("edu") (`i') (b2[1,`i']) (v2[`i',`i'])
}

qui ologit edu agr con ext neu ope i.ped age fem if west == 0
mat b2 = e(b)
mat v2 = e(V)
forval i = 1/5 {
	post pf2 ("eas") ("edu") (`i') (b2[1,`i']) (v2[`i',`i'])
}

qui ologit edu agr con ext neu ope i.ped age fem if west == 1
mat b2 = e(b)
mat v2 = e(V)
forval i = 1/5 {
	post pf2 ("wst") ("edu") (`i') (b2[1,`i']) (v2[`i',`i'])
}

postclose pf2


preserve
use d2
gen ub = es + 1.96*sqrt(se)
gen lb = es - 1.96*sqrt(se)
replace es = exp(es) if dv == "edu"
replace ub = exp(ub) if dv == "edu"
replace lb = exp(lb) if dv == "edu"

capture program drop GraphEst2
program GraphEst2
	args aux dv tit sv xl xlb1 xlb2 xlb3
	
	graph twoway (rspike ub lb iv if dv == "`dv'" & aux == "`aux'", hor)      ///
				 (dot es iv if dv == "`dv'" & aux == "`aux'", hor msiz(small) ///
				  mc(black) ndot(1)), scheme(s1mono) tit("`tit'")           ///
                 ylab(1 "agr"  2 "con" 3 "ext" 4 "neu" 5 "ope", angle(h))   ///
		         xtit("estimate") xline(`xl', lp(shortdash))                ///
				 ytit("") legend(off) xlab(`xlb1'(`xlb2')`xlb3')            ///
				 saving(`sv', replace)
end

foreach x in age mal fem eas wst {
	GraphEst2 `x' edu "`x'" g`x' 1 0.8 0.1 1.2
}
graph combine gage.gph gmal.gph gfem.gph geas.gph gwst.gph, scheme(s1mono)
graph export gsoep-2-figX2-aux.pdf, replace
restore


*** Regress income/prestige on personality and parent education
eststo clear
postutil clear

postfile pf2 str3 dv iv es se using d2, replace

qui regress inc agr con ext neu ope i.ped age fem west 
mat b2 = e(b)
mat v2 = e(V)
forval i = 1/5 {
	post pf2 ("inc") (`i') (b2[1,`i']) (v2[`i',`i'])
}

qui regress pst agr con ext neu ope i.ped age fem west 
mat b2 = e(b)
mat v2 = e(V)
forval i = 1/5 {
	post pf2 ("pst") (`i') (b2[1,`i']) (v2[`i',`i'])
}

postclose pf2

  
preserve
use d2
gen ub = es + 1.96*sqrt(se)
gen lb = es - 1.96*sqrt(se)

capture program drop GraphEst3
program GraphEst3
	args dv tit sv
	
	graph twoway (rspike ub lb iv if dv == "`dv'" , hor)                    ///
				 (dot es iv if dv == "`dv'", hor msiz(small)                ///
				  mc(black) ndot(1)), scheme(s1mono) tit("`tit'")           ///
                 ylab(1 "agr"  2 "con" 3 "ext" 4 "neu" 5 "ope", angle(h))   ///
		         xtit("estimate") xline(0, lp(shortdash))                   ///
				 ytit("") legend(off) saving(`sv', replace)
end

GraphEst3 inc "Income"   g1 1 
GraphEst3 pst "Prestige" g2 1 
graph combine g1.gph g2.gph, scheme(s1mono)
graph export gsoep-2-figX2-aux2.pdf, replace
restore


*** Regress education on personality and parent education adjusting for ability
ologit edu agr con ext neu ope i.ped age fem west if !mi(ani)
ologit edu agr con ext neu ope i.ped age fem west ani num 


*** Separating mother's and father's education
keep if !mi(fed, med)
tab fed fem
tab med fem

eststo clear
postutil clear

postfile pf1 md str3 dv iv es se using d1, replace
foreach x of varlist agr con ext neu ope {	
	
	qui regress `x' i.fed i.med age fem west 
	mat b = e(b)
	mat v = e(V)
	forval i = 2/8 {
		post pf1 (1) ("`x'") (`i') (b[1,`i']) (v[`i',`i'])
	}
	
	qui regress `x' i.fed i.med age west if fem == 0
	mat b = e(b)
	mat v = e(V)
	forval i = 2/8 {
		post pf1 (2) ("`x'") (`i') (b[1,`i']) (v[`i',`i'])
	}
	
	qui regress `x' i.fed i.med age west if fem == 1
	mat b = e(b)
	mat v = e(V)
	forval i = 2/8 {
		post pf1 (3) ("`x'") (`i') (b[1,`i']) (v[`i',`i'])
	}
	
}
postclose pf1

preserve
use d1, replace
drop if iv == 5
gen ub = es + 1.96*sqrt(se)
gen lb = es - 1.96*sqrt(se)

capture program drop GraphEst4
program GraphEst4
	args md dv tit sv xl xlb1 xlb2 xlb3
	
	graph twoway (rspike ub lb iv if dv == "`dv'" & md == `md', hor)       ///
				 (dot es iv if dv == "`dv'" & md == `md', hor msiz(small)  ///
				  mc(black) ndot(1)), scheme(s1mono) tit("`tit'")          ///
                 ylab(2 "fat edu: app"  3 "fat edu: tech" 4 "fat edu: uni" ///
				      6 "mot edu: app"  7 "mot edu: tech" 8 "mot edu: uni" ///
                      , angle(h)) xtit("estimate") ytit("") legend(off)    ///
			     xline(`xl', lp(shortdash)) xlab(`xlb1'(`xlb2')`xlb3')     ///
				 saving(`sv', replace)
end

forval i = 1/3 {
	GraphEst4 `i' agr "Agreeableness" g1 0 -2 2 4
	GraphEst4 `i' con "Conscientiousness" g2 0 -2 2 4
	GraphEst4 `i' ext "Extraversion" g3 0 -2 2 4
	GraphEst4 `i' neu "Neuroticism" g4 0 -2 2 4
	GraphEst4 `i' ope "Openess" g5 0 -2 2 4
	graph combine g1.gph g2.gph g3.gph g4.gph g5.gph, scheme(s1mono) ///
	      tit("Model `i'")
	graph export ~/desktop/gsoep-2-figA`i'.pdf, replace
}
restore

ologit edu agr con ext neu ope i.fed i.med age fem west 

