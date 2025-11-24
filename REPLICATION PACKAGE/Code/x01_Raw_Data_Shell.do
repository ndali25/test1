*======================================================================
* x01_Raw_Data_Shell.do
*====================================================================== 
/**********************************************************************  
	Data in:  `year'Q`quarter'.csv files from the ECB (RAW DATA)
   
	Data out: 
			  hicpAc.dta
              hicpBc.dta
              hicpAroll.dta
              hicpBroll.dta
              hicptwoyr.dta
              hicpfiveyr.dta
              gdpAc.dta
              gdpBc.dta
              gdpAroll.dta
              gdpBroll.dta
              gdptwoyr.dta
              gdpfivetr.dta
              urateA.dta
              urateB.dta
              urateAroll.dta
              urateBroll.dta
              uratetwoyr.dta
              uratefiveyr.dta
**********************************************************************/
clear
set more off   

local year = $start_year 
local quarter = $start_quarter 
local z = 0 /*set dummy to trigger to get out of loop */

while `z' == 0 {

   insheet using "${raw}/`year'Q`quarter'.csv", comma  clear
	
   /*Get rid of header */
   drop in 1/2

   preserve

   /* Mark where the Core Inflation Expectations data section starts */ 
   gen coreinfl = strpos(v1, "CORE")
   gen bin_coreinfl = 0
   replace bin_coreinfl = 1 if coreinfl > 0

   /* Keep only inflation data */
   gen erasedata = sum(bin_coreinfl)
   drop if erasedata == 1

   rename v1 date
   rename v2 person
   rename v3 point

   drop coreinfl bin_coreinfl erasedata

   /* Create Date (year & month) Variables */
   gen year = substr(date,1,4)
   gen temp = substr(date,5,3)

   destring v* person point year,replace
   gen month = .
   replace month = 12 if temp == "Dec"
   replace month = 3 if temp == "Mar"
   replace month = 2 if temp == "Feb"
   replace month = 6 if temp == "Jun"
   replace month = 9 if temp == "Sep"

   tab month, missing
   drop date temp
   gen qdate = `quarter' /*survey date (quarter)*/
   gen ydate = `year' /* survey date (year)*/
   order ydate qdate year month
   save "${intermediate}/temp_inflation_`year'Q`quarter'.dta", replace
   restore
   preserve
   /*Keep GDP data */
   
   gen GDP = strpos(v1, "GDP")
   gen binGDP = 0
   replace binGDP = 1 if GDP > 0

   gen keepdata = sum(binGDP)
   keep if keepdata == 1

   gen labour = strpos(v1, "LABOUR")
   gen binlabour = 0
   replace binlabour = 1 if labour > 0
   gen erasedata = sum(binlabour)
   drop if erasedata == 1

   /* Get rid of header*/
   drop in 1/2

   rename v1 date
   rename v2 person
   rename v3 point

   drop GDP binGDP keepdata labour binlabour erasedata

   /* Create date variables (year & quarter)*/
   gen year = substr(date,1,4)
   gen quarter = substr(date,6,1)

   destring v* person point year quarter, replace
   drop date
   gen qdate = `quarter' /*survey date (quarter)*/
   gen ydate = `year' /*survey date (year)*/
   order ydate qdate year quarter
   save "${intermediate}/temp_GDP_`year'Q`quarter'.dta", replace

   restore

   /*Keep Unemployment Data */
   gen urate = strpos(v1, "UNEMPLOYMENT")
   gen binurate = 0
   replace binurate = 1 if urate >0
   gen keepdata = sum(binurate)
   keep if keepdata == 1

   /* Drop Assumption Data */
   gen assume = strpos(v1, "ASSUMPTIONS")
   gen binassume = 0
   replace binassume = 1 if assume > 0
   gen erasedata = sum(binassume)
   drop if erasedata == 1

   drop in 1/2
   rename v1 date
   rename v2 person
   rename v3 point
   drop urate binurate keepdata assume binassume erasedata
   gen year = substr(date, 1,4)
   gen temp = substr(date,5,3)

   destring v* person point year,replace
   gen month = .
   replace month = 11 if temp == "Nov"
   replace month = 1 if temp == "Jan"
   replace month = 2 if temp == "Feb"
   replace month = 5 if temp == "May"
   replace month = 8 if temp == "Aug"
   
   replace month = 12 if temp == "Dec"
   replace month = 3 if temp == "Mar"
   replace month = 6 if temp == "Jun"
   replace month = 9 if temp == "Sep"

   tab month, missing
   drop date temp
   gen qdate = `quarter' /*survey date (quarter)*/
   gen ydate = `year' /* survey date (year)*/
   order ydate qdate year month
   save "${intermediate}/temp_unemployment_`year'Q`quarter'.dta", replace
   
   
/*****************************************************************************************/
/*****************************************************************************************/
/*****************************************************************************************/
   
   if (`year' == $end_year & `quarter' == $end_quarter) {
      local z = 1
   }
   
   local quarter = `quarter' + 1

   if `quarter' == 5 {
      local year = `year' + 1
      local quarter = 1
   }
}

*	++++++++++++	*
*		HICP		*
*	++++++++++++	*
/*Parse & append the HICP data by forecast horizons */

local year = $start_year /*set year*/
local quarter = $start_quarter /*set quarter*/
local z = 0 /*set dummy*/

while `z' == 0 {
   
   use "${intermediate}/temp_inflation_`year'Q`quarter'.dta", clear
   
   capture confirm numeric variable year
   if _rc {
	drop if year == "TARG"
   }
   
   destring year, replace
   destring person, replace
   
   /********************************************************************/
   /* Create Dummies by forecast horizons                              */
   /********************************************************************/
   
   /*Current Calendar Year Horizon Dummy */
   gen hicpAc = 0
   replace hicpAc = 1 if (year == `year' & month == .)
   label var hicpAc "Current Year HICP Inflation Expectation"
   
   /* Next Calendar Year Horizon Dummy */
   gen hicpBc = 0
   replace hicpBc = 1 if (year == `year' + 1 & month == .)
   label var hicpBc "Next Year HICP Inflation Expectation"
   
   /* One Year Ahead Rolling Horizon Dummy */
   gen hicpAroll = 0
   replace hicpAroll = 1 if (qdate == 1 & year == `year' & month != .)
   replace hicpAroll = 1 if ((qdate == 2 | qdate == 3 | qdate == 4) & year == `year' + 1 & month !=.)
   label var hicpAroll "Rolling 1 Yr ahead HICP Inflation Expectation"
   
   /* One Year- One Year Forward Rolling Horizon Dummy */
   gen hicpBroll = 0
   replace hicpBroll = 1 if (qdate == 1 & year == `year' + 1 & month != .)
   replace hicpBroll = 1 if ((qdate == 2 | qdate == 3 | qdate == 4) & year == `year' + 2 & month !=.)
   label var hicpBroll "Rolling 1YR-1YR forward HICP Inflation Expectation"
   
   /* Calendar Two Year Ahead Dummy */
   gen hicptwoyr = 0
   replace hicptwoyr = 1 if ((ydate > 1999 & (qdate == 3 | qdate == 4)) & year == `year' + 2 & month == .)
   label var hicptwoyr "Two Year ahead HICP Inflation Expectation"
   
   /* Calendar Five Year Ahead Dummy */
   gen hicpfiveyr = 0
   replace hicpfiveyr = 1 if ((qdate == 1 & ydate == 1999) & year == `year' + 4 & month == .)
   replace hicpfiveyr = 1 if ((qdate == 1 & ydate == 2000) & year == `year' + 4 & month == .)
   replace hicpfiveyr = 1 if ((ydate > 2000 & (qdate == 1 | qdate == 2)) & year == `year' + 4 & month == .)
   replace hicpfiveyr = 1 if ((ydate > 2000 & (qdate == 3 | qdate == 4)) & year == `year' + 5 & month == .)
   label var hicpfiveyr "Five Year ahead HICP Inflation Expectation"
   
   destring v*, replace

   /* Rename Variables by "bins" */
   /* Number of bins have changed across time. The loop changes how many "bins" are created*/

   if (`year' < 2000) {
      rename v4 a1
      rename v5 a2
      rename v6 a3
      rename v7 a4
      rename v8 a5
      rename v9 a6
      rename v10 a7
      rename v11 a8
      rename v12 a9
      replace a1 = 0 if a1 == .
      replace a2 = 0 if a2 == .
      replace a3 = 0 if a3 == .
      replace a4 = 0 if a4 == .
      replace a5 = 0 if a5 == .
      replace a6 = 0 if a6 == .
      replace a7 = 0 if a7 == .
      replace a8 = 0 if a8 == .
      replace a9 = 0 if a9 == .     
      drop v*
   }
   else if (`year' ==  2000 & (`quarter' == 1 | `quarter' == 2 | `quarter' == 3)) {
      rename v4 a1
      rename v5 a2
      rename v6 a3
      rename v7 a4
      rename v8 a5
      rename v9 a6
      rename v10 a7
      rename v11 a8
      rename v12 a9
      replace a1 = 0 if a1 == .
      replace a2 = 0 if a2 == .
      replace a3 = 0 if a3 == .
      replace a4 = 0 if a4 == .
      replace a5 = 0 if a5 == .
      replace a6 = 0 if a6 == .
      replace a7 = 0 if a7 == .
      replace a8 = 0 if a8 == .
      replace a9 = 0 if a9 == .     
      drop v*
   }
   else if (`year' == 2000 & `quarter' == 4) {
      rename v4 a1
      rename v5 a2
      rename v6 a3
      rename v7 a4
      rename v8 a5
      rename v9 a6
      rename v10 a7
      rename v11 a8
      rename v12 a9
      rename v13 a10
      replace a1 = 0 if a1 == .
      replace a2 = 0 if a2 == .
      replace a3 = 0 if a3 == .
      replace a4 = 0 if a4 == .
      replace a5 = 0 if a5 == .
      replace a6 = 0 if a6 == .
      replace a7 = 0 if a7 == .
      replace a8 = 0 if a8 == .
      replace a9 = 0 if a9 == .
      replace a10 = 0 if a10 == .
      drop v*
   }
   else if (`year' > 2000 & `year' <2008){
      rename v4 a1
      rename v5 a2
      rename v6 a3
      rename v7 a4
      rename v8 a5
      rename v9 a6
      rename v10 a7
      rename v11 a8
      rename v12 a9
      replace a1 = 0 if a1 == .
      replace a2 = 0 if a2 == .
      replace a3 = 0 if a3 == .
      replace a4 = 0 if a4 == .
      replace a5 = 0 if a5 == .
      replace a6 = 0 if a6 == .
      replace a7 = 0 if a7 == .
      replace a8 = 0 if a8 == .
      replace a9 = 0 if a9 == .
      drop v*
   }
   else if (`year' == 2008 & (`quarter' == 1 | `quarter' == 2)) {
      rename v4 a1
      rename v5 a2
      rename v6 a3
      rename v7 a4
      rename v8 a5
      rename v9 a6
      rename v10 a7
      rename v11 a8
      rename v12 a9
      replace a1 = 0 if a1 == .
      replace a2 = 0 if a2 == .
      replace a3 = 0 if a3 == .
      replace a4 = 0 if a4 == .
      replace a5 = 0 if a5 == .
      replace a6 = 0 if a6 == .
      replace a7 = 0 if a7 == .
      replace a8 = 0 if a8 == .
      replace a9 = 0 if a9 == .         
      drop v*
   }
   else if (`year' == 2008 & (`quarter' == 3|`quarter' == 4)) {
      rename v4 a1
      rename v5 a2
      rename v6 a3
      rename v7 a4
      rename v8 a5
      rename v9 a6
      rename v10 a7
      rename v11 a8
      rename v12 a9
      rename v13 a10
      replace a1 = 0 if a1 == .
      replace a2 = 0 if a2 == .
      replace a3 = 0 if a3 == .
      replace a4 = 0 if a4 == .
      replace a5 = 0 if a5 == .
      replace a6 = 0 if a6 == .
      replace a7 = 0 if a7 == .
      replace a8 = 0 if a8 == .
      replace a9 = 0 if a9 == .
      replace a10 = 0 if a10 == .
      drop v*
   }
   else if (`year' == 2009 & `quarter' == 1) {
      rename v4 a1
      rename v5 a2
      rename v6 a3
      rename v7 a4
      rename v8 a5
      rename v9 a6
      rename v10 a7
      rename v11 a8
      rename v12 a9
      rename v13 a10
      replace a1 = 0 if a1 == .
      replace a2 = 0 if a2 == .
      replace a3 = 0 if a3 == .
      replace a4 = 0 if a4 == .
      replace a5 = 0 if a5 == .
      replace a6 = 0 if a6 == .
      replace a7 = 0 if a7 == .
      replace a8 = 0 if a8 == .
      replace a9 = 0 if a9 == .
      replace a10 = 0 if a10 == .
      drop v*
   }


   else if (`year' == 2009 & (`quarter' == 2 | `quarter' == 3 | `quarter' == 4)) {
      rename v4 a1
      rename v5 a2
      rename v6 a3
      rename v7 a4
      rename v8 a5
      rename v9 a6
      rename v10 a7
      rename v11 a8
      rename v12 a9
      rename v13 a10
      rename v14 a11
      rename v15 a12
      rename v16 a13
      rename v17 a14
      replace a1 = 0 if a1 == .
      replace a2 = 0 if a2 == .
      replace a3 = 0 if a3 == .
      replace a4 = 0 if a4 == .
      replace a5 = 0 if a5 == .
      replace a6 = 0 if a6 == .
      replace a7 = 0 if a7 == .
      replace a8 = 0 if a8 == .
      replace a9 = 0 if a9 == .
      replace a10 = 0 if a10 == .
      replace a11 = 0 if a11 == .
      replace a12 = 0 if a12 == .
      replace a13 = 0 if a13 == .
      replace a14 = 0 if a14 == .
      drop v*
   }
   else if (`year' > 2009 & `year' < 2020) | (`year'==2020 & `quarter'==1) {
      rename v4 a1
      rename v5 a2
      rename v6 a3
      rename v7 a4
      rename v8 a5
      rename v9 a6
      rename v10 a7
      rename v11 a8
      rename v12 a9
      rename v13 a10
      rename v14 a11
      rename v15 a12
      replace a1 = 0 if a1 == .
      replace a2 = 0 if a2 == .
      replace a3 = 0 if a3 == .
      replace a4 = 0 if a4 == .
      replace a5 = 0 if a5 == .
      replace a6 = 0 if a6 == .
      replace a7 = 0 if a7 == .
      replace a8 = 0 if a8 == .
      replace a9 = 0 if a9 == .
      replace a10 = 0 if a10 == .
      replace a11 = 0 if a11 == .
      replace a12 = 0 if a12 == .
      drop v*      
   }
   else if (`year' == 2020 & `quarter' == 2) {
      rename v4 a1
      rename v5 a2
      rename v6 a3
      rename v7 a4
      rename v8 a5
      rename v9 a6
      rename v10 a7
      rename v11 a8
      rename v12 a9
      rename v13 a10
      rename v14 a11
      rename v15 a12
	  rename v16 a13
	  rename v17 a14
	  rename v18 a15
	  rename v19 a16
	  rename v20 a17
	  rename v21 a18 
      replace a1 = 0 if a1 == .
      replace a2 = 0 if a2 == .
      replace a3 = 0 if a3 == .
      replace a4 = 0 if a4 == .
      replace a5 = 0 if a5 == .
      replace a6 = 0 if a6 == .
      replace a7 = 0 if a7 == .
      replace a8 = 0 if a8 == .
      replace a9 = 0 if a9 == .
      replace a10 = 0 if a10 == .
      replace a11 = 0 if a11 == .
      replace a12 = 0 if a12 == .
	  replace a13 = 0 if a13 == .
	  replace a14 = 0 if a14 == .
	  replace a15 = 0 if a15 == .
	  replace a16 = 0 if a16 == .
	  replace a17 = 0 if a17 == .
	  replace a18 = 0 if a18 == .
      drop v*      
   }

   foreach i of numlist 1(1)18 {
	capture replace a`i' = a`i'/100
   }
   
   destring person point, replace            
   preserve

   /* Create Dataset: Keep Current Year Ahead HICP Inflation Forecasts */
   drop if hicpAc == 0
               
   if (`year' == $start_year & `quarter' == $start_quarter) {
      save "${intermediate}/hicpAc.dta", replace
   }
   else {
      save "${intermediate}/temp.dta", replace
      append using "${intermediate}/hicpAc.dta"
      save "${intermediate}/hicpAc.dta", replace
   }

   restore

   preserve

   /* Create Dataset: Keep Next Year Ahead HICP Inflation Forecasts */
   drop if hicpBc == 0
               
   if (`year' == $start_year & `quarter' == $start_quarter) {
      save "${intermediate}/hicpBc.dta", replace
   }
   else {
      save "${intermediate}/temp.dta", replace
      append using "${intermediate}/hicpBc.dta"
      save "${intermediate}/hicpBc.dta", replace
   }

   restore
               
   preserve

   /* Create Dataset: Keep One Year Ahead HICP Inflation Forecast */
   drop if hicpAroll == 0
               
   if (`year' == $start_year & `quarter' == $start_quarter) {
      save "${intermediate}/hicpAroll.dta", replace
   }
   else {
      save "${intermediate}/temp.dta", replace
      append using "${intermediate}/hicpAroll.dta"
      save "${intermediate}/hicpAroll.dta", replace
   }

   restore
   preserve

   /* Create Dataset: Keep 1yr-1yr Forward HICP Inflation Forecast */
   drop if hicpBroll == 0
               
   if (`year' == $start_year & `quarter' == $start_quarter) {
      save "${intermediate}/hicpBroll.dta", replace
   }
   else {
      save "${intermediate}/temp.dta", replace
      append using "${intermediate}/hicpBroll.dta"
      save "${intermediate}/hicpBroll.dta", replace
   }

   restore
               
   preserve

   /* Create Dataset: Keep Two Year ahead HICP Inflation Forecast */
   drop if hicptwoyr == 0
               
   if (`year' == $start_year & `quarter' == $start_quarter) {
      save "${intermediate}/hicptwoyr.dta", replace
   }
   else {
      save "${intermediate}/temp.dta", replace 
      append using "${intermediate}/hicptwoyr.dta"
      save "${intermediate}/hicptwoyr.dta", replace
   }

   restore
               
   preserve

   /* Create Dataset: Keep Five Year ahead HICP Inflation Forecast */
   drop if hicpfiveyr == 0
               
   if (`year' == $start_year & `quarter' == $start_quarter) {
      save "${intermediate}/hicpfiveyr.dta", replace
   }
   else {
      save "${intermediate}/temp.dta", replace
      append using "${intermediate}/hicpfiveyr.dta"
      save "${intermediate}/hicpfiveyr.dta", replace
   }

   restore

   
/*****************************************************************************************/
/*****************************************************************************************/
/*****************************************************************************************/
   
   destring year, replace
   
   if (`year' == $end_year & `quarter' == $end_quarter) {
      local z = 1
   }
   
   local quarter = `quarter' + 1

   if `quarter' == 5 {
      local year = `year' + 1
      local quarter = 1
   }
}



use "${intermediate}/hicpAc.dta", clear
sort ydate qdate person
drop hicpAc hicpBc hicpAroll hicpBroll hicptwoyr hicpfiveyr

/* Generate Interval Groups */

capture confirm var group
if !_rc {
	disp "group defined"
}
else {
	disp "group not defined"
	gen group = 0
}

replace group = 1 if ydate == 1999 | (ydate == 2000 & qdate != 4) | (ydate >= 2001 & ydate < 2008) | (ydate == 2008 & (qdate == 1 | qdate == 2))
replace group = 2 if (ydate == 2000 & qdate == 4) | (ydate == 2008 & (qdate == 3 | qdate == 4)) | (ydate == 2009 & qdate == 1)
replace group = 3 if ydate == 2009 & (qdate == 2 | qdate == 3 | qdate == 4)
replace group = 4 if ydate >= 2010
replace group = 5 if (ydate == 2020 & qdate==2)

save, replace

use "${intermediate}/hicpBc.dta", clear
sort ydate qdate person
drop hicpAc hicpBc hicpAroll hicpBroll hicptwoyr hicpfiveyr


/* Generate Interval Groups */

capture confirm var group
if !_rc {
	disp "group defined"
}
else {
	disp "group not defined"
	gen group = 0
}

replace group = 1 if ydate == 1999 | (ydate == 2000 & qdate != 4) | (ydate >= 2001 & ydate < 2008) | (ydate == 2008 & (qdate == 1 | qdate == 2))
replace group = 2 if (ydate == 2000 & qdate == 4) | (ydate == 2008 & (qdate == 3 | qdate == 4)) | (ydate == 2009 & qdate == 1)
replace group = 3 if ydate == 2009 & (qdate == 2 | qdate == 3 | qdate == 4)
replace group = 4 if ydate >= 2010

save, replace

use "${intermediate}/hicpAroll.dta", clear
sort ydate qdate person
drop hicpAc hicpBc hicpAroll hicpBroll hicptwoyr hicpfiveyr


/* Generate Interval Groups */

capture confirm var group
if !_rc {
	disp "group defined"
}
else {
	disp "group not defined"
	gen group = 0
}

replace group = 1 if ydate == 1999 | (ydate == 2000 & qdate != 4) | (ydate >= 2001 & ydate < 2008) | (ydate == 2008 & (qdate == 1 | qdate == 2))
replace group = 2 if (ydate == 2000 & qdate == 4) | (ydate == 2008 & (qdate == 3 | qdate == 4)) | (ydate == 2009 & qdate == 1)
replace group = 3 if ydate == 2009 & (qdate == 2 | qdate == 3 | qdate == 4)
replace group = 4 if ydate >= 2010
replace group = 5 if (ydate == 2020 & qdate==2)

save, replace

use "${intermediate}/hicpBroll.dta", clear
sort ydate qdate person
drop hicpAc hicpBc hicpAroll hicpBroll hicptwoyr hicpfiveyr


/* Generate Interval Groups */

capture confirm var group
if !_rc {
	disp "group defined"
}
else {
	disp "group not defined"
	gen group = 0
}

replace group = 1 if ydate == 1999 | (ydate == 2000 & qdate != 4) | (ydate >= 2001 & ydate < 2008) | (ydate == 2008 & (qdate == 1 | qdate == 2))
replace group = 2 if (ydate == 2000 & qdate == 4) | (ydate == 2008 & (qdate == 3 | qdate == 4)) | (ydate == 2009 & qdate == 1)
replace group = 3 if ydate == 2009 & (qdate == 2 | qdate == 3 | qdate == 4)
replace group = 4 if ydate >= 2010
replace group = 5 if (ydate == 2020 & qdate==2)


save, replace

use "${intermediate}/hicptwoyr.dta", clear
sort ydate qdate person
drop hicpAc hicpBc hicpAroll hicpBroll hicptwoyr hicpfiveyr


/* Generate Interval Groups */

capture confirm var group
if !_rc {
	disp "group defined"
}
else {
	disp "group not defined"
	gen group = 0
}

replace group = 1 if ydate == 1999 | (ydate == 2000 & qdate != 4) | (ydate >= 2001 & ydate < 2008) | (ydate == 2008 & (qdate == 1 | qdate == 2))
replace group = 2 if (ydate == 2000 & qdate == 4) | (ydate == 2008 & (qdate == 3 | qdate == 4)) | (ydate == 2009 & qdate == 1)
replace group = 3 if ydate == 2009 & (qdate == 2 | qdate == 3 | qdate == 4)
replace group = 4 if ydate >= 2010
replace group = 5 if (ydate == 2020 & qdate==2)

save, replace

use "${intermediate}/hicpfiveyr.dta", clear
sort ydate qdate person
drop hicpAc hicpBc hicpAroll hicpBroll hicptwoyr hicpfiveyr


/* Generate Interval Groups */

capture confirm var group
if !_rc {
	disp "group defined"
}
else {
	disp "group not defined"
	gen group = 0
}

replace group = 1 if ydate == 1999 | (ydate == 2000 & qdate != 4) | (ydate >= 2001 & ydate < 2008) | (ydate == 2008 & (qdate == 1 | qdate == 2))
replace group = 2 if (ydate == 2000 & qdate == 4) | (ydate == 2008 & (qdate == 3 | qdate == 4)) | (ydate == 2009 & qdate == 1)
replace group = 3 if ydate == 2009 & (qdate == 2 | qdate == 3 | qdate == 4)
replace group = 4 if ydate >= 2010
replace group = 5 if (ydate == 2020 & qdate==2)

save, replace


   use "${intermediate}/temp_GDP_2000Q1.dta", clear
   
*	++++++++++++	*
*		GDP			*
*	++++++++++++	*
/*Parse & append the data by forecast horizons GDP */

local year = $start_year /*set year*/
local quarter = $start_quarter /*set quarter*/
local z = 0 /*set dummy*/

while `z' == 0 {
   
   use "${intermediate}/temp_GDP_`year'Q`quarter'.dta", clear

   /*************************************************/
   /* Create Dummies by Forecast Horizon            */
   /*************************************************/

   /*Current Calendar Year Horizon Dummy */
   gen gdpAc = 0
   replace gdpAc = 1 if (year == `year' & quarter == .)

   /* Next Calendar Year Horizon Dummy */
   gen gdpBc = 0
   replace gdpBc = 1 if (year == `year' + 1 & quarter == .)

   /* One Year Ahead Rolling Horizon Dummy */
   gen gdpAroll = 0
   replace gdpAroll = 1 if ((qdate == 1 | qdate == 2) & year == `year' & quarter != .)
   replace gdpAroll = 1 if ((qdate == 3 | qdate == 4) & year == `year' + 1 & quarter !=.)

   /* Two Year Ahead Rolling Horizon Dummy */
   gen gdpBroll = 0
   replace gdpBroll = 1 if ((qdate == 1 | qdate == 2) & year == `year' + 1  & quarter != .)
   replace gdpBroll = 1 if ((qdate == 3 | qdate == 4) & year == `year' + 2 & quarter !=.)

   /* Calendar Two Year Ahead Dummy */
   gen gdptwoyr = 0
   replace gdptwoyr = 1 if ((ydate > 1999 & (qdate == 3 | qdate == 4)) & year == `year' + 2 & quarter == .)

   /* Calendar Five Year Ahead Dummy */
   gen gdpfiveyr = 0
   replace gdpfiveyr = 1 if ((qdate == 1 & ydate == 1999) & year == `year' + 4 & quarter == .)
   replace gdpfiveyr = 1 if ((qdate == 1 & ydate == 2000) & year == `year' + 4 & quarter == .)
   replace gdpfiveyr = 1 if ((ydate > 2000 & (qdate == 1 | qdate == 2)) & year == `year' + 4 & quarter == .)
   replace gdpfiveyr = 1 if ((ydate > 2000 & (qdate == 3 | qdate == 4)) & year == `year' + 5 & quarter == .)

   if (`year' < 2000) {
      rename v4 a1
      rename v5 a2
      rename v6 a3
      rename v7 a4
      rename v8 a5
      rename v9 a6
      rename v10 a7
      rename v11 a8
      rename v12 a9
      rename v13 a10
      replace a1 = 0 if a1 == .
      replace a2 = 0 if a2 == .
      replace a3 = 0 if a3 == .
      replace a4 = 0 if a4 == .
      replace a5 = 0 if a5 == .
      replace a6 = 0 if a6 == .
      replace a7 = 0 if a7 == .
      replace a8 = 0 if a8 == .
      replace a9 = 0 if a9 == .
      replace a10 = 0 if a10 == .
      capture drop v*
   }
   else if (`year' ==  2000 & (`quarter' == 1)) {
      rename v4 a1
      rename v5 a2
      rename v6 a3
      rename v7 a4
      rename v8 a5
      rename v9 a6
      rename v10 a7
      rename v11 a8
      rename v12 a9
      rename v13 a10
      replace a1 = 0 if a1 == .
      replace a2 = 0 if a2 == .
      replace a3 = 0 if a3 == .
      replace a4 = 0 if a4 == .
      replace a5 = 0 if a5 == .
      replace a6 = 0 if a6 == .
      replace a7 = 0 if a7 == .
      replace a8 = 0 if a8 == .
      replace a9 = 0 if a9 == .
      replace a10 = 0 if a10 == .
      capture drop v*
   }
   else if (`year' == 2000 & (`quarter' == 2 | `quarter' == 3 | `quarter' == 4)) {
      rename v4 a1
      rename v5 a2
      rename v6 a3
      rename v7 a4
      rename v8 a5
      rename v9 a6
      rename v10 a7
      rename v11 a8
      rename v12 a9
      rename v13 a10
      rename v14 a11
      rename v15 a12
      replace a1 = 0 if a1 == .
      replace a2 = 0 if a2 == .
      replace a3 = 0 if a3 == .
      replace a4 = 0 if a4 == .
      replace a5 = 0 if a5 == .
      replace a6 = 0 if a6 == .
      replace a7 = 0 if a7 == .
      replace a8 = 0 if a8 == .
      replace a9 = 0 if a9 == .
      replace a10 = 0 if a10 == .
      replace a11 = 0 if a11 == .
      replace a12 = 0 if a12 == .
      capture drop v*
   }
   else if (`year' > 2000 & `year' <2008){
      rename v4 a1
      rename v5 a2
      rename v6 a3
      rename v7 a4
      rename v8 a5
      rename v9 a6
      rename v10 a7
      rename v11 a8
      rename v12 a9
      rename v13 a10
      replace a1 = 0 if a1 == .
      replace a2 = 0 if a2 == .
      replace a3 = 0 if a3 == .
      replace a4 = 0 if a4 == .
      replace a5 = 0 if a5 == .
      replace a6 = 0 if a6 == .
      replace a7 = 0 if a7 == .
      replace a8 = 0 if a8 == .
      replace a9 = 0 if a9 == .
      replace a10 = 0 if a10 == .
      capture drop v*
   }
   else if (`year' == 2008 & (`quarter' == 1 | `quarter' == 2 | `quarter' == 3)) {
      rename v4 a1
      rename v5 a2
      rename v6 a3
      rename v7 a4
      rename v8 a5
      rename v9 a6
      rename v10 a7
      rename v11 a8
      rename v12 a9
      rename v13 a10 
      replace a1 = 0 if a1 == .
      replace a2 = 0 if a2 == .
      replace a3 = 0 if a3 == .
      replace a4 = 0 if a4 == .
      replace a5 = 0 if a5 == .
      replace a6 = 0 if a6 == .
      replace a7 = 0 if a7 == .
      replace a8 = 0 if a8 == .
      replace a9 = 0 if a9 == .
      replace a10 = 0 if a10 == .
      capture drop v*
   }
   else if (`year' == 2008 & (`quarter' == 4)) {
      rename v4 a1
      rename v5 a2
      rename v6 a3
      rename v7 a4
      rename v8 a5
      rename v9 a6
      rename v10 a7
      rename v11 a8
      rename v12 a9
      rename v13 a10
      rename v14 a11
      rename v15 a12
      replace a1 = 0 if a1 == .
      replace a2 = 0 if a2 == .
      replace a3 = 0 if a3 == .
      replace a4 = 0 if a4 == .
      replace a5 = 0 if a5 == .
      replace a6 = 0 if a6 == .
      replace a7 = 0 if a7 == .
      replace a8 = 0 if a8 == .
      replace a9 = 0 if a9 == .
      replace a10 = 0 if a10 == .
      replace a11 = 0 if a11 == .
      replace a12 = 0 if a12 == .
      capture drop v*
   }
   else if (`year' == 2009 & `quarter' == 1) {
      rename v4 a1
      rename v5 a2
      rename v6 a3
      rename v7 a4
      rename v8 a5
      rename v9 a6
      rename v10 a7
      rename v11 a8
      rename v12 a9
      rename v13 a10
      rename v14 a11
      rename v15 a12
      replace a1 = 0 if a1 == .
      replace a2 = 0 if a2 == .
      replace a3 = 0 if a3 == .
      replace a4 = 0 if a4 == .
      replace a5 = 0 if a5 == .
      replace a6 = 0 if a6 == .
      replace a7 = 0 if a7 == .
      replace a8 = 0 if a8 == .
      replace a9 = 0 if a9 == .
      replace a10 = 0 if a10 == .
      replace a11 = 0 if a11 == .
      replace a12 = 0 if a12 == .
      capture drop v*
   }


   else if (`year' == 2009 & (`quarter' == 2 | `quarter' == 3 | `quarter' == 4)) | (`year' == 2020 & `quarter' == 2)  {
      rename v4 a1
      rename v5 a2
      rename v6 a3
      rename v7 a4
      rename v8 a5
      rename v9 a6
      rename v10 a7
      rename v11 a8
      rename v12 a9
      rename v13 a10
      rename v14 a11
      rename v15 a12
      rename v16 a13
      rename v17 a14
      rename v18 a15
      rename v19 a16
      rename v20 a17
      rename v21 a18
      rename v22 a19
      rename v23 a20
      rename v24 a21
      rename v25 a22
      replace a1 = 0 if a1 == .
      replace a2 = 0 if a2 == .
      replace a3 = 0 if a3 == .
      replace a4 = 0 if a4 == .
      replace a5 = 0 if a5 == .
      replace a6 = 0 if a6 == .
      replace a7 = 0 if a7 == .
      replace a8 = 0 if a8 == .
      replace a9 = 0 if a9 == .
      replace a10 = 0 if a10 == .
      replace a11 = 0 if a11 == .
      replace a12 = 0 if a12 == .
      replace a13 = 0 if a13 == .
      replace a14 = 0 if a14 == .
      replace a15 = 0 if a15 == .
      replace a16 = 0 if a16 == .
      replace a17 = 0 if a17 == .
      replace a18 = 0 if a18 == .
      replace a19 = 0 if a19 == .
      replace a20 = 0 if a20 == .
      replace a21 = 0 if a21 == .
      replace a22 = 0 if a22 == .
      capture drop v*
   }
   else if (`year' > 2009) {
      rename v4 a1
      rename v5 a2
      rename v6 a3
      rename v7 a4
      rename v8 a5
      rename v9 a6
      rename v10 a7
      rename v11 a8
      rename v12 a9
      rename v13 a10
      rename v14 a11
      rename v15 a12
      replace a1 = 0 if a1 == .
      replace a2 = 0 if a2 == .
      replace a3 = 0 if a3 == .
      replace a4 = 0 if a4 == .
      replace a5 = 0 if a5 == .
      replace a6 = 0 if a6 == .
      replace a7 = 0 if a7 == .
      replace a8 = 0 if a8 == .
      replace a9 = 0 if a9 == .
      replace a10 = 0 if a10 == .
      replace a11 = 0 if a11 == .
      replace a12 = 0 if a12 == .
      capture drop v*      
   }
   
   foreach i of numlist 1(1)22 {
	capture replace a`i' = a`i'/100
   }     
          
   preserve

   /* Create Dataset: Keep Current Year GDP forecast */
   drop if gdpAc == 0
               
   if (`year' == $start_year & `quarter' == $start_quarter) {
      save "${intermediate}/gdpAc.dta", replace
   }
   else {
      save "${intermediate}/temp.dta", replace
      append using "${intermediate}/gdpAc.dta"
      save "${intermediate}/gdpAc.dta", replace
   }

   restore

   preserve

   /* Create Dataset: Keep Next Year GDP forecast */
   drop if gdpBc == 0
               
   if (`year' == $start_year & `quarter' == $start_quarter) {
      save "${intermediate}/gdpBc.dta", replace
   }
   else {
      save "${intermediate}/temp.dta", replace
      append using "${intermediate}/gdpBc.dta"
      save "${intermediate}/gdpBc.dta", replace
   }

   restore
               
   preserve

   /* Create Dataset: Keep One Year Ahead Rolling GDP forecast */
   drop if gdpAroll == 0
               
   if (`year' == $start_year & `quarter' == $start_quarter) {
      save "${intermediate}/gdpAroll.dta", replace
   }
   else {
      save "${intermediate}/temp.dta", replace
      append using "${intermediate}/gdpAroll.dta"
      save "${intermediate}/gdpAroll.dta", replace
   }

   restore
   preserve

   /* Create Dataset: Keep 1yr-1yr Forward Rolling GDP forecast */
   
   drop if gdpBroll == 0
               
   if (`year' == $start_year & `quarter' == $start_quarter) {
      save "${intermediate}/gdpBroll.dta", replace
   }
   else {
      save "${intermediate}/temp.dta", replace
      append using "${intermediate}/gdpBroll.dta"
      save "${intermediate}/gdpBroll.dta", replace
   }

   restore
               
   preserve

   /* Create Dataset: Keep Two year ahead GDP forecast */
   drop if gdptwoyr == 0
               
   if (`year' == $start_year & `quarter' == $start_quarter) {
      save "${intermediate}/gdptwoyr.dta", replace
   }
   else {
      save "${intermediate}/temp.dta", replace 
      append using "${intermediate}/gdptwoyr.dta"
      save "${intermediate}/gdptwoyr.dta", replace
   }

   restore
               
   preserve

   /* Create Dataset: Keep Five year ahead GDP forecast */
   drop if gdpfiveyr == 0
               
   if (`year' == $start_year & `quarter' == $start_quarter) {
      save "${intermediate}/gdpfiveyr.dta", replace
   }
   else {
      save "${intermediate}/temp.dta", replace
      append using  "${intermediate}/gdpfiveyr.dta"
      save "${intermediate}/gdpfiveyr.dta", replace
   }

   restore

   if (`year' == $end_year & `quarter' == $end_quarter) {
      local z = 1
   }
   
   local quarter = `quarter' + 1

   if `quarter' == 5 {
      local year = `year' + 1
      local quarter = 1
   }
}


/* Clean Final Data Set */

use "${intermediate}/gdpAc.dta", clear

capture confirm var group
if !_rc {
	disp "group defined"
}
else {
	disp "mdate not defined"
	gen group = 0
}

replace group = 1 if ydate == 1999 | ydate == 2000 & qdate == 1| (ydate >= 2001 & ydate < 2008) | (ydate == 2008 & (qdate == 1 | qdate == 2 | qdate == 3))
replace group = 2 if ydate == 2000 & (qdate == 2 | qdate == 3 | qdate == 4)
replace group = 3 if (ydate == 2008 & qdate == 4) | (ydate == 2009 & qdate == 1) |ydate >= 2010
replace group = 4 if ydate == 2009 & (qdate == 2 | qdate == 3 | qdate == 4)
replace group = 5 if (ydate == 2020 & qdate==2)


sort ydate qdate person
drop gdpAc gdpBc gdpAroll gdpBroll gdptwoyr gdpfiveyr

save, replace

use "${intermediate}/gdpBc.dta", clear

capture confirm var group
if !_rc {
	disp "group defined"
}
else {
	disp "mdate not defined"
	gen group = 0
}

replace group = 1 if ydate == 1999 | ydate == 2000 & qdate == 1| (ydate >= 2001 & ydate < 2008) | (ydate == 2008 & (qdate == 1 | qdate == 2 | qdate == 3))
replace group = 2 if ydate == 2000 & (qdate == 2 | qdate == 3 | qdate == 4)
replace group = 3 if (ydate == 2008 & qdate == 4) | (ydate == 2009 & qdate == 1) | ydate >= 2010
replace group = 4 if ydate == 2009 & (qdate == 2 | qdate == 3 | qdate == 4)
replace group = 5 if (ydate == 2020 & qdate==2)


sort ydate qdate person
drop gdpAc gdpBc gdpAroll gdpBroll gdptwoyr gdpfiveyr
save, replace

use "${intermediate}/gdpAroll.dta", clear


capture confirm var group
if !_rc {
	disp "group defined"
}
else {
	disp "mdate not defined"
	gen group = 0
}

replace group = 1 if ydate == 1999 | ydate == 2000 & qdate == 1| (ydate >= 2001 & ydate < 2008) | (ydate == 2008 & (qdate == 1 | qdate == 2 | qdate == 3))
replace group = 2 if ydate == 2000 & (qdate == 2 | qdate == 3 | qdate == 4)
replace group = 3 if (ydate == 2008 & qdate == 4) | (ydate == 2009 & qdate == 1) |ydate >= 2010
replace group = 4 if ydate == 2009 & (qdate == 2 | qdate == 3 | qdate == 4)
replace group = 5 if (ydate == 2020 & qdate==2)


sort ydate qdate person
drop gdpAc gdpBc gdpAroll gdpBroll gdptwoyr gdpfiveyr
save, replace

use "${intermediate}/gdpBroll.dta", clear


capture confirm var group
if !_rc {
	disp "group defined"
}
else {
	disp "mdate not defined"
	gen group = 0
}

replace group = 1 if ydate == 1999 | ydate == 2000 & qdate == 1| (ydate >= 2001 & ydate < 2008) | (ydate == 2008 & (qdate == 1 | qdate == 2 | qdate == 3))
replace group = 2 if ydate == 2000 & (qdate == 2 | qdate == 3 | qdate == 4)
replace group = 3 if (ydate == 2008 & qdate == 4) | (ydate == 2009 & qdate == 1) |ydate >= 2010
replace group = 4 if ydate == 2009 & (qdate == 2 | qdate == 3 | qdate == 4)
replace group = 5 if (ydate == 2020 & qdate==2)


sort ydate qdate person
drop gdpAc gdpBc gdpAroll gdpBroll gdptwoyr gdpfiveyr
save, replace

use "${intermediate}/gdptwoyr.dta", clear


capture confirm var group
if !_rc {
	disp "group defined"
}
else {
	disp "mdate not defined"
	gen group = 0
}

replace group = 1 if ydate == 1999 | ydate == 2000 & qdate == 1| (ydate >= 2001 & ydate < 2008) | (ydate == 2008 & (qdate == 1 | qdate == 2 | qdate == 3))
replace group = 2 if ydate == 2000 & (qdate == 2 | qdate == 3 | qdate == 4)
replace group = 3 if (ydate == 2008 & qdate == 4) | (ydate == 2009 & qdate == 1) |ydate >= 2010
replace group = 4 if ydate == 2009 & (qdate == 2 | qdate == 3 | qdate == 4)
replace group = 5 if (ydate == 2020 & qdate==2)


sort ydate qdate person
drop gdpAc gdpBc gdpAroll gdpBroll gdptwoyr gdpfiveyr
save, replace

use "${intermediate}/gdpfiveyr.dta", clear


capture confirm var group
if !_rc {
	disp "group defined"
}
else {
	disp "mdate not defined"
	gen group = 0
}

replace group = 1 if ydate == 1999 | ydate == 2000 & qdate == 1| (ydate >= 2001 & ydate < 2008) | (ydate == 2008 & (qdate == 1 | qdate == 2 | qdate == 3))
replace group = 2 if ydate == 2000 & (qdate == 2 | qdate == 3 | qdate == 4)
replace group = 3 if (ydate == 2008 & qdate == 4) | (ydate == 2009 & qdate == 1) |ydate >= 2010
replace group = 4 if ydate == 2009 & (qdate == 2 | qdate == 3 | qdate == 4)
replace group = 5 if (ydate == 2020 & qdate==2)

sort ydate qdate person
drop gdpAc gdpBc gdpAroll gdpBroll gdptwoyr gdpfiveyr
save, replace
*/

*	++++++++++++	*
*	UNEMPLOYMENT	*
*	++++++++++++	*

/*Parse & append the data by forecast horizons */

local year = $start_year /*set year*/
local quarter = $start_quarter /*set quarter*/
local z = 0 /*set dummy*/

while `z' == 0 {
   
   use "${intermediate}/temp_unemployment_`year'Q`quarter'.dta", clear

   /********************************************************************/
   /* Create Dummies by forecast horizons                              */
   /********************************************************************/
   
   /*Current Calendar Year Horizon Dummy */
   gen urateAc = 0
   replace urateAc = 1 if (year == `year' & month == .)
   label var urateAc "Current Year Unemployment Expectation"
   
   /* Next Calendar Year Horizon Dummy */
   gen urateBc = 0
   replace urateBc = 1 if (year == `year' + 1 & month == .)
   label var urateBc "Next Year Unemployment Expectation"
   
   /* One Year Ahead Rolling Horizon Dummy */
   gen urateAroll = 0
   replace urateAroll = 1 if (qdate == 1 & year == `year' & month != .)
   replace urateAroll = 1 if ((qdate == 2 | qdate == 3 | qdate == 4) & year == `year' + 1 & month !=.)
   label var urateAroll "Rolling 1 Yr ahead Unemployment Expectation"
   
   /* One Year- One Year Forward Rolling Horizon Dummy */
   gen urateBroll = 0
   replace urateBroll = 1 if (qdate == 1 & year == `year' + 1 & month != .)
   replace urateBroll = 1 if ((qdate == 2 | qdate == 3 | qdate == 4) & year == `year' + 2 & month !=.)
   label var urateBroll "Rolling 1YR-1YR forward Unemployment Expectation"
   
   /* Calendar Two Year Ahead Dummy */
   gen uratetwoyr = 0
   replace uratetwoyr = 1 if ((ydate > 1999 & (qdate == 3 | qdate == 4)) & year == `year' + 2 & month == .)
   label var uratetwoyr "Two Year ahead Unemployment Expectation"
   
   /* Calendar Five Year Ahead Dummy */
   gen uratefiveyr = 0
   replace uratefiveyr = 1 if ((qdate == 1 & ydate == 1999) & year == `year' + 4 & month == .)
   replace uratefiveyr = 1 if ((qdate == 1 & ydate == 2000) & year == `year' + 4 & month == .)
   replace uratefiveyr = 1 if ((ydate > 2000 & (qdate == 1 | qdate == 2)) & year == `year' + 4 & month == .)
   replace uratefiveyr = 1 if ((ydate > 2000 & (qdate == 3 | qdate == 4)) & year == `year' + 5 & month == .)
   label var uratefiveyr "Five Year ahead Unemployment Expectation"

   /* Rename Variables by "bins" */
   /* Number of bins have changed across time. The loop changes how many "bins" are created*/
   * ----------------------------------------------------------------  
   * Group 1 
   if (`year' == 1999) | (`year' == 2000 & `quarter' == 1) {
      rename v4 a1
      rename v5 a2
      rename v6 a3
      rename v7 a4
      rename v8 a5
      rename v9 a6
      rename v10 a7
      rename v11 a8
      replace a1 = 0 if a1 == .
      replace a2 = 0 if a2 == .
      replace a3 = 0 if a3 == .
      replace a4 = 0 if a4 == .
      replace a5 = 0 if a5 == .
      replace a6 = 0 if a6 == .
      replace a7 = 0 if a7 == .
      replace a8 = 0 if a8 == .
      capture drop v*
   }
   * ----------------------------------------------------------------  
   * Group 2 
   else if (`year' == 2000 & `quarter' == 2){
      rename v4 a1
      rename v5 a2
      rename v6 a3
      rename v7 a4
      rename v8 a5
      rename v9 a6
      rename v10 a7
      rename v11 a8
      rename v12 a9
      rename v13 a10
      rename v14 a11
      replace a1 = 0 if a1 == .
      replace a2 = 0 if a2 == .
      replace a3 = 0 if a3 == .
      replace a4 = 0 if a4 == .
      replace a5 = 0 if a5 == .
      replace a6 = 0 if a6 == .
      replace a7 = 0 if a7 == .
      replace a8 = 0 if a8 == .
      replace a9 = 0 if a9 == .
      replace a10 = 0 if a10 == .
      replace a11 = 0 if a11 == .
      capture drop v*
   }  
   * ----------------------------------------------------------------  
   * Group 3 
   else if (`year' ==  2000 & (`quarter' == 3 | `quarter' == 4)) {
      rename v4 a1
      rename v5 a2
      rename v6 a3
      rename v7 a4
      rename v8 a5
      rename v9 a6
      rename v10 a7
      rename v11 a8
      rename v12 a9
      rename v13 a10
      rename v14 a11
      replace a1 = 0 if a1 == .
      replace a2 = 0 if a2 == .
      replace a3 = 0 if a3 == .
      replace a4 = 0 if a4 == .
      replace a5 = 0 if a5 == .
      replace a6 = 0 if a6 == .
      replace a7 = 0 if a7 == .
      replace a8 = 0 if a8 == .
      replace a9 = 0 if a9 == .
      replace a10 = 0 if a10 == .
      replace a11 = 0 if a11 == .
      capture drop v*
   }
   * ----------------------------------------------------------------  
   * Group 4
   else if (`year' == 2001 | (`year' == 2002 & `quarter' == 1)) {
      rename v4 a1
      rename v5 a2
      rename v6 a3
      rename v7 a4
      rename v8 a5
      rename v9 a6
      rename v10 a7
      rename v11 a8
      rename v12 a9
      rename v13 a10
      rename v14 a11
      rename v15 a12
      rename v16 a13
      replace a1 = 0 if a1 == .
      replace a2 = 0 if a2 == .
      replace a3 = 0 if a3 == .
      replace a4 = 0 if a4 == .
      replace a5 = 0 if a5 == .
      replace a6 = 0 if a6 == .
      replace a7 = 0 if a7 == .
      replace a8 = 0 if a8 == .
      replace a9 = 0 if a9 == .
      replace a10 = 0 if a10 == .
      replace a11 = 0 if a11 == .
      replace a12 = 0 if a12 == .
      replace a13 = 0 if a13 == .
      capture drop v*
   }
   * ----------------------------------------------------------------  
   * Group 5
   else if ((`year' ==  2002 & `quarter' != 1) | (`year' >= 2003 & `year' <= 2008) | (`year' == 2009 & `quarter' == 1)){
      rename v4 a1
      rename v5 a2
      rename v6 a3
      rename v7 a4
      rename v8 a5
      rename v9 a6
      rename v10 a7
      rename v11 a8
      rename v12 a9
      rename v13 a10
      rename v14 a11
      rename v15 a12
      rename v16 a13
      replace a1 = 0 if a1 == .
      replace a2 = 0 if a2 == .
      replace a3 = 0 if a3 == .
      replace a4 = 0 if a4 == .
      replace a5 = 0 if a5 == .
      replace a6 = 0 if a6 == .
      replace a7 = 0 if a7 == .
      replace a8 = 0 if a8 == .
      replace a9 = 0 if a9 == .
      replace a10 = 0 if a10 == .
      replace a11 = 0 if a11 == .
      replace a12 = 0 if a12 == .
      replace a13 = 0 if a13 == .
      capture drop v*
   }
   * ----------------------------------------------------------------  
   * Group 6
   else if (`year' == 2009 & (`quarter' == 2 | `quarter' == 3 | `quarter' == 4)) | (`year' > 2017)  {
      rename v4 a1
      rename v5 a2
      rename v6 a3
      rename v7 a4
      rename v8 a5
      rename v9 a6
      rename v10 a7
      rename v11 a8
      rename v12 a9
      rename v13 a10
      rename v14 a11
      rename v15 a12
      rename v16 a13
      rename v17 a14
      rename v18 a15
      rename v19 a16
      rename v20 a17
      rename v21 a18
      rename v22 a19
      rename v23 a20
      rename v24 a21
      
      replace a1 = 0 if a1 == .
      replace a2 = 0 if a2 == .
      replace a3 = 0 if a3 == .
      replace a4 = 0 if a4 == .
      replace a5 = 0 if a5 == .
      replace a6 = 0 if a6 == .
      replace a7 = 0 if a7 == .
      replace a8 = 0 if a8 == .
      replace a9 = 0 if a9 == .         
      replace a10 = 0 if a10 == .         
      replace a11 = 0 if a11 == .         
      replace a12 = 0 if a12 == .         
      replace a13 = 0 if a13 == .         
      replace a14 = 0 if a14 == .         
      replace a15 = 0 if a15 == .         
      replace a16 = 0 if a16 == .         
      replace a17 = 0 if a17 == .         
      replace a18= 0 if a18 == .         
      replace a19 = 0 if a19 == .         
      replace a20 = 0 if a20 == .         
      replace a21 = 0 if a21 == .         

      capture drop v*
   }
   * ----------------------------------------------------------------  
   * Group 7 
   else if (`year' >= 2010 & `year' <= 2017) {

      rename v4 a1
      rename v5 a2
      rename v6 a3
      rename v7 a4
      rename v8 a5
      rename v9 a6
      rename v10 a7
      rename v11 a8
      rename v12 a9
      rename v13 a10
      rename v14 a11
      rename v15 a12
      rename v16 a13
      rename v17 a14
      rename v18 a15
      rename v19 a16
      rename v20 a17
      rename v21 a18
      rename v22 a19
      replace a1 = 0 if a1 == .
      replace a2 = 0 if a2 == .
      replace a3 = 0 if a3 == .
      replace a4 = 0 if a4 == .
      replace a5 = 0 if a5 == .
      replace a6 = 0 if a6 == .
      replace a7 = 0 if a7 == .
      replace a8 = 0 if a8 == .
      replace a9 = 0 if a9 == .
      replace a10 = 0 if a10 == .
      replace a11 = 0 if a11 == .
      replace a12 = 0 if a12 == .
      replace a13 = 0 if a13 == .
      replace a14 = 0 if a14 == .
      replace a15 = 0 if a15 == .
      replace a16 = 0 if a16 == .
      replace a17 = 0 if a17 == .
      replace a18 = 0 if a18 == .
      replace a19 = 0 if a19 == .
      capture drop v*
   }
   
* ----------------------------------------------------------------  
   foreach i of numlist 1(1)19 {
	capture replace a`i' = a`i'/100
   }
               
   preserve

   /* Create Dataset: Keep Current Year Ahead Unemployment Forecasts */
   drop if urateAc == 0
               
   if (`year' == 1999 & `quarter' == 1) {
      save "${intermediate}/urateAc.dta", replace
   }
   else {
      save "${intermediate}/temp.dta", replace
      append using "${intermediate}/urateAc.dta"
      save "${intermediate}/urateAc.dta", replace
   }

   restore

   preserve

   /* Create Dataset: Keep Next Year Ahead Unemployment Forecasts */
   drop if urateBc == 0
               
   if (`year' == 1999 & `quarter' == 1) {
      save "${intermediate}/urateBc.dta", replace
   }
   else {
      save "${intermediate}/temp.dta", replace
      append using "${intermediate}/urateBc.dta"
      save "${intermediate}/urateBc.dta", replace
   }

   restore
               
   preserve

   /* Create Dataset: Keep One Year Ahead Unemployment Forecast */
   drop if urateAroll == 0
               
   if (`year' == 1999 & `quarter' == 1) {
      save "${intermediate}/urateAroll.dta", replace
   }
   else {
      save "${intermediate}/temp.dta", replace
      append using "${intermediate}/urateAroll.dta"
      save "${intermediate}/urateAroll.dta", replace
   }

   restore
   preserve

   /* Create Dataset: Keep 1yr-1yr Forward Unemployment Forecast */
   drop if urateBroll == 0
               
   if (`year' == 1999 & `quarter' == 1) {
      save "${intermediate}/urateBroll.dta", replace
   }
   else {
      save "${intermediate}/temp.dta", replace
      append using "${intermediate}/urateBroll.dta"
      save "${intermediate}/urateBroll.dta", replace
   }

   restore
               
   preserve

   /* Create Dataset: Keep Two Year ahead Unemployment Forecast */
   drop if uratetwoyr == 0
               
   if (`year' == 1999 & `quarter' == 1) {
      save "${intermediate}/uratetwoyr.dta", replace
   }
   else {
      save "${intermediate}/temp.dta", replace 
      append using "${intermediate}/uratetwoyr.dta"
      save "${intermediate}/uratetwoyr.dta", replace
   }

   restore
               
   preserve

   /* Create Dataset: Keep Five Year ahead Unemployment Forecast */
   drop if uratefiveyr == 0
               
   if (`year' == 1999 & `quarter' == 1) {
      save "${intermediate}/uratefiveyr.dta", replace
   }
   else {
      save "${intermediate}/temp.dta", replace
      append using  "${intermediate}/uratefiveyr.dta"
      save "${intermediate}/uratefiveyr.dta", replace
   }

   restore

   
/*****************************************************************************************/
/*****************************************************************************************/
/*****************************************************************************************/
   

   if (`year' == $end_year & `quarter' == $end_quarter) {
      local z = 1
   }
   
   local quarter = `quarter' + 1

   if `quarter' == 5 {
      local year = `year' + 1
      local quarter = 1
   }
}

use "${intermediate}/urateAc.dta", clear
sort ydate qdate person
drop urateAc urateBc urateAroll urateBroll uratetwoyr uratefiveyr

/* Generate Interval Groups */

capture confirm var group
if !_rc {
	disp "group defined"
}
else {
	disp "group not defined"
	gen group = 0
}

replace group = 1 if ydate == 1999 | (ydate == 2000 & qdate == 1)
replace group = 2 if ydate == 2000 & qdate == 2
replace group = 3 if ydate == 2000 & (qdate == 3 | qdate == 4)
replace group = 4 if ydate == 2001 | (ydate == 2002 & qdate == 1)
replace group = 5 if (ydate == 2002 & qdate != 1) | (ydate >=2003 & ydate <=2008) | (ydate == 2009 & qdate == 1) 
replace group = 6 if (ydate == 2009 & qdate != 1) | (ydate > 2017)
replace group = 7 if (ydate >= 2010 & ydate <= 2017)


save, replace

use "${intermediate}/urateBc.dta", clear
sort ydate qdate person
drop urateAc urateBc urateAroll urateBroll uratetwoyr uratefiveyr


/* Generate Interval Groups */

capture confirm var group
if !_rc {
	disp "group defined"
}
else {
	disp "group not defined"
	gen group = 0
}

replace group = 1 if ydate == 1999 | (ydate == 2000 & qdate == 1)
replace group = 2 if ydate == 2000 & qdate == 2
replace group = 3 if ydate == 2000 & (qdate == 3 | qdate == 4)
replace group = 4 if ydate == 2001 | (ydate == 2002 & qdate == 1)
replace group = 5 if (ydate == 2002 & qdate != 1) | (ydate >=2003 & ydate <=2008) | (ydate == 2009 & qdate == 1) 
replace group = 6 if (ydate == 2009 & qdate != 1) | (ydate > 2017)
replace group = 7 if (ydate >= 2010 & ydate <= 2017)



save, replace

use "${intermediate}/urateAroll.dta", clear
sort ydate qdate person
drop urateAc urateBc urateAroll urateBroll uratetwoyr uratefiveyr


/* Generate Interval Groups */

capture confirm var group
if !_rc {
	disp "group defined"
}
else {
	disp "group not defined"
	gen group = 0
}

replace group = 1 if ydate == 1999 | (ydate == 2000 & qdate == 1)
replace group = 2 if ydate == 2000 & qdate == 2
replace group = 3 if ydate == 2000 & (qdate == 3 | qdate == 4)
replace group = 4 if ydate == 2001 | (ydate == 2002 & qdate == 1)
replace group = 5 if (ydate == 2002 & qdate != 1) | (ydate >=2003 & ydate <=2008) | (ydate == 2009 & qdate == 1) 
replace group = 6 if (ydate == 2009 & qdate != 1) | (ydate > 2017)
replace group = 7 if (ydate >= 2010 & ydate <= 2017)


save, replace

use "${intermediate}/urateBroll.dta", clear
sort ydate qdate person
drop urateAc urateBc urateAroll urateBroll uratetwoyr uratefiveyr


/* Generate Interval Groups */

capture confirm var group
if !_rc {
	disp "group defined"
}
else {
	disp "mdate not defined"
	gen group = 0
}

replace group = 1 if ydate == 1999 | (ydate == 2000 & qdate == 1)
replace group = 2 if ydate == 2000 & qdate == 2
replace group = 3 if ydate == 2000 & (qdate == 3 | qdate == 4)
replace group = 4 if ydate == 2001 | (ydate == 2002 & qdate == 1)
replace group = 5 if (ydate == 2002 & qdate != 1) | (ydate >=2003 & ydate <=2008) | (ydate == 2009 & qdate == 1) 
replace group = 6 if (ydate == 2009 & qdate != 1) | (ydate > 2017)
replace group = 7 if (ydate >= 2010 & ydate <= 2017)


save, replace

use "${intermediate}/uratetwoyr.dta", clear
sort ydate qdate person
drop urateAc urateBc urateAroll urateBroll uratetwoyr uratefiveyr


/* Generate Interval Groups */

capture confirm var group
if !_rc {
	disp "group defined"
}
else {
	disp "group not defined"
	gen group = 0
}

replace group = 1 if ydate == 1999 | (ydate == 2000 & qdate == 1)
replace group = 2 if ydate == 2000 & qdate == 2
replace group = 3 if ydate == 2000 & (qdate == 3 | qdate == 4)
replace group = 4 if ydate == 2001 | (ydate == 2002 & qdate == 1)
replace group = 5 if (ydate == 2002 & qdate != 1) | (ydate >=2003 & ydate <=2008) | (ydate == 2009 & qdate == 1) 
replace group = 6 if (ydate == 2009 & qdate != 1) | (ydate > 2017)
replace group = 7 if (ydate >= 2010 & ydate <= 2017)

save, replace

use "${intermediate}/uratefiveyr.dta", clear
sort ydate qdate person
drop urateAc urateBc urateAroll urateBroll uratetwoyr uratefiveyr


/* Generate Interval Groups */

capture confirm var group
if !_rc {
	disp "group defined"
}
else {
	disp "group not defined"
	gen group = 0
}

replace group = 1 if ydate == 1999 | (ydate == 2000 & qdate == 1)
replace group = 2 if ydate == 2000 & qdate == 2
replace group = 3 if ydate == 2000 & (qdate == 3 | qdate == 4)
replace group = 4 if ydate == 2001 | (ydate == 2002 & qdate == 1)
replace group = 5 if (ydate == 2002 & qdate != 1) | (ydate >=2003 & ydate <=2008) | (ydate == 2009 & qdate == 1) 
replace group = 6 if (ydate == 2009 & qdate != 1) | (ydate > 2017)
replace group = 7 if (ydate >= 2010 & ydate <= 2017)


save, replace


/* Erase Temp Files */

local year = $start_year /* set starting year */
local quarter = $start_quarter /* set starting quarter */
local z = 0 /*set dummy to trigger to get out of loop */

while `z' == 0 {

   erase "${intermediate}/temp_GDP_`year'Q`quarter'.dta"
   erase "${intermediate}/temp_inflation_`year'Q`quarter'.dta"
   erase "${intermediate}/temp_unemployment_`year'Q`quarter'.dta"

  
   if (`year' == $end_year & `quarter' == $end_quarter) {
      local z = 1
   }
   
   local quarter = `quarter' + 1

   if `quarter' == 5 {
      local year = `year' + 1
      local quarter = 1
   }
}

erase "${intermediate}/temp.dta"


