*** Purpose: descriptives for for revised gsoep analysis
*** Author: S Bauldry
*** Date: March 14, 2016

*** loading data
use gsoep-data-2, replace


****** Unweighted descriptives ******
*** Gender by region distribution
tab fem west

*** Parent education by respondent education
tab ped edu15

*** Age and personality distribution in 2005
sum age05 agr05 con05 ext05 neu05 ope05



****** Weighted descriptives *******
*** Note: we do not have the weight variables necessary (p 40)




