*** Purpose: data preparation for gsoep analysis
*** Author: S Bauldry
*** Date: November 14, 2016

*** loading data prepared by Renee Ryberg
*** original file name: GSOEPclean_V5
use gsoep-data.dta, replace

*** additional data preparation
gen fem = (sex == 2)

gen west = (l1110205 == 1) if !mi(l1110205)

rename (agreeableness05 agreeableness09 conscientiousness05             ///
        conscientiousness09 extraversion05 extraversion09 neuroticism05 ///
		neuroticism09 openness05 openness09)                            ///
       (agr05 agr09 con05 con09 ext05 ext09 neu05 neu09 ope05 ope09)

rename (educ4cat05 educ4cat09) (edu05 edu09)

lab def ed 1 "no voc edu" 2 "apprentice" 3 "master/tech" 4 "university"
lab val edu05 edu09 ed

gen age05 = 2005 - gebjahr
gen age09 = 2009 - gebjahr

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

rename (vphrf zphrf) (wgt05 wgt09)

*** keeping variables for analysis and setting analysis samples
keep if west
keep if !mi(ped)

egen nm05 = rowmiss(age05 agr05 con05 ext05 neu05 ope05 edu05 wgt05)
gen sam05 = ( nm05 == 0 )

egen nm09 = rowmiss(age09 agr09 con09 ext09 neu09 ope09 edu09 wgt09)
gen sam09 = ( nm09 == 0 )

keep if sam05 | sam09

order ped fem west age05 agr05 con05 ext05 neu05 ope05 edu05 sam05 wgt05 ///
      age09 agr09 con09 ext09 neu09 ope09 edu09 sam09 wgt09

keep ped-wgt09

*** saving data for analysis
save gsoep-data, replace
