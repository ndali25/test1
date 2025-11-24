*======================================================================
* x04_Data_Clean_And_Merge.do
*======================================================================
/**********************************************************************
	Description: Merge realized data with the survey data, dropping those 
	who don't report valid forecasts as specified by the conditions below.
**********************************************************************/
clear
set more off

foreach var in gdp hicp urate {
	foreach horizon in Ac Bc Aroll Broll {

			use  "${intermediate}/`var'`horizon'.dta", clear

			egen total = rowtotal(a*)
			gen sum1 = 0
			replace sum1=1 if total <=.999  | total >=1.001 // drop forecasters whose density forecasts don't add up to 1 beyond some rounding error
			count if ( !inrange(total,.999,1.001) | point==. )
			drop  if ( !inrange(total,.999,1.001) | point==. )
			
				generate matched = ( !missing(point) ) & (sum1==0) // make sure forecasters report both a density AND a point forecast
			    merge m:1 ydate qdate using "${intermediate}/actual_`var'.dta", keep(1 3)	
				
				assert inlist(ydate,1999,2000) & !inlist(qdate,1) & inlist("`horizon'","fiveyr") if _merge == 2 // 1999 and 2000 Q2-Q4 don't have data for the five-year-ahead forecast
				drop _merge
				if "`horizon'" != "Ac"  drop realized_*Ac // keep "realized" data only for the dataset that we are actually saving 
				if "`horizon'" != "Bc"  drop realized_*Bc
				if "`horizon'" != "Aroll"  drop realized_*A
				if "`horizon'" != "Broll"  drop realized_*B
				if "`horizon'" != "fiveyr" drop realized_*5
				
			// remove 2009Q1 for gdpAroll as the bin structure didn't catch up quickly enough with the recession
			if "`var'"=="gdp" & "`horizon'"=="Aroll" {
				save "${intermediate}/clean_`var'`horizon'_w2009q1.dta", replace
				drop if ydate==2009 & qdate==1
				save "${intermediate}/clean_`var'`horizon'.dta", replace
			}
			
			save "${intermediate}/clean_`var'`horizon'.dta", replace
	} // end horizon loop
} // end var loop


