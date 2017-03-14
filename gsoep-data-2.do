*** Purpose: data preparation for revised gsoep analysis
*** Author: S Bauldry
*** Date: March 14, 2017

*** loading data prepared by Renee Ryberg
use GSOEPclean_V6, replace

*** additional data preparation
gen fem = (sex == 2)
lab def s 0 "M" 1 "F"
lab val fem s

gen west = (l1110205 == 1) if !mi(l1110205)

rename (agreeableness05 conscientiousness05 extraversion05 neuroticism05  ///
		openness05 educ4cat15 stillineduc) (agr05 con05 ext05 neu05 ope05 ///
		edu15 inedu)
lab def ed 1 "none" 2 "app" 3 "tech" 4 "uni"
lab val edu15 ed

gen age05 = 2005 - gebjahr

gen fed = .
replace fed = 1 if vsbil < 7 & vbbil == 10
replace fed = 2 if vsbil < 6 & vbbil >= 20 & vbbil <= 25
replace fed = 3 if vsbil < 6 & vbbil >= 26 & vbbil <= 28
replace fed = 4 if vsbil < 6 & vbbil >= 30 & vbbil <= 32

gen med = .
replace med = 1 if msbil < 7 & mbbil == 10
replace med = 2 if msbil < 6 & mbbil >= 20 & mbbil <= 25
replace med = 3 if msbil < 6 & mbbil >= 26 & mbbil <= 28
replace med = 4 if msbil < 6 & mbbil >= 30 & mbbil <= 32

egen ped = rowmax(fed med)
lab var ped "parent education"   
lab val ped ed

rename (vphrf bfphrf) (wgt05 wgt15)

*** keeping variables for analysis and setting analysis sample
keep if from2005 == 1
dis _N

keep if wgt05 > 0
dis _N

keep if age05 <= 25
dis _N

keep if !mi(edu15)
dis _N

keep if !mi(agr05, con05, ext05, neu05, ope05, ped)
dis _N

*** saving data for analysis
keep edu15 ped fem west age05 agr05 con05 ext05 neu05 ope05 wgt05 wgt15
save gsoep-data-2, replace


