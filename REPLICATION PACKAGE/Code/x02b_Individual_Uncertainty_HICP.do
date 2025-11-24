*======================================================================
* x02b_Individual_Uncertainty_HICP.do
*====================================================================== 
/**********************************************************************
	Description: Creates percentile by individual forecast distribution.
**********************************************************************/
clear 
set mem 100000 
set more off 

local data "Ac Bc Aroll Broll" 
foreach sampcut in /*5 10 15 20 25 zzz - commented all but 100*/ 100 { 
foreach x of local data { 

   use "${intermediate}/hicp`x'.dta", clear 
//    drop nopoint total sum0 sum1 

   bys person: gen sample_N = _N 
   if `sampcut' != 100 { 
   drop if sample_N < `sampcut' 
   } 
   
   
			*Restrict sample 
			gen nopoint = 0 
			replace nopoint = 1 if point == . 
			egen total = rowtotal(a*) 

			gen sum0 = 0 
			replace sum0 = 1 if total == 0 
			label variable sum0 "missing density forecast" 

			gen sum1 = 0 
			replace sum1=1 if total <=.991  | total >=1.009 
			label variable sum1 "probabilities do not sum to unity" 
			
   drop if sum0 == 1 
   drop if sum1 == 1 
   drop if nopoint == 1 

/* Create Mean and Dispersion Measure from the Point Forecastps by quarter */ 
   bysort ydate qdate: egen disperse = sd(point) 
   bysort ydate qdate: egen mean = mean(point) 

/* Create zscore to exclude any outliers within the point forecasts */ 
   gen zscore = abs((point-mean)/disperse) 
   count if zscore > 3 
   drop zscore mean disperse 

   // Declare Year and Quarter Variables and dummy z variable which stops the loop once it reaches the last quarter of data 
   local yy = 1999 
   local qq = 1 
   local z = 0 
   local endpoint = 1 
   local group = 0 
   

   // Create left endpoint values for each bin ("b")
   while (`z' == 0) { 
      preserve 
      keep if ydate == `yy' & qdate == `qq' 

      if (`yy' == 1999) | (`yy' == 2000 & `qq' == 1) | (`yy' == 2000 & `qq' == 2)| (`yy'==2000 & `qq' == 3) | (`yy' >= 2001 & `yy' <= 2007) | (`yy' == 2008 & `qq' == 1) | (`yy' == 2008 & `qq' == 2) { 

      gen left2 = -0.05 
      gen left3 = 0.45 
      gen left4 = 0.95 
      gen left5 = 1.45 
      gen left6 = 1.95 
      gen left7 = 2.45 
      gen left8 = 2.95 
      gen left9 = 3.45 

         if `endpoint' == 1 { 
            gen left1 = -0.5 
         } 
         else if `endpoint' == 2 { 
            gen left1 = -1.0 
         } 
         else if `endpoint' == 3 { 
            gen left1 = -1.5 
         } 
      local group = 1 
      
      } 
      if ((`yy' == 2000 & `qq' == 4)|(`yy' == 2008 & `qq' == 3) | (`yy' == 2008 & `qq' == 4) | (`yy' == 2009 & `qq' == 1)) { 

      gen left2 = -0.05 
      gen left3 = 0.45 
      gen left4 = 0.95 
      gen left5 = 1.45 
      gen left6 = 1.95 
      gen left7 = 2.45 
      gen left8 = 2.95 
      gen left9 = 3.45 
      gen left10 = 3.95 

      
         if `endpoint' == 1 { 
            gen left1 = -0.5 
         } 
         else if `endpoint' == 2 { 
            gen left1 = -1.0 
         } 
         else if `endpoint' == 3 { 
            gen left1 = -1.5 
         } 

      local group = 2 
      } 
      if ((`yy' == 2009 & `qq' == 2)|(`yy' == 2009 & `qq' == 3)|(`yy' == 2009 & `qq' == 4)) { 

      gen left2 = -2.05 
      gen left3 = -1.55 
      gen left4 = -1.05 
      gen left5 = -0.55 
      gen left6 = -0.05 
      gen left7 = 0.45 
      gen left8 = 0.95 
      gen left9 = 1.45 
      gen left10 = 1.95 
      gen left11 = 2.45 
      gen left12 = 2.95 
      gen left13 = 3.45 
      gen left14 = 3.95 

      
         if `endpoint' == 1 { 
            gen left1 = -2.5 
         } 
         else if `endpoint' == 2 { 
            gen left1 = -3.0 
         } 
         else if `endpoint' == 3 { 
            gen left1 = -3.5 
         } 

      local group = 3 
      } 
     if (`yy' > 2009 & `yy' < 2020) | (`yy'==2020 & `qq'==1) {


      gen left2 = -1.05
      gen left3 = -0.55
      gen left4 = -0.05
      gen left5 = 0.45
      gen left6 = 0.95
      gen left7 = 1.45
      gen left8 = 1.95
      gen left9 = 2.45
      gen left10 = 2.95
      gen left11 = 3.45
      gen left12 = 3.95
      
         if `endpoint' == 1 {
            gen left1 = -1.5
         }
         else if `endpoint' == 2 {
            gen left1 = -2.0
         }
         else if `endpoint' == 3 {
            gen left1 = -2.5
         }
      local group = 4
      }
	  *NEW!! GROUP 5* ADDED 2020Q2* 
	  
	        if (`yy' == 2020 & `qq' == 2) {

         gen left2 = -4.05
         gen left3 = -3.55
         gen left4 = -3.05
         gen left5 = -2.55
         gen left6 = -2.05
         gen left7 = -1.55
         gen left8 = -1.05
         gen left9 = -0.55
         gen left10 = -0.05
         gen left11 = 0.45
         gen left12 = 0.95
         gen left13 = 1.45
         gen left14 = 1.95
         gen left15 = 2.45
         gen left16 = 2.95
         gen left17 = 3.45
         gen left18 = 3.95
      
         if `endpoint' == 1 {
            gen left1 = -4.55
         }
         else if `endpoint' == 2 {
            gen left1 = -4.95
         }
         else if `endpoint' == 3 {
            gen left1 = -5.55
         }
      local group = 5
      }

      sum person 
      local obs = r(N) 
      quietly: foreach percentile of numlist 1 5 10 15 20 25 50 75 80 85 90 99 { 
         gen P`percentile' = 0 
         gen Bin`percentile' = 0 
         foreach num of numlist 1/`obs' { 
            local point = `percentile'/100 
            local prior = `point' 
            local bin = 0 
            while `point' > 0 { 
               local bin = `bin' + 1 
               local prior = `point' 
               local point = `point' - a`bin'[`num'] 
               di `point' 
            } 
            if `bin' != 1 | (`bin' != 9 & `group' == 1) | (`bin' !=10 & `group' == 2) | (`bin' != 14 & `group' == 3) | (`bin' != 12 & `group'==4) | (`bin' != 18 & `group'==5) { 
               replace P`percentile' = left`bin'[`num'] + (`prior'/a`bin'[`num'])*.49 in `num' 
            } 
            else { 
               if `endpoint' == 1 { 
                  replace P`percentile' = left`bin'[`num'] + (`prior'/a`bin'[`num'])*.44 in `num' 
               } 
               else if `endpoint' == 2 { 
                  replace P`percentile' = left`bin'[`num'] + (`prior'/a`bin'[`num'])*.94 in `num' 
               } 
               else if `endpoint' == 3 { 
                  replace P`percentile' = left`bin'[`num'] + (`prior'/a`bin'[`num'])*1.44 in `num' 
               } 
            } 
         replace Bin`percentile' = `bin' in `num' 
         } 
      }   

      if (`yy' == 1999 & `qq' == 1){ 
         save "${intermediate}/laxhicp_Percentile`x'_`sampcut'.dta", replace 
      } 
      else { 
         append using "${intermediate}/laxhicp_Percentile`x'_`sampcut'.dta"
         save "${intermediate}/laxhicp_Percentile`x'_`sampcut'", replace
      } 
      
      local qq = `qq' + 1 
      if (`qq' == 5) { 
         local qq = 1 
         local yy = `yy' + 1 
      } 
 
      // Kills Loop 
      if (`yy' == $next_year & `qq' == $next_quarter) { 
         local z = 1 
      } 
   restore 
   
   } 
} 
} 
/* Same thing, but for 5-year forecasts */  
foreach sampcut in 100 { 
use "${intermediate}/hicpfiveyr.dta", clear 
// drop nopoint total sum0 sum1 

   bys person: gen sample_N = _N 
   if `sampcut' != 100 { 
   drop if sample_N < `sampcut' 
   } 

			*Restrict sample 
			gen nopoint = 0 
			replace nopoint = 1 if point == . 
			egen total = rowtotal(a*) 

			gen sum0 = 0 
			replace sum0 = 1 if total == 0 
			label variable sum0 "missing density forecast" 

			gen sum1 = 0 
			replace sum1=1 if total <=.991  | total >=1.009 
			label variable sum1 "probabilities do not sum to unity" 
			

   drop if sum0 == 1 
   drop if sum1 == 1 
   drop if nopoint == 1 

/* Create Mean and Dispersion Measure from the Point Forecastps by quarter */ 
   bysort ydate qdate: egen disperse = sd(point) 
   bysort ydate qdate: egen mean = mean(point) 

/* Create zscore to exclude any outliers within the point forecasts */ 
   gen zscore = abs((point-mean)/disperse) 
   count if zscore > 3 
   drop zscore mean disperse 

   // Declare Year and Quarter Variables and dummy z variable which stops the loop once it reaches the last quarter of data 
   local yy = 1999 
   local qq = 1 
   local z = 0 
   local endpoint = 1 
   local group = 0 
   

   // Create left endpoint values for each bin ("b")

   while (`z' == 0) { 
      preserve 
      keep if ydate == `yy' & qdate == `qq' 

      if (`yy' == 1999 | (`yy' == 2000 & `qq' == 1) | (`yy' == 2000 & `qq' == 2)| (`yy'==2000 & `qq' == 3) | (`yy' >= 2001 & `yy' <= 2007) | (`yy' == 2008 & `qq' == 1) | (`yy' == 2008 & `qq' == 2)) { 

      gen left2 = -0.05 
      gen left3 = 0.45 
      gen left4 = 0.95 
      gen left5 = 1.45 
      gen left6 = 1.95 
      gen left7 = 2.45 
      gen left8 = 2.95 
      gen left9 = 3.45 

         if `endpoint' == 1 { 
            gen left1 = -0.5 
         } 
         else if `endpoint' == 2 { 
            gen left1 = -1.0 
         } 
         else if `endpoint' == 3 { 
            gen left1 = -1.5 
         } 
      local group = 1 
      
      } 
      if ((`yy' == 2000 & `qq' == 4)|(`yy' == 2008 & `qq' == 3) | (`yy' == 2008 & `qq' == 4) | (`yy' == 2009 & `qq' == 1)) { 

      gen left2 = -0.05 
      gen left3 = 0.45 
      gen left4 = 0.95 
      gen left5 = 1.45 
      gen left6 = 1.95 
      gen left7 = 2.45 
      gen left8 = 2.95 
      gen left9 = 3.45 
      gen left10 = 3.95 

      
         if `endpoint' == 1 { 
            gen left1 = -0.5 
         } 
         else if `endpoint' == 2 { 
            gen left1 = -1.0 
         } 
         else if `endpoint' == 3 { 
            gen left1 = -1.5 
         } 

      local group = 2 
      } 
      if ((`yy' == 2009 & `qq' == 2)|(`yy' == 2009 & `qq' == 3)|(`yy' == 2009 & `qq' == 4)) { 

      gen left2 = -2.05 
      gen left3 = -1.55 
      gen left4 = -1.05 
      gen left5 = -0.55 
      gen left6 = -0.05 
      gen left7 = 0.45 
      gen left8 = 0.95 
      gen left9 = 1.45 
      gen left10 = 1.95 
      gen left11 = 2.45 
      gen left12 = 2.95 
      gen left13 = 3.45 
      gen left14 = 3.95 

      
         if `endpoint' == 1 { 
            gen left1 = -2.5 
         } 
         else if `endpoint' == 2 { 
            gen left1 = -3.0 
         } 
         else if `endpoint' == 3 { 
            gen left1 = -3.5 
         } 

      local group = 3 
      } 
      if (`yy' > 2009 & `yy' < 2020) | (`yy'==2020 & `qq'==1) {


      gen left2 = -1.05
      gen left3 = -0.55
      gen left4 = -0.05
      gen left5 = 0.45
      gen left6 = 0.95
      gen left7 = 1.45
      gen left8 = 1.95
      gen left9 = 2.45
      gen left10 = 2.95
      gen left11 = 3.45
      gen left12 = 3.95
      
         if `endpoint' == 1 {
            gen left1 = -1.5
         }
         else if `endpoint' == 2 {
            gen left1 = -2.0
         }
         else if `endpoint' == 3 {
            gen left1 = -2.5
         }
      local group = 4
      }
	  
	  *NEW!! GROUP 5* ADDED 2020Q2* 
	  
	        if (`yy' == 2020 & `qq' == 2) {

         gen left2 = -4.05
         gen left3 = -3.55
         gen left4 = -3.05
         gen left5 = -2.55
         gen left6 = -2.05
         gen left7 = -1.55
         gen left8 = -1.05
         gen left9 = -0.55
         gen left10 = -0.05
         gen left11 = 0.45
         gen left12 = 0.95
         gen left13 = 1.45
         gen left14 = 1.95
         gen left15 = 2.45
         gen left16 = 2.95
         gen left17 = 3.45
         gen left18 = 3.95
      
         if `endpoint' == 1 {
            gen left1 = -4.55
         }
         else if `endpoint' == 2 {
            gen left1 = -4.95
         }
         else if `endpoint' == 3 {
            gen left1 = -5.55
         }
      local group = 5
      }

      sum person 
      local obs = r(N) 
      quietly: foreach percentile of numlist 1 5 10 15 20 25 50 75 80 85 90 99 { 
         gen P`percentile' = 0 
         gen Bin`percentile' = 0 
         foreach num of numlist 1/`obs' { 
            local point = `percentile'/100 
            local prior = `point' 
            local bin = 0 
            while `point' > 0 { 
               local bin = `bin' + 1 
               local prior = `point' 
               local point = `point' - a`bin'[`num'] 
               di `point' 
            } 
            if `bin' != 1 | (`bin' != 9 & `group' == 1) | (`bin' !=10 & `group' == 2) | (`bin' != 14 & `group' == 3) | (`bin' != 12 & `group'==4) | (`bin' != 18 & `group'==5) { 
               replace P`percentile' = left`bin'[`num'] + (`prior'/a`bin'[`num'])*.49 in `num' 
            } 
            else { 
               if `endpoint' == 1 { 
                  replace P`percentile' = left`bin'[`num'] + (`prior'/a`bin'[`num'])*.44 in `num' 
               } 
               else if `endpoint' == 2 { 
                  replace P`percentile' = left`bin'[`num'] + (`prior'/a`bin'[`num'])*.94 in `num' 
               } 
               else if `endpoint' == 3 { 
                  replace P`percentile' = left`bin'[`num'] + (`prior'/a`bin'[`num'])*1.44 in `num' 
               } 
            } 
         replace Bin`percentile' = `bin' in `num' 
         } 
      }   

      if (`yy' == 1999 & `qq' == 1){ 
         save "${intermediate}/laxhicp_Percentile5_`sampcut'.dta", replace 
      } 
      else { 
         append using "${intermediate}/laxhicp_Percentile5_`sampcut'.dta"
         save "${intermediate}/laxhicp_Percentile5_`sampcut'", replace 
      } 
      
      if `yy' > 2000 { 
	  local qq = `qq' + 1 
      if (`qq' == 5) { 
         local qq = 1 
         local yy = `yy' + 1 
      } 
	  } 
	  
	  if ((`yy' == 1999 | `yy' == 2000) & `qq' == 1) { 
	  local yy = `yy' + 1 
	  } 
	  
 
      // Kills Loop 
      if (`yy' == $next_year & `qq' == $next_quarter) { 
         local z = 1 
      } 
   restore 
   
   } 
} 
  
  
