*** Purpose: analysis of stability of personality traits by age
*** Author: S Bauldry
*** Date: September 8, 2016

*** loading data
use gsoep-data-2.dta, replace

*** looping through ages and storing correlation coefficients
tempfile pf1
postutil clear
postfile pf age agr con ext ope neu using `pf1', replace

forval i = 25/65 {
	foreach x in agr con ext ope neu {
		qui cor `x'05 `x'09 if age09 == `i'
		local r`x' = r(rho)
	}
	post pf (`i') (`ragr') (`rcon') (`rext') (`rope') (`rneu')
}

postclose pf

preserve
use `pf1', replace

tempfile g1 g2 g3 g4 g5
graph twoway (scatter agr age, msymbol(Oh)) (lowess agr age), scheme(s1mono) ///
  ytit("correlation 05/09") ylab(0.35(0.1).75, angle(horizontal) grid)       ///
  xlab(25(10)65) tit("agreeableness") legend(off) saving(`g1', replace)      ///
  text(.35 30 "{bf:r = 0.53}") 
  
graph twoway (scatter con age, msymbol(Oh)) (lowess con age), scheme(s1mono) ///
  ytit("correlation 05/09") ylab(0.35(0.1).75, angle(horizontal) grid)       ///
  xlab(25(10)65) tit("conscientiousness") legend(off) saving(`g2', replace)  ///
  text(.35 30 "{bf:r = 0.53}") 
  
graph twoway (scatter ext age, msymbol(Oh)) (lowess ext age), scheme(s1mono) ///
  ytit("correlation 05/09") ylab(0.35(0.1).75, angle(horizontal) grid)       ///
  xlab(25(10)65) tit("extraversion") legend(off) saving(`g3', replace)       ///
  text(.35 30 "{bf:r = 0.62}") 
  
graph twoway (scatter ope age, msymbol(Oh)) (lowess ope age), scheme(s1mono) ///
  ytit("correlation 05/09") ylab(0.35(0.1).75, angle(horizontal) grid)       ///
  xlab(25(10)65) tit("openness") legend(off) saving(`g4', replace)           ///
  text(.35 30 "{bf:r = 0.59}") 
  
graph twoway (scatter neu age, msymbol(Oh)) (lowess neu age), scheme(s1mono) ///
  ytit("correlation 05/09") ylab(0.35(0.1).75, angle(horizontal) grid)       ///
  xlab(25(10)65) tit("neuroticism") legend(off) saving(`g5', replace)        ///
  text(.35 30 "{bf:r = 0.58}") 

graph combine "`g1'" "`g2'" "`g3'" "`g5'" "`g4'", scheme(s1mono)
graph export gsoep-memo-2-fig2.pdf, replace
restore
