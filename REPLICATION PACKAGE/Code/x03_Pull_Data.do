*======================================================================
* x03_Pull_Data.do
*======================================================================
/**********************************************************************
	Description: Calculate realized values of Euro Zone GDP growth and HICP, then
    combine various series into speradsheets for HICP, GDP and unemployment rate.
    Uses the real time data, with the t and t+4 (or t and t+12 in the case of HICP)
    values coming from the t+4 (or t+12) vintage.
    Data vintages for each series located at: 
    GDP:
    https://sdw.ecb.europa.eu/quickview.do?SERIES_KEY=194.RTD.Q.S0.S.G_GDPM_TO_C.E
    HICP:
    https://sdw.ecb.europa.eu/quickview.do?SERIES_KEY=194.RTD.M.S0.N.P_C_OV.X
    Urate:
    https://sdw.ecb.europa.eu/quickview.do?SERIES_KEY=194.RTD.M.S0.S.L_UNETO.F

    Note: Data are frozen in the realizations.xlsx spreadsheet. The realized data 
    will go as far out as 2019Q3 -- i.e., we will be computing forecast performance 
    metrics out to the 2019Q1 survey date, because that is the date for which 2019Q3 
    is the target variable.
*********************************************************************/
clear all
set more off


*	1. Raw HICP data 
	import excel using "${raw}/realizations.xlsx", sheet("hicp") clear 
	drop if _n <= 1
	gen year = substr(A,1,4)
	gen month = substr(A,5,2)
	destring month year C, replace
	rename C hicp
	destring D, replace
	sort year month

	drop A B
	keep if month == 12 | month == 3 | month == 6 | month == 9 | month==2
	drop if month==2 & year~=2019
	drop if month==3 & year==2019
	
	keep if year >= 1998
	rename month quarter

	 gen realized_hicp_growthA = . 
	 gen realized_hicp_growthB = . 
	 gen realized_hicp_growthAc = . // place holders for calendar year
	 gen realized_hicp_growthBc = . // place holders for calendar year
	 gen realized_hicp_growth5 = .
	
		replace realized_hicp_growthA = ((D[_n+3]/hicp[_n+3])-1)*100
		replace realized_hicp_growthB = ((D[_n+7]/hicp[_n+7])-1)*100 
		replace realized_hicp_growthB = 100*((hicp[_n+7]-hicp[_n+3])/hicp[_n+3]) if (year == 1998) | (year == 1999 & quarter == 3)
		replace realized_hicp_growthA = 100*((hicp[_n+3]-hicp[_n-1])/hicp[_n-1]) if (year == 1998) | (year == 1999) | (year == 2000 & quarter == 3 )
		

	  replace quarter = 1 if (quarter == 2 & year == 2019) // survey was conducted earlier, so the realized number has to come from Feb instead of March
	  replace quarter = 2 if (quarter == 6 & year == 2019) 
	  replace quarter = 3 if (quarter == 9 & year == 2019) 
	  replace quarter = 4 if (quarter == 12 & year == 2019) 

      replace quarter = 1 if (quarter == 3 & year != 2019) 
	  replace quarter = 2 if (quarter == 6 & year != 2019)
	  replace quarter = 3 if (quarter == 9 & year != 2019)
	  replace quarter = 4 if (quarter == 12 & year != 2019)

	drop hicp D
	keep if year > 1998
	rename year ydate
	rename quarter qdate
	
	save "${intermediate}/actual_hicp.dta", replace
	
*	2.1 Raw GDP growth data 
	import excel using "${raw}/realizations.xlsx", sheet("gdp") clear
	drop if _n <= 1
	gen year = substr(A,1,4)
	gen quarter = substr(A,5,2)
	destring year quarter C, replace
	rename C gdp
	destring D, replace
	sort year quarter
	drop A B
	gen realized_gdp_growthA = . 
	gen realized_gdp_growthB = . 
	gen realized_gdp_growthAc = . // place holders for calendar year
	gen realized_gdp_growthBc = . // place holders for calendar year
	gen realized_gdp_growth5 = . 
		replace realized_gdp_growthA = 100 * ((gdp[_n+2]/D[_n+2])-1) 
		replace realized_gdp_growthB = 100 * ((gdp[_n+6]/D[_n+6])-1)
		replace realized_gdp_growthA = 100 * ((gdp[_n+2]-gdp[_n-2]) / gdp[_n-2]) if (year==1998) | (year == 1999) 
	drop gdp D
	keep if year > 1998
	rename year ydate
	rename quarter qdate		
	save "${intermediate}/actual_gdp.dta", replace
	
* 	2.2 Raw Unemployment Rate data 
	import excel using "${raw}/realizations.xlsx", sheet("urate") clear
	drop if _n <= 1
	gen year = substr(A,1,4)
	gen month = substr(A,5,2)
	destring month year C, replace
	rename C urate
	sort year month
	*create realized variable for long term forecast 
	by year: egen temp = mean(urate)
	keep if month == 11 | month == 2 | month == 5 | month == 8
	keep if year >= 1998
	rename month quarter
	replace quarter = 1 if quarter == 2
	replace quarter = 2 if quarter == 5
	replace quarter = 3 if quarter == 8
	replace quarter = 4 if quarter == 11
	*	This adjustment is made because of the way the HICP survey question is asked
	*	In 1998Q1 you are asked to forecast the unemployment rate in Nov of '98. 
		gen realized_urateA = (urate[_n+3])
		gen realized_urateB = (urate[_n+7])
		gen realized_urateAc = .
		gen realized_urateBc = . // place holders for the calendar year
		gen realized_urate5 = (temp[_n+18])	
	drop urate temp A B
	keep if year > 1998	
	rename year ydate
	rename quarter qdate	
	save "${intermediate}/actual_urate.dta", replace
	

	