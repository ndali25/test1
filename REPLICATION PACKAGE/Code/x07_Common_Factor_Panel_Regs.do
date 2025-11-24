*======================================================================
* x07_Common_Factor_Panel_Regs.do
*======================================================================
/**********************************************************************
	Description: Run fixed effects and loading factor regressions, and 
	export the data. Also create and export datasets that will be used 
	to produce figures.
**********************************************************************/
clear
set more off
cd "${regressions}"

foreach var in gdp hicp urate {
	foreach num in 50 {
		foreach horizon in Aroll Broll {
		
			preserve 
			use "${ready}\new_accuracymeasuresv2_`var'`horizon'.dta", clear
			sort ydate qdate person point				
			drop yq
			generate yq = yq(ydate, qdate)		
		
			xtset person yq, quarterly
			tsfill, full
			est clear
		
			// realized is short for realized_`var'[_growth]`horizon_abbreviated', ie realized_gdp_growthA, which is the realized gdp growth for the Aroll (1-year-ahead) horizon from the ydate/qdate survey
			generate point_fcast_accuracy         =     point - realized
			generate point_fcast_accuracy_sq      =    (point - realized)^2		                                                                         
			generate point_fcast_accuracy_abs     =    abs(point - realized)
			generate pfa_abs = point_fcast_accuracy_abs
	
			// compute means by survey of each metric 
			bysort yq : egen mean_pfa=mean(point_fcast_accuracy_abs)
			bysort yq : egen mean_eada=mean(EADA) // NOT USED IN PAPER
			bysort yq : egen mean_arps=mean(rank_prob_score_revised_abs)
		
			save "${ready}\new_accuracymeasuresv3_`var'`horizon'.dta", replace // includes point forecast accuracy measures

			*---------------------------------------
			* 	Point Forecast Accuracy
			*---------------------------------------

			eststo acc_`var'`horizon'_joint_pfa: ivreg2 point_fcast_accuracy_abs ibn.person ibn.person#c.mean_pfa, robust bw(5) kernel(bar) noconstant small
	
			// save and export fixed effects and loading factors and VCV matrix 
			matrix V=get(VCE)
			matrix b = get(_b)
			scalar rmse = e(rmse)
			sum mean_pfa, detail
			scalar minpfa = r(min)
			scalar maxpfa = r(max)
			scalar medpfa = r(p50)
			matrix list V
			matrix list b
			scalar list rmse
			scalar list minpfa
			scalar list maxpfa
			scalar list medpfa
		
			putexcel set pesaran_pfa_`var'`horizon'_cov_`num'_newey_joint, replace
			putexcel A1 = matrix(V), names
			putexcel close
			putexcel set pesaran_pfa_`var'`horizon'_coefs_`num'_newey_joint, replace
			putexcel A1 = matrix(b), names
			putexcel close
			putexcel set pesaran_pfa_`var'`horizon'_stats_`num'_newey_joint, replace
			putexcel A1 = rmse
			putexcel B1 = minpfa
			putexcel C1 = maxpfa
			putexcel D1 = medpfa
			putexcel close
			eststo clear

			eststo acc_`var'`horizon'_hats_pfa: ivreg2 point_fcast_accuracy_abs i.person i.person#c.mean_pfa mean_pfa, robust bw(5) kernel(bar)
	
			// save and export fixed effects and loading factors and VCV matrix 
			matrix V=get(VCE)
			matrix b = get(_b)
			matrix list V
			matrix list b
		
			putexcel set pesaran_pfa_`var'`horizon'_cov_`num'_newey_hats, replace
			putexcel A1 = matrix(V), names
			putexcel close
			putexcel set pesaran_pfa_`var'`horizon'_coefs_`num'_newey_hats, replace
			putexcel A1 = matrix(b), names
			putexcel close
			eststo clear
		
	
			*---------------------------------------
			* 			ARPS
			*---------------------------------------

			eststo acc_`var'`horizon'_joint_arps: ivreg2 rank_prob_score_revised_abs ibn.person ibn.person#c.mean_arps, robust bw(5) kernel(bar) noconstant small
	
			// save and export fixed effects and loading factors and VCV matrix 	
			matrix V=get(VCE)
			matrix b = get(_b)
			matrix list V
			matrix list b
			scalar rmse = e(rmse)
			sum mean_arps, detail
			scalar minpfa = r(min)
			scalar maxpfa = r(max)
			scalar medpfa = r(p50)
			matrix list V
			matrix list b
			scalar list rmse
			scalar list minpfa
			scalar list maxpfa
			scalar list medpfa
		
			putexcel set pesaran_arps_`var'`horizon'_cov_`num'_newey_joint, replace
			putexcel A1 = matrix(V), names
			putexcel close
			putexcel set pesaran_arps_`var'`horizon'_coefs_`num'_newey_joint, replace
			putexcel A1 = matrix(b), names
			putexcel close
			putexcel set pesaran_arps_`var'`horizon'_stats_`num'_newey_joint, replace
			putexcel A1 = rmse
			putexcel B1 = minpfa
			putexcel C1 = maxpfa
			putexcel D1 = medpfa
			putexcel close
			eststo clear

			eststo acc_`var'`horizon'_hats_arps: ivreg2 rank_prob_score_revised_abs i.person i.person#c.mean_arps mean_arps, robust bw(5) kernel(bar) small
	
	
			// save and export fixed effects and loading factors and VCV matrix 
			matrix V=get(VCE)
			matrix b = get(_b)
			matrix list V
			matrix list b
		
			putexcel set pesaran_arps_`var'`horizon'_cov_`num'_newey_hats, replace
			putexcel A1 = matrix(V), names
			putexcel close
			putexcel set pesaran_arps_`var'`horizon'_coefs_`num'_newey_hats, replace
			putexcel A1 = matrix(b), names
			putexcel close
			eststo clear

			restore
		}
	}
}

*---------------------------------------
* 	Export Average FP Values
*---------------------------------------
foreach var in gdp hicp urate {
	foreach num in 50 {
		foreach horizon in Aroll Broll {
			use "${ready}\new_accuracymeasuresv3_`var'`horizon'.dta", clear
			if "`var'" == "gdp" {
				generate tgdate = yq(year, quarter)
			}
			if "`var'" == "hicp" | "`var'" == "urate" {
				if "`horizon'" == "Aroll"{
					generate tgdate = yq + 3
				}
				if "`horizon'" == "Broll"{
					generate tgdate = yq + 7
				}
			}
			format tgdate %tq
			collapse mean_pfa mean_arps, by(tgdate)
			drop if tgdate == . | mean_pfa == . | mean_arps == .
			rename mean_pfa `var'`horizon'_pfa
			rename mean_arps `var'`horizon'_arps
			tempfile `var'`horizon'
			save ``var'`horizon''
		}
	}
}

use `gdpAroll', clear
merge 1:1 tgdate using `gdpBroll'
sort tgdate
drop _m
merge 1:1 tgdate using `hicpAroll'
sort tgdate
drop _m
merge 1:1 tgdate using `hicpBroll'
sort tgdate
drop _m
merge 1:1 tgdate using `urateAroll'
sort tgdate
drop _m
merge 1:1 tgdate using `urateBroll'
sort tgdate
drop _m

tempfile paneldata 
save `paneldata'
use "${ready}\euro_area_recession_dates.dta", clear
merge 1:1 tgdate using `paneldata'
drop _m

export excel using "${ready}\avg_fp_vals.xlsx", firstrow(variables) replace

*---------------------------------------
* 	Export Average Adjusted FP Values
*---------------------------------------
foreach var in gdp hicp urate {
	foreach num in 50 {
		foreach horizon in Aroll Broll {
			use "${ready}\new_accuracymeasuresv3_`var'`horizon'.dta", clear
			if "`var'" == "gdp" {
				generate tgdate = yq(year, quarter)
			}
			if "`var'" == "hicp" | "`var'" == "urate" {
				if "`horizon'" == "Aroll"{
					generate tgdate = yq + 3
				}
				if "`horizon'" == "Broll"{
					generate tgdate = yq + 7
				}
			}
			format tgdate %tq
			gen adj_pfa = point_fcast_accuracy_abs - mean_pfa
			gen adj_arps = rank_prob_score_revised_abs - mean_arps
			bysort person: egen mean_adj_pfa=mean(adj_pfa)
			bysort person: egen mean_adj_arps=mean(adj_arps)
			collapse mean_adj_pfa mean_adj_arps, by(person)
			drop if person == . | mean_adj_pfa == . | mean_adj_arps == .
			rename mean_adj_pfa `var'`horizon'_adj_pfa
			rename mean_adj_arps `var'`horizon'_adj_arps
			tempfile `var'`horizon'
			save ``var'`horizon''
		}
	}
}

use `gdpAroll', clear
merge 1:1 person using `gdpBroll'
sort person
drop _m
merge 1:1 person using `hicpAroll'
sort person
drop _m
merge 1:1 person using `hicpBroll'
sort person
drop _m
merge 1:1 person using `urateAroll'
sort person
drop _m
merge 1:1 person using `urateBroll'
sort person
drop _m

export excel using "${ready}\avg_adj_fp_vals.xlsx", firstrow(variables) replace

*---------------------------------------
* 	Export Aggregated Alphas and Lambdas
*---------------------------------------
foreach var in gdp hicp urate {
	foreach measure in pfa arps {
		foreach horizon in Aroll Broll {
			import excel "pesaran_`measure'_`var'`horizon'_coefs_50_newey_joint.xlsx", sheet("Sheet1") clear
			drop A
			sxpose, clear
			rename _var1 ID
			rename _var2 coeff
			destring coeff, replace
			replace ID = substr(ID, 1, 10)
			replace ID = "1.person" if ID == "1bn.person"
			replace ID = "2.person" if ID == "2.person#c"
			replace ID = "4.person" if ID == "4.person#c"
			replace ID = "5.person" if ID == "5.person#c"
			forvalues x = 1/100 {
				replace ID = "`x'" if ID == "`x'.person"
				replace ID = "`x'" if ID == "`x'.person#"
			}
			destring ID, replace
			sort ID coeff
			by ID: gen group = _n
			reshape wide coeff, i(ID) j(group)
			rename coeff1 `measure'_`var'_`horizon'_alpha
			rename coeff2 `measure'_`var'_`horizon'_lambda
			tempfile `measure'`var'`horizon'
			save ``measure'`var'`horizon''
		}
	}
}

use `pfagdpAroll', clear
merge 1:1 ID using `pfagdpBroll'
sort ID
drop _m
merge 1:1 ID using `arpsgdpAroll'
sort ID
drop _m
merge 1:1 ID using `arpsgdpBroll'
sort ID
drop _m
merge 1:1 ID using `pfahicpAroll'
sort ID
drop _m
merge 1:1 ID using `pfahicpBroll'
sort ID
drop _m
merge 1:1 ID using `arpshicpAroll'
sort ID
drop _m
merge 1:1 ID using `arpshicpBroll'
sort ID
drop _m
merge 1:1 ID using `pfaurateAroll'
sort ID
drop _m
merge 1:1 ID using `pfaurateBroll'
sort ID
drop _m
merge 1:1 ID using `arpsurateAroll'
sort ID
drop _m
merge 1:1 ID using `arpsurateBroll'
sort ID
drop _m

tolower pfa_gdp_Aroll_alpha-arps_urate_Broll_lambda
export excel using "alpha_lambda_sheet.xlsx", firstrow(variables) replace


