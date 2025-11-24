*======================================================================
* x12_Forecast_Performance_Rankings.do
*======================================================================
/**********************************************************************
	Description: Generate Table 3 by computing rank orderings of fitted 
	forecast accuracy.
**********************************************************************/
clear
set more off

import excel "${regressions}\alpha_lambda_sheet.xlsx", sheet("Sheet1") firstrow
keep ID pfa_gdp_aroll_alpha pfa_gdp_aroll_lambda
ren pfa_gdp_aroll_alpha alpha
ren pfa_gdp_aroll_lambda lambda
drop if alpha == . | lambda == .

/* RANKINGS */
gen FP25 = alpha + lambda * 0.25
gen FP50 = alpha + lambda * 0.5
gen FP75 = alpha + lambda * 0.75
gen FP100 = alpha + lambda * 1
gen FP150 = alpha + lambda * 1.5
gen FP200 = alpha + lambda * 2
gen FP400 = alpha + lambda * 4
gen FP600 = alpha + lambda * 6

sort FP25
gen rFP25 = _n
sort FP50
gen rFP50 = _n
sort FP75
gen rFP75 = _n
sort FP100
gen rFP100 = _n
sort FP150
gen rFP150 = _n
sort FP200
gen rFP200 = _n
sort FP400
gen rFP400 = _n
sort FP600
gen rFP600 = _n
order ID rFP25 rFP50 rFP75 rFP100 rFP150 rFP200 rFP400 rFP600
sort rFP25

/* EXPORT */
preserve
keep ID-rFP600
export excel using "${regressions}\table3.xlsx", firstrow(variables) replace
restore

// NOT USED IN PAPER
spearman rFP25 rFP400
spearman rFP25 rFP600

/* CROSSING VALUES */
gen FPcrossing = alpha / (1 - lambda)
replace FPcrossing = . if alpha < 0 & lambda < 1
replace FPcrossing = . if alpha > 0 & lambda > 1
sort FPcrossing
gen flag = "Red" if alpha > 0 & lambda < 1 & FPcrossing != .
replace flag = "Orange" if alpha < 0 & lambda > 1 & FPcrossing != .
// NOT USED IN PAPER


