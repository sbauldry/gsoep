*** Purpose: analysis for memo 3
*** Author: S Bauldry
*** Date: December 4, 2016

*** loading data
use gsoep-midata-2, replace

*** graphing main effects of parent education on personality 
capture program drop PerPed
program PerPed
	args sex reg
	foreach x of varlist ope05 neu05 ext05 con05 agr05 {
		mi est: reg `var' i.ped age if fem == `sex' & west == `reg'
		mat b`x' = e(b_mi)
		mat v`x' = e(V_mi)
	}
	post pf (`sex') (`reg') (b[1,2]) (v[2,2]) (b[1,3]) (v[3,3]) ///
	        (b[1,4]) (v[4,4])
end

postutil clear
postfile pf str10 sex reg b1 v1 b2 v2 b3 v3 b4 v4 b5 v5 b6 v6 b7 v7 b8 v8 ///
  b9 v9 b10 v10 b11 v11 b12 v12 b13 v13 b14 v14 b15 v15 using pp, replace
  
foreach x of varlist ope05 neu05 ext05 con05 agr05 {
	mi est: reg `x' i.ped 

foreach x of varlist agr05 con05 ext05 neu05 ope05 {
	PerPed `x' 1 1
	PerPed `x' 1 0
	PerPed `x' 0 1
	PerPed `x' 0 0
}

postclose pf

use `pp', clear

gen b15 = b1 if 


gen id = _n
reshape long b v ub lb, i(id) j(est)
drop id

gen b1 = b if per == "agr05"
gen 


forval i = 1/3 {
	gen ub`i' = b`i' + sqrt(v`i')*1.96
	gen lb`i' = b`i' - sqrt(v`i')*1.96
}

graph twoway rcap ub lb est if sex == 1 & reg == 1, by(per) horizontal
	
	
