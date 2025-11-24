*======================================================================
* x05_Drop_Low_Counts.do
*======================================================================
/**********************************************************************
	Description: Drop forecasters that participated in less than `n' surveys.
**********************************************************************/
clear all          
set more off

foreach var in gdp hicp urate {
	foreach horizon in Ac Bc Aroll Broll {
		local n=50
		local tol=0.001
		use "${intermediate}\clean_`var'`horizon'.dta", clear 			
		generate yq = yq(ydate, qdate)		
		order yq 
		sort yq person
		xtset person yq, quarterly
		
		capture drop indicator 
		gen indicator = 0
		replace indicator = 1 if total<=1-`tol' | total>=1+`tol'
		
		capture drop matched
		generate matched = (!missing(point)) & (indicator==0)   

		bysort person: egen participation_count = sum(matched)	
		keep if participation_count>=`n'
		save "${intermediate}\clean_`var'`horizon'_nolowcounts50.dta", replace
		
	}
}
		
		// Used to get 2009q1 pfa value for GDP growth
		use "${intermediate}\clean_gdpAroll_w2009q1.dta", clear 			
		generate yq = yq(ydate, qdate)		
		order yq 
		sort yq person
		xtset person yq, quarterly
		
		capture drop indicator 
		gen indicator = 0
		replace indicator = 1 if total<=1-0.001 | total>=1+0.001
		
		gen point_temp = point
		replace point = . if yq == tq(2009q1)
		
		capture drop matched
		generate matched = (!missing(point)) & (indicator==0)   

		bysort person: egen participation_count = sum(matched)	
		keep if participation_count>=50
		replace point = point_temp if yq == tq(2009q1)
		
		save "${intermediate}\clean_gdpAroll_w2009q1_nolowcounts50.dta",replace
		
		sort ydate qdate person point				
		drop yq
		generate yq = yq(ydate, qdate)		
		
		xtset person yq, quarterly
		tsfill, full
		est clear
		
		generate point_fcast_accuracy         =     point - realized
		generate point_fcast_accuracy_sq      =    (point - realized)^2		                                                
		generate point_fcast_accuracy_abs     =    abs(point - realized)
		generate pfa_abs = point_fcast_accuracy_abs
	 
		bysort yq : egen mean_pfa=mean(point_fcast_accuracy_abs)
		save "${ready}\new_accuracymeasuresv3_gdpAroll_w2009q1.dta", replace
		

