*======================================================================
* x13_Forecast_Combinations.do
*======================================================================
/**********************************************************************
	Description: Produce performance-weighted forecast measure for 
	Table 5A.
**********************************************************************/
clear
set more off

import excel "${regressions}\alpha_lambda_sheet.xlsx", sheet("Sheet1") firstrow
keep ID pfa_gdp_aroll_alpha pfa_gdp_aroll_lambda
ren pfa_gdp_aroll_alpha alpha
ren pfa_gdp_aroll_lambda lambda
drop if alpha == . | lambda == .
ren ID person

/* Merge with forecast performance data */
merge 1:m person using "${ready}\new_accuracymeasuresv3_gdpAroll.dta"
assert _m == 3
drop _m
keep person yq alpha lambda mean_pfa point_fcast_accuracy_abs

/* Predicted forecast performance */
gen fp_hat = alpha + lambda * mean_pfa

/* RMSE from each forecaster's regression */
gen resid_sqr = (fp_hat - point_fcast_accuracy_abs)^2
bysort person: egen SSR = total(resid_sqr)
bysort person: gen valid_obs = (point_fcast_accuracy_abs != .)
bysort person: egen total_obs = sum(valid_obs)
gen df = total_obs - 2
gen MSE = SSR/df
gen RMSE = sqrt(MSE)
drop resid_sqr SSR df MSE

/* Test: checks that manual RMSE is the same as the RMSE that Stata computes */
gen a = 0
if a == 1 {
	keep if person == 1
	eststo  acc_hicpAroll_joint_pfa: ivreg2 point_fcast_accuracy_abs mean_pfa, robust bw(5) kernel(bar) small	
}
drop a
/* Test: checks that manual RMSE is the same as the RMSE that Stata computes*/

/* Standardized forecast performance */
gen std_fp = (mean_pfa - fp_hat) / RMSE
drop RMSE

/* Use standard normal CDF to compute probabilities */
gen prob = normal(std_fp)

/* Compute probability weights */
sort yq
egen sum_prob = sum(prob), by(yq)
gen mean_weight = prob / sum_prob

/* Compute probability-weighted consensus forecast performances */
gen meanprob_forecast_ind = mean_weight * point_fcast_accuracy_abs
bysort yq: egen meanprob_forecast = sum(meanprob_forecast_ind)
collapse mean_pfa meanprob_forecast, by(yq)
label var mean_pfa "Consensus Forecast"
label var meanprob_forecast "Performance-weighted Forecast"

/* Select surveys */
keep if inlist(yq, tq(2016q2), tq(2014q4), tq(2004q3), tq(2002q2), tq(2011q3), tq(2001q3), tq(2008q4), tq(2008q3))
sort mean_pfa
gen ratio = meanprob_forecast / mean_pfa
label var ratio "Ratio"
drop yq

/* Output */
export excel using "${regressions}\table5a.xlsx", firstrow(varlabels) replace


