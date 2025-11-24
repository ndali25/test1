*======================================================================
* x18_HL_Prep.do
*======================================================================
/**********************************************************************
	Description: Prepare ECB forecast errors for use with 
	Hounyo and Lahiri (2023) bootstrap procedure.
**********************************************************************/
clear
set more off

foreach var in gdp hicp urate {
	foreach horizon in Aroll Broll  { 
		use "${ready}\new_accuracymeasuresv3_`var'`horizon'.dta", clear
		
		keep yq person point_fcast_accuracy
		sort yq person
		reshape wide point_fcast_accuracy, i(yq) j(person)

		export excel using "${ready}\errors_`var'`horizon'_point.xlsx", firstrow(variables) replace
	}
}

foreach var in gdp hicp urate {
	foreach horizon in Aroll Broll  { 
		use "${ready}\new_accuracymeasuresv3_`var'`horizon'.dta", clear
		
		keep yq person rank_prob_score_revised_abs
		sort yq person
		reshape wide rank_prob_score_revised_abs, i(yq) j(person)

		export excel using "${ready}\errors_`var'`horizon'_density.xlsx", firstrow(variables) replace
	}
}


