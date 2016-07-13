*** Purpose: prepare descriptives for gsoep analysis
*** Author: S Bauldry
*** Date: July 11, 2016

*** loading data prepared by Renee
*** original file name: GSOEPclean_V2
*** do file for data creation: Data set creation_3.25.16
use gsoep-data.dta, replace


*** additional data preparation
gen female = (sex == 2)
rename (agreeableness05 agreeableness09 conscientiousness05             ///
        conscientiousness09 extraversion05 extraversion09 neuroticism05 ///
		neuroticism09 openness05 openness09)                            ///
       (agr05 agr09 con05 con09 ext05 ext09 neu05 neu09 ope05 ope09)
rename (educ4cat09 autono09) (edu09 aut09)

recode emplst09 (1 = 3) (2 = 2) (3 4 5 6 = 1), gen(emp09)
lab var emp09 "employment status"
lab def em 1 "not PT/FT" 2 "PT" 3 "FT"
lab val emp09 em

gen inc09 = ln(labgro09)
lab var inc09 "logged gross income from labor"

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

*** setting analysis sample and keeping analysis variables
keep if !mi(agr05, con05, ext05, neu05, ope05)
keep if age09 >= 25 & age09 <= 65
keep edu09 emp09 inc09 aut09 mps09 agr05 con05 ext05 neu05 ope05 age09 ///
     female ped 

*** outcomes
sum edu09 emp09 inc09 mps09 aut09

tempfile g1 g2 g3 g4 g5
tempvar eduf empf
qui sum edu09
gen `eduf' = 1/r(N)
graph hbar (sum) `eduf', over(edu09) scheme(lean2) ytit("% respondents") ///
   tit("education") saving(`g1', replace)
   
qui sum emp09
gen `empf' = 1/r(N)
graph hbar (sum) `empf', over(emp09) scheme(lean2) ytit("% respondents") ///
  tit("employment status") saving(`g2', replace)
  
hist inc09, scheme(lean2) xtit("log income") tit("income") saving(`g3', replace)

hist mps09, scheme(lean2) xtit("prestige") tit("prestige") saving(`g4', replace)

hist aut09, scheme(lean2) discrete xtit("autonomy") tit("autonomy") ///
  saving(`g5', replace)

graph combine "`g1'" "`g2'" "`g3'" "`g4'" "`g5'", scheme(lean2)
graph export gsoep-fig1.pdf, replace




*** personality measures
sum agr05 con05 ext05 neu05 ope05

tempfile g1 g2 g3 g4 g5
hist agr05, scheme(lean2) discrete tit("agreeableness") saving(`g1')
hist con05, scheme(lean2) discrete tit("conscientiousness") saving(`g2')
hist ext05, scheme(lean2) discrete tit("extraversion") saving(`g3')
hist neu05, scheme(lean2) discrete tit("neuroticism") saving(`g4')
hist ope05, scheme(lean2) discrete tit("openness") saving(`g5')

graph combine "`g1'" "`g2'" "`g3'" "`g4'" "`g5'", scheme(lean2)
graph export gsoep-fig2.pdf, replace



