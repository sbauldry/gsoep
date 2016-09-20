*** Purpose: moderated mediation analysis
*** Author: S Bauldry
*** Date: September 19, 2016

*** loading data
use gsoep-data-2.dta, replace


*** Associations between parent education and personality dimensions
eststo clear
foreach x of varlist agr05 con05 ext05 neu05 ope05 {
	forval i = 0/1 {
		regress `x' i.ped if female == `i' [pw = wgt], vce(robust)
		eststo `x'`i'
	}
}

esttab agr051 con051 ext051 neu051 ope051 using table11.csv, ///
  replace b(%9.3f) se(%9.3f) stats(N r2)

esttab agr050 con050 ext050 neu050 ope050 using table10.csv, ///
  replace b(%9.3f) se(%9.3f) stats(N r2)

  
  
*** Associations between parent education, personality, and adult attainments
eststo clear
forval i = 0/1 {
	ologit edu09 agr05 con05 ext05 neu05 ope05 i.ped if female == `i' ///
	       [pw = wgt], vce(robust)
	eststo edu`i'
	
	reg lnnwg09 agr05 con05 ext05 neu05 ope05 i.ped if female == `i' ///
	    [pw = wgt], vce(robust)
    eststo wag`i'
	
	reg mps09 agr05 con05 ext05 neu05 ope05 i.ped if female == `i' ///
	    [pw = wgt], vce(robust)
    eststo mps`i'

	reg aut09 agr05 con05 ext05 neu05 ope05 i.ped if female == `i' ///
	    [pw = wgt], vce(robust)
    eststo aut`i'
}

esttab edu1 wag1 mps1 aut1 using table41.csv, replace b(%9.3f) se(%9.3f) ///
  stats(N r2)
  
esttab edu0 wag0 mps0 aut0 using table40.csv, replace b(%9.3f) se(%9.3f) ///
  stats(N r2)
  

* Checking interactions for significant main effects
ologit edu09 agr05 con05 ext05 c.neu05 ope05 i.ped c.neu05#i.ped ///
  if female == 1 [pw = wgt], vce(robust)

ologit edu09 agr05 con05 ext05 c.neu05 c.ope05 i.ped c.ope05#i.ped ///
  if female == 1 [pw = wgt], vce(robust)

ologit edu09 agr05 con05 ext05 c.neu05 ope05 i.ped c.neu05#i.ped ///
  if female == 0 [pw = wgt], vce(robust)

ologit edu09 agr05 con05 ext05 c.neu05 c.ope05 i.ped c.ope05#i.ped ///
  if female == 0 [pw = wgt], vce(robust)
  
reg aut09 agr05 con05 ext05 c.neu05 ope05 i.ped c.neu05#i.ped ///
  if female == 0 [pw = wgt], vce(robust)

reg aut09 agr05 con05 ext05 c.neu05 c.ope05 i.ped c.ope05#i.ped ///
  if female == 0 [pw = wgt], vce(robust)
  
reg lnnwg09 c.agr05 con05 ext05 c.neu05 c.ope05 i.ped c.agr05#i.ped ///
  if female == 0 [pw = wgt], vce(robust)
  


