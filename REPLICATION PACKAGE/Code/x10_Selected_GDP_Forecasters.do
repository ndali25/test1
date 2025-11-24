*======================================================================
* x10_Selected_GDP_Forecasters.do
*======================================================================
/**********************************************************************
	Description: Isolate performance data from forecasters used in 
	Figure 7.
**********************************************************************/
clear
set more off

use "${ready}\new_accuracymeasuresv3_gdpAroll.dta", replace

keep if inlist(person, 22,36,37,85)
keep person point_fcast_accuracy_abs mean_pfa
ren person variable
replace variable = 0 if variable == 37
replace variable = 1 if variable == 36
replace variable = 3 if variable == 22
replace variable = 2 if variable == 85
drop if point_fcast_accuracy_abs == . | mean_pfa == .
order mean_pfa variable point_fcast_accuracy_abs

export excel using "${ready}\selected_gdp_forecasters.xls", firstrow(variables) replace