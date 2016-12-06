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
		qui mi est: reg `x' i.ped age if fem == `sex' & west == `reg' [pw = wgt05]
		mat b`x' = e(b_mi)
		mat v`x' = e(V_mi)
	}
	post pf (`sex') (`reg') (bagr05[1,2]) (vagr05[2,2]) ///
	                        (bagr05[1,3]) (vagr05[3,3]) ///
	                        (bagr05[1,4]) (vagr05[4,4]) ///
							(bcon05[1,2]) (vcon05[2,2]) ///
	                        (bcon05[1,3]) (vcon05[3,3]) ///
	                        (bcon05[1,4]) (vcon05[4,4]) ///
							(bext05[1,2]) (vext05[2,2]) ///
	                        (bext05[1,3]) (vext05[3,3]) ///
	                        (bext05[1,4]) (vext05[4,4]) ///
							(bneu05[1,2]) (vneu05[2,2]) ///
	                        (bneu05[1,3]) (vneu05[3,3]) ///
	                        (bneu05[1,4]) (vneu05[4,4]) ///
							(bope05[1,2]) (vope05[2,2]) ///
	                        (bope05[1,3]) (vope05[3,3]) ///
	                        (bope05[1,4]) (vope05[4,4]) 					
end

postutil clear
postfile pf sex reg b1 v1 b2 v2 b3 v3 b4 v4 b5 v5 b6 v6 b7 v7 b8 v8 ///
  b9 v9 b10 v10 b11 v11 b12 v12 b13 v13 b14 v14 b15 v15 using pp, replace
  
PerPed 1 1
PerPed 1 0
PerPed 0 1
PerPed 0 0

postclose pf

use pp, clear

gen id = _n
reshape long b v, i(id) j(est)
gen ub = b + 1.96*sqrt(v)
gen lb = b - 1.96*sqrt(v)

capture program drop PPGr
program PPGr
	args sex reg gn t
		graph twoway (scatter b est if  sex == `sex' & reg == `reg', ms(o))      ///
                     (rcap ub lb est if sex == `sex' & reg == `reg', lc(black)), ///
			         scheme(s1mono) ylab( , angle(h)) yline(0)            ///
			         xlab(1 "b1"  2 `""b2" "{bf: agr}"'  3 "b3"           ///
			              4 "b1"  5 `""b2" "{bf: con}"'  6 "b3"           ///
				          7 "b1"  8 `""b2" "{bf: ext}"'  9 "b3"           ///
				          10 "b1" 11 `""b2" "{bf: neu}"' 12 "b3"          ///
				          13 "b1" 14 `""b2" "{bf: ope}"' 15 "b3")         ///
			         legend(off) tit("`t'") xtit("") ytit("effect")       ///
					 ylab(-2(1)3) saving(`gn', replace)
end

PPGr 1 1 g1 "Female West Germany"
PPGr 1 0 g2 "Female East Germany"
PPGr 0 1 g3 "Male West Germany"
PPGr 0 0 g4 "Male East Germany"

graph combine g1.gph g2.gph g3.gph g4.gph, scheme(s1mono)



