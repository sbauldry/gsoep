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


*** Descriptives for Table X1
mi est: prop edu [pw = wgt05] if fem == 1 & west == 1
mi est: prop edu [pw = wgt05] if fem == 1 & west == 0
mi est: prop edu [pw = wgt05] if fem == 0 & west == 1
mi est: prop edu [pw = wgt05] if fem == 0 & west == 0

mi est: prop ped [pw = wgt05] if fem == 1 & west == 1
mi est: prop ped [pw = wgt05] if fem == 1 & west == 0
mi est: prop ped [pw = wgt05] if fem == 0 & west == 1
mi est: prop ped [pw = wgt05] if fem == 0 & west == 0

foreach x of varlist age05 agr05 con05 ext05 neu05 ope05 {
	forval i = 0/1 {
		forval j = 0/1 {
			qui mi est: mean `x' [pw = wgt05] if fem == `i' & west == `j'
			mat b = e(b_mi)
			local `x'`i'`j' = b[1,1]

			forval m = 1/20 {
				qui sum `x' if _mi_m == `m' & fem == `i' & west == `j'
				local sd`m' = r(sd)
			}
			local `x's`i'`j' = (`sd1'  + `sd2'  + `sd3'  + `sd4'  + `sd5'  + ///
			                    `sd6'  + `sd7'  + `sd8'  + `sd9'  + `sd10' + ///
								`sd11' + `sd12' + `sd13' + `sd14' + `sd15' + ///
								`sd16' + `sd17' + `sd18' + `sd19' + `sd20')/20
		}
	}

	dis "`x': " as res %5.2f ``x'11' "  " as res %5.2f ``x's11' "  " ///
	            as res %5.2f ``x'10' "  " as res %5.2f ``x's10' "  " ///
				as res %5.2f ``x'01' "  " as res %5.2f ``x's01' "  " ///
				as res %5.2f ``x'00' "  " as res %5.2f ``x's00' 
}



