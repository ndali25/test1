*======================================================================
* x11_Disagreement_Prep.do
*======================================================================
/**********************************************************************
	Description: Produce disagreement measures for Figure 6.
**********************************************************************/
clear
set more off

foreach var in gdp hicp urate {
	foreach horizon in Aroll Broll {
		use "${ready}\new_accuracymeasuresv3_`var'`horizon'.dta", clear
		keep yq person point realized point_fcast_accuracy_abs mean_pfa
		keep if point != . & realized != .

		/* Disagreement  */
		bysort yq: egen avg_point = mean(point)
		gen disagreement = abs(point - avg_point)
		bysort yq: egen avg_disagreement = mean(disagreement)
		gen rel_dis = disagreement - avg_disagreement
		bysort person: egen avg_rel_dis = mean(rel_dis)

		/* Forecast Performance */
		gen rel_fp = point_fcast_accuracy_abs - mean_pfa
		bysort person: egen avg_rel_fp = mean(rel_fp)
	
		/* Collapse */
		collapse rel_dis rel_fp, by(person)

		export excel using "${ready}\fp_and_dis_`var'`horizon'", firstrow(variables) replace
	}
}


