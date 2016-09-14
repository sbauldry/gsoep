*** Purpose: descriptives for gsoep analysis
*** Author: S Bauldry
*** Date: September 8, 2016

*** loading data
use gsoep-data-2.dta, replace


*** socioeconomic measures
* just keeping values for wages, prestige, and autonomy for full-time workers
replace lnnwg09 = . if emp09 != 1
replace mps09   = . if emp09 != 1
replace aut09   = . if emp09 != 1

qui tab edu09, gen(ed)
qui tab emp09, gen(em)
qui tab ped, gen(pe)

bysort female: sum ed1-ed4 em1-em3 lnnwg09 mps09 aut09 pe1-pe4



tab female
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

