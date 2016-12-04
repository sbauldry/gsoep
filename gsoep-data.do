*** Purpose: data preparation for gsoep analysis
*** Author: S Bauldry
*** Date: November 14, 2016

*** loading data prepared by Renee Ryberg
*** original file name: GSOEPclean_V5
use gsoep-data.dta, replace

*** additional data preparation
gen fem = (sex == 2)
lab def s 0 "M" 1 "F"
lab val fem s

gen west = (l1110205 == 1) if !mi(l1110205)

rename (agreeableness05 agreeableness09 conscientiousness05             ///
        conscientiousness09 extraversion05 extraversion09 neuroticism05 ///
		neuroticism09 openness05 openness09)                            ///
       (agr05 agr09 con05 con09 ext05 ext09 neu05 neu09 ope05 ope09)

rename (educ4cat05 educ4cat09) (edu05 edu09)

lab def ed 1 "none" 2 "app" 3 "tech" 4 "uni"
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

*** keeping variables for analysis and setting analysis sample
keep if from2005 == 1
dis _N

keep if age05 >= 25
dis _N

keep if !mi(edu05)
dis _N

*** saving data for analysis
keep edu05 ped fem west age05 agr05 con05 ext05 neu05 ope05 wgt05
save gsoep-data-2, replace


*** running multiple imputation
mi set flong
mi reg imp ped agr05 con05 ext05 neu05 ope05
mi imp chain (ologit) ped (regress) agr05 con05 ext05 neu05 ope05 = age05 ///
             i.edu05, by(west fem) add(20) rseed(16629829)
save gsoep-midata-2, replace		 
