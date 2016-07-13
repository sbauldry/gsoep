*** Purpose: descriptives and preliminary gsoep analysis
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
rename (educ4cat09 autono09 living1) (edu09 aut09 liv1)

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
keep edu09 emp09 inc09 aut09 mps09 agr05 con05 ext05 neu05 ope05 age09 ///
     female ped liv1 zbula nation05

* age 25 to 65 in 2009
dis _N
drop if mi(age09)
drop if age09 < 25 | age09 > 65
dis _N

tempvar m1 m2 m3 m4 m5
egen `m1' = rownonmiss(edu09 emp09)
tab `m1' 

egen `m2' = rownonmiss(inc09 mps09 aut09)
tab `m2'

egen `m3' = rownonmiss(agr05 con05 ext05 neu05 ope05)
tab `m3'

tab `m3' if `m1' == 2

tab ped
tab liv1
tab zbula
tab nation05

egen `m4' = rownonmiss(edu09 emp09 agr05 con05 ext05 neu05 ope05 ped)
tab `m4'

egen `m5' = rownonmiss(inc09 mps09 aut09 agr05 con05 ext05 neu05 ope05 ped)
tab `m5'

keep if `m4' == 8


*** socioeconomic measures
sum edu09 emp09 inc09 mps09 aut09 ped

tempfile g1 g2 g3 g4 g5 g6
tempvar eduf empf pedf
qui sum edu09
gen `eduf' = 1/r(N)
graph hbar (sum) `eduf', over(edu09) scheme(lean2) ytit("pr respondents") ///
   tit("education") saving(`g1', replace)
   
qui sum emp09
gen `empf' = 1/r(N)
graph hbar (sum) `empf', over(emp09) scheme(lean2) ytit("pr respondents") ///
  tit("employment status") saving(`g2', replace)
  
hist inc09, scheme(lean2) xtit("log income") tit("income") saving(`g3', replace)

hist mps09, scheme(lean2) xtit("prestige") tit("prestige") saving(`g4', replace)

hist aut09, scheme(lean2) discrete xtit("autonomy") tit("autonomy") ///
  saving(`g5', replace)
  
qui sum ped
gen `pedf' = 1/r(N)
graph hbar (sum) `pedf', over(ped) scheme(lean2) ytit("pr respondents") ///
  tit("parent education") saving(`g6', replace)

graph combine "`g1'" "`g2'" "`g3'" "`g4'" "`g5'" "`g6'", scheme(lean2)
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

corr agr05 con05 ext05 neu05 ope05


*** parent education and personality
eststo clear
foreach x of varlist agr05 con05 ext05 neu05 ope05 {
	regress `x' age09 female ped, vce(robust)
	eststo `x'_1
	
	regress `x' age09 female i.ped, vce(robust)
	eststo `x'_2
}
esttab agr05_1 agr05_2 con05_1 con05_2 , b(%5.2f) star compress nogaps not
esttab ext05_1 ext05_2 neu05_1 neu05_2 , b(%5.2f) star compress nogaps not
esttab ope05_1 ope05_2 , b(%5.2f) star compress nogaps not


*** parent education, personality, and socioeconomic attainments
eststo clear
qui ologit edu09 age09 female ped agr05 con05 ext05 neu05 ope05, vce(robust)
eststo m1

qui ologit edu09 age09 female i.ped agr05 con05 ext05 neu05 ope05, vce(robust)
eststo m2

qui mlogit emp09 age09 female ped agr05 con05 ext05 neu05 ope05,  ///
  vce(robust) b(1)
eststo m3

qui mlogit emp09 age09 female i.ped agr05 con05 ext05 neu05 ope05, ///
  vce(robust) b(1)
eststo m4

esttab m1 m2 m3 m4, b(%5.2f) star compress nogaps not eform wide


eststo clear
foreach x of varlist inc09 mps09 aut09 {
	qui regress `x' age09 female ped agr05 con05 ext05 neu05 ope05, vce(robust)
	eststo `x'_1
	
	qui regress `x' age09 female i.ped agr05 con05 ext05 neu05 ope05, ///
	  vce(robust)
	eststo `x'_2
}
esttab inc09_1 inc09_2 mps09_1 mps09_2 , b(%5.2f) star compress nogaps not
esttab aut09_1 aut09_2 , b(%5.2f) star compress nogaps not

