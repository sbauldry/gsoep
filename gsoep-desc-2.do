*** Purpose: descriptives for for revised gsoep analysis
*** Author: S Bauldry
*** Date: March 14, 2016

*** loading data
use gsoep-data-2, replace

****** Unweighted descriptives ******
*** Gender by region distribution
tab fem west

*** Parent education by respondent education
tab ped edu, row
tab ped

*** Age and personality distribution in 2005
sum age fem west agr con ext neu ope




