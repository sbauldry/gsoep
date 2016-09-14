*** Purpose: data preparation for gsoep analysis
*** Author: S Bauldry
*** Date: September 8, 2016

*** loading data prepared by Renee Ryberg
*** original file name: GSOEPclean_V4
*** do file for data creation: GSOEP data cleaning_9.8.16.do
use gsoep-data.dta, replace


*** additional data preparation
gen female = (sex == 2)

gen west = (l1110205 == 1) if !mi(l1110205)
desc l1110205

rename (agreeableness05 agreeableness09 conscientiousness05             ///
        conscientiousness09 extraversion05 extraversion09 neuroticism05 ///
		neuroticism09 openness05 openness09)                            ///
       (agr05 agr09 con05 con09 ext05 ext09 neu05 neu09 ope05 ope09)

rename (educ4cat09 autono09 e1110305) (edu09 aut09 emp09)

gen lnnwg09 = ln(hourlywage09_n + 1)
gen lngwg09 = ln(hourlywage09_g + 1)

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
lab def ed 1 "no voc edu"  2 "app training" 3 "master/tech" 4 "university"    
lab val ped ed
lab val edu09 ed

gen wgt = vphrf*wpbleib*xpbleib*ypbleib*zpbleib

*** setting analysis sample and keeping analysis variables
keep if from2005 == 1 & from2009 == 1
keep if age09 >= 25 & age09 <= 65
keep if west == 1
keep if !mi(ped)
keep if !mi(agr05, con05, ext05, neu05, ope05)

keep edu09 emp09 lnnwg09 lngwg09 aut09 mps09 agr05 con05 ext05 neu05 ope05 ///
     agr09 con09 ext09 neu09 ope09 age09 female ped wgt

*** saving data for analysis
save gsoep-data-2, replace
