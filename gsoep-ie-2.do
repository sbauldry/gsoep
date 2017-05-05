*** Purpose: creating figure for indirect effects
*** Author: S Bauldry
*** Date: April 21, 2017


*** entering results from Mplus
clear
input id str20 v es1 se1 es2 se2
1  "par edu: app -> agr"  -0.004 0.011 -0.006 0.021
2  "par edu: tech -> agr"  0.005 0.014  0.027 0.033
3  "par edu: uni -> agr"  -0.003 0.010 -0.001 0.022
5  "par edu: app -> con"  -0.004 0.020  0.039 0.058
6  "par edu: tech -> con" -0.002 0.011  0.097 0.071
7  "par edu: uni -> con"  -0.002 0.010  0.085 0.065
9  "par edu: app -> ext"  -0.004 0.014  0.005 0.040
10 "par edu: tech -> ext" -0.014 0.023 -0.017 0.044
11 "par edu: uni -> ext"  -0.015 0.022 -0.009 0.041
13 "par edu: app -> neu"   0.002 0.044  0.050 0.082
14 "par edu: tech -> neu" -0.006 0.049  0.023 0.089
15 "par edu: uni -> neu"   0.020 0.045  0.062 0.085
17 "par edu: app -> ope"   0.065 0.044  0.103 0.115
18 "par edu: tech -> ope"  0.106 0.059  0.189 0.128
19 "par edu: uni -> ope"   0.120 0.058  0.218 0.122
end

forval i = 1/2 {
	gen ub`i' = es`i' + 1.96*se`i'
	gen lb`i' = es`i' - 1.96*se`i'
	replace es`i' = exp(es`i')
	replace ub`i' = exp(ub`i')
	replace lb`i' = exp(lb`i')
}

graph twoway (rspike ub2 lb2 id, hor) ///
             (dot es2 id, hor msiz(small) mc(black) ndot(1)),               ///
			 scheme(s1mono) xline(1, lp(shortdash))                         ///
			 ytit("") xlab(0.8(0.2)1.6) tit("Secondary Degree") legend(off) ///
			 xtit("indirect effect estimate") ///
             ylab(1  "par edu: app -> agr"  ///
		          2  "par edu: tech -> agr" ///
                  3  "par edu: uni -> agr"  ///
                  5  "par edu: app -> con"  ///
                  6  "par edu: tech -> con" ///
                  7  "par edu: uni -> con"  ///
                  9  "par edu: app -> ext"  ///
                  10 "par edu: tech -> ext" ///
                  11 "par edu: uni -> ext"  ///
                  13 "par edu: app -> neu"  ///
                  14 "par edu: tech -> neu" ///
                  15 "par edu: uni -> neu"  ///
                  17 "par edu: app -> ope"  ///
                  18 "par edu: tech -> ope" ///
                  19 "par edu: uni -> ope", angle(h)) ///
			saving(g1, replace)
			
graph twoway (rspike ub1 lb1 id, hor) ///
             (dot es1 id, hor msiz(small) mc(black) ndot(1)),               ///
			 scheme(s1mono) xline(1, lp(shortdash))                         ///
			 ytit("") xlab(0.8(0.2)1.6) tit("Educational Attainment")       ///
			 xtit("indirect effect estimate") legend(off) ///
             ylab(1  "par edu: app -> agr"  ///
		          2  "par edu: tech -> agr" ///
                  3  "par edu: uni -> agr"  ///
                  5  "par edu: app -> con"  ///
                  6  "par edu: tech -> con" ///
                  7  "par edu: uni -> con"  ///
                  9  "par edu: app -> ext"  ///
                  10 "par edu: tech -> ext" ///
                  11 "par edu: uni -> ext"  ///
                  13 "par edu: app -> neu"  ///
                  14 "par edu: tech -> neu" ///
                  15 "par edu: uni -> neu"  ///
                  17 "par edu: app -> ope"  ///
                  18 "par edu: tech -> ope" ///
                  19 "par edu: uni -> ope", angle(h)) ///
			saving(g2, replace)

graph combine g1.gph g2.gph, scheme(s1mono)
graph export gsoep-2-fig4.pdf, replace
