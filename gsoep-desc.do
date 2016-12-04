*** Purpose: descriptives for gsoep analysis
*** Author: S Bauldry
*** Date: November 14, 2016

*** loading data
use gsoep-data-2, replace


*** missing data
tab ped, m
egen mp = rowmiss(agr05 con05 ext05 neu05 ope05)
recode mp (2 3 4 5 = 1)
tab mp


*** Distribution of respondent and parent education by sex and region
capture program drop EduG
program EduG
	args var sex reg tit gf
	
	preserve
	keep if fem == `sex' & west == `reg' & !mi(`var')
	local obs = _N
	gen frac = 1/`obs'
	graph bar (sum) frac, over(`var') scheme(s1mono) ylab(0(0.2).6, angle(h)) ///
      title("`tit'") ytit("% respondents") note("N = `obs'")  ///
      saving(`gf', replace)
	restore
end

EduG edu 1 1 "Female West Germany" g1
EduG edu 1 0 "Female East Germany" g2
EduG edu 0 1 "Male West Germany"   g3
EduG edu 0 0 "Male East Germany"   g4

graph combine g1.gph g2.gph g3.gph g4.gph, scheme(s1mono)


EduG ped 1 1 "Female West Germany" g1
EduG ped 1 0 "Female East Germany" g2
EduG ped 0 1 "Male West Germany"   g3
EduG ped 0 0 "Male East Germany"   g4

graph combine g1.gph g2.gph g3.gph g4.gph, scheme(s1mono)


*** Comparing distributions of parent education in original data and MI data
prop ped if fem & west
prop ped if fem & !west
prop ped if !fem & west
prop ped if !fem & !west

preserve
use gsoep-midata-2, replace
mi est: prop ped if fem & west
mi est: prop ped if fem & !west
mi est: prop ped if !fem & west
mi est: prop ped if !fem & !west
restore


*** Descriptives for personality measures
bysort fem west: sum agr05 con05 ext05 neu05 ope05


*** Age ranges
bysort fem west: sum age05

