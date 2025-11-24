*======================================================================
* x02a_Individual_Uncertainty_GDP.do
*====================================================================== 
/**********************************************************************
	Description: Creates percentile by individual forecast distribution.
**********************************************************************/
clear
set more off 

local data "Ac Bc Aroll Broll" 
foreach sampcut in 100 { 
foreach x of local data { 

   use "${intermediate}/gdp`x'.dta", clear 
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
      
      if (`yy' == 1999) | (`yy' == 2000 & `qq' == 1) | (`yy' >= 2001 & `yy' <= 2007) | (`yy' == 2008 & `qq' == 1) | (`yy' == 2008 & `qq' == 2) | (`yy'==2008 & `qq' == 3) { 

         gen b2 = -0.05 
         gen b3 = 0.45 
         gen b4 = 0.95 
         gen b5 = 1.45 
         gen b6 = 1.95 
         gen b7 = 2.45 
         gen b8 = 2.95 
         gen b9 = 3.45 
         gen b10 = 3.95 
         

         if `endpoint' == 1 { 
            gen b1 = -0.5 
         } 
         else if `endpoint' == 2 { 
            gen b1 = -1.0 
         } 
         else if `endpoint' == 3 { 
            gen b1 = -1.5 
         } 
         local group = 1 
      
      } 
      if ((`yy' == 2000 & `qq' == 2)| (`yy' == 2000 & `qq' == 3)|(`yy' == 2000 & `qq' == 4)) { 

         gen b2 = -0.05 
         gen b3 = 0.45 
         gen b4 = 0.95 
         gen b5 = 1.45 
         gen b6 = 1.95 
         gen b7 = 2.45 
         gen b8 = 2.95 
         gen b9 = 3.45 
         gen b10 = 3.95 
         gen b11 = 4.45 
         gen b12 = 4.95 

      
         if `endpoint' == 1 { 
            gen b1 = -0.5 
         } 
         else if `endpoint' == 2 { 
            gen b1 = -1.0 
         } 
         else if `endpoint' == 3 { 
            gen b1 = -1.5 
         } 

         local group = 2 
      } 
      if ((`yy' == 2008 & `qq' == 4)|(`yy' == 2009 & `qq' == 1)|(`yy' >2009)) { 

         gen b2 = -1.05 
         gen b3 = -0.55 
         gen b4 = -0.05 
         gen b5 = 0.45 
         gen b6 = 0.95 
         gen b7 = 1.45 
         gen b8 = 1.95 
         gen b9 = 2.45 
         gen b10 = 2.95 
         gen b11 = 3.45 
         gen b12 = 3.95 
      
         if `endpoint' == 1 { 
            gen b1 = -1.5 
         } 
         else if `endpoint' == 2 { 
            gen b1 = -2.0 
         } 
         else if `endpoint' == 3 { 
            gen b1 = -2.5 
         } 

         local group = 3 
      } 
      if (`yy' == 2009 & `qq' == 2) | (`yy' == 2009 & `qq' == 3) | (`yy'==2009 & `qq' == 4) { 


         gen b2 = -6.05 
         gen b3 = -5.55 
         gen b4 = -5.05 
         gen b5 = -4.55 
         gen b6 = -4.05 
         gen b7 = -3.55 
         gen b8 = -3.05 
         gen b9 = -2.55 
         gen b10 = -2.05 
         gen b11 = -1.55 
         gen b12 = -1.05 
         gen b13 = -0.55 
         gen b14 = -0.05 
         gen b15 = 0.45 
         gen b16 = 0.95 
         gen b17 = 1.45 
         gen b18 = 1.95 
         gen b19 = 2.45 
         gen b20 = 2.95 
         gen b21 = 3.45 
         gen b22 = 3.95 

         
         if `endpoint' == 1 { 
            gen b1 = -6.5 
         } 
         else if `endpoint' == 2 { 
            gen b1 = -7.0 
         } 
         else if `endpoint' == 3 { 
            gen b1 = -7.5 
         } 
         local group = 4 
      } 
	   * new! group 5 added bc of the bin structure change in 2020q2
	       if (`yy' == 2020 & `qq' == 2) {

         gen b2 = -15.05
         gen b3 = -13.05
         gen b4 = -11.05
         gen b5 = -9.05
         gen b6 = -7.05
         gen b7 = -5.05
         gen b8 = -3.05
         gen b9 = -1.05
         gen b10 = -0.55
         gen b11 = -0.05
         gen b12 = 0.45
         gen b13 = 0.95
         gen b14 = 1.45
         gen b15 = 1.95
         gen b16 = 2.45
         gen b17 = 2.95
         gen b18 = 3.45
         gen b19 = 3.95
         gen b20 = 5.95
         gen b21 = 7.95
         gen b22 = 9.95

         if `endpoint' == 1 {
            gen b1 = -15.5 
         }
         else if `endpoint' == 2 { // the endpoint that we are actually using, the others idc about right now 
            gen b1 = -17.1
         }
         else if `endpoint' == 3 {
            gen b1 = -16.5
         }
         local group = 5
      }
      
      sum person 
	  	local obs = r(N) 
      quietly: foreach percentile of numlist 1 5 10 15 20 25 50 70 75 80 85 90 95 99 { 
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
            if `bin' != 1 { 
               replace P`percentile' = b`bin'[`num'] + (`prior'/a`bin'[`num'])*.49 in `num' 
            } 
            else if (`bin' != 10 & `group' == 1) { 
               replace P`percentile' = b`bin'[`num'] + (`prior'/a`bin'[`num'])*.49 in `num' 
            } 
            else if (`bin' !=12 & `group' == 2) { 
               replace P`percentile' = b`bin'[`num'] + (`prior'/a`bin'[`num'])*.49 in `num' 
            } 
            else if (`bin' !=12 & `group' == 3) { 
               replace P`percentile' = b`bin'[`num'] + (`prior'/a`bin'[`num'])*.49 in `num' 
            } 
            else if (`bin' !=22 & (`group' == 4 | `group'==5)) { 
               replace P`percentile' = b`bin'[`num'] + (`prior'/a`bin'[`num'])*.49 in `num' 
            } 
            else { 
               if `endpoint' == 1 { 
                  replace P`percentile' = b`bin'[`num'] + (`prior'/a`bin'[`num'])*.44 in `num' 
               } 
               else if `endpoint' == 2 { 
                  replace P`percentile' = b`bin'[`num'] + (`prior'/a`bin'[`num'])*.94 in `num' 
               } 
               else if `endpoint' == 3 { 
                  replace P`percentile' = b`bin'[`num'] + (`prior'/a`bin'[`num'])*1.44 in `num' 
               } 
            } 
         replace Bin`percentile' = `bin' in `num' 
         } 
      }   

      if (`yy' == 1999 & `qq' == 1){ 
         save "${intermediate}/laxgdp_Percentile`x'_`sampcut'.dta", replace 
      } 
      else { 
         append using "${intermediate}/laxgdp_Percentile`x'_`sampcut'.dta" 
         save "${intermediate}/laxgdp_Percentile`x'_`sampcut'", replace 
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
/* Same exact thing, but for the 5-year forecast */
foreach sampcut in 100 { 
use "${intermediate}/gdpfiveyr.dta", clear 
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
      
      if (`yy' == 1999 | (`yy' == 2000 & `qq' == 1) | (`yy' >= 2001 & `yy' <= 2007) | (`yy' == 2008 & `qq' == 1) | (`yy' == 2008 & `qq' == 2))|(`yy'==2008 & `qq' == 3) { 

         gen b2 = -0.05 
         gen b3 = 0.45 
         gen b4 = 0.95 
         gen b5 = 1.45 
         gen b6 = 1.95 
         gen b7 = 2.45 
         gen b8 = 2.95 
         gen b9 = 3.45 
         gen b10 = 3.95 
         

         if `endpoint' == 1 { 
            gen b1 = -0.5 
         } 
         else if `endpoint' == 2 { 
            gen b1 = -1.0 
         } 
         else if `endpoint' == 3 { 
            gen b1 = -1.5 
         } 
         local group = 1 
      
      } 
      if ((`yy' == 2000 & `qq' == 2)| (`yy' == 2000 & `qq' == 3)|(`yy' == 2000 & `qq' == 4)) { 

         gen b2 = -0.05 
         gen b3 = 0.45 
         gen b4 = 0.95 
         gen b5 = 1.45 
         gen b6 = 1.95 
         gen b7 = 2.45 
         gen b8 = 2.95 
         gen b9 = 3.45 
         gen b10 = 3.95 
         gen b11 = 4.45 
         gen b12 = 4.95 

      
         if `endpoint' == 1 { 
            gen b1 = -0.5 
         } 
         else if `endpoint' == 2 { 
            gen b1 = -1.0 
         } 
         else if `endpoint' == 3 { 
            gen b1 = -1.5 
         } 

         local group = 2 
      } 
      if ((`yy' == 2008 & `qq' == 4)|(`yy' == 2009 & `qq' == 1) | (`yy' > 2009)) { 

         gen b2 = -1.05 
         gen b3 = -0.55 
         gen b4 = -0.05 
         gen b5 = 0.45 
         gen b6 = 0.95 
         gen b7 = 1.45 
         gen b8 = 1.95 
         gen b9 = 2.45 
         gen b10 = 2.95 
         gen b11 = 3.45 
         gen b12 = 3.95 
      
         if `endpoint' == 1 { 
            gen b1 = -1.5 
         } 
         else if `endpoint' == 2 { 
            gen b1 = -2.0 
         } 
         else if `endpoint' == 3 { 
            gen b1 = -2.5 
         } 

         local group = 3 
      } 
      if (`yy' == 2009 & `qq' == 2) | (`yy' == 2009 & `qq' == 3) | (`yy'==2009 & `qq' == 4) { 


         gen b2 = -6.05 
         gen b3 = -5.55 
         gen b4 = -5.05 
         gen b5 = -4.55 
         gen b6 = -4.05 
         gen b7 = -3.55 
         gen b8 = -3.05 
         gen b9 = -2.55 
         gen b10 = -2.05 
         gen b11 = -1.55 
         gen b12 = -1.05 
         gen b13 = -0.55 
         gen b14 = -0.05 
         gen b15 = 0.45 
         gen b16 = 0.95 
         gen b17 = 1.45 
         gen b18 = 1.95 
         gen b19 = 2.45 
         gen b20 = 2.95 
         gen b21 = 3.45 
         gen b22 = 3.95 

         
         if `endpoint' == 1 { 
            gen b1 = -6.5 
         } 
         else if `endpoint' == 2 { 
            gen b1 = -7.0 
         } 
         else if `endpoint' == 3 { 
            gen b1 = -7.5 
         } 
         local group = 4 
      } 
      
	 * new! group 5 added bc of the bin structure change in 2020q2
	       if (`yy' == 2020 & `qq' == 2) {

         gen b2 = -15.05
         gen b3 = -13.05
         gen b4 = -11.05
         gen b5 = -9.05
         gen b6 = -7.05
         gen b7 = -5.05
         gen b8 = -3.05
         gen b9 = -1.05
         gen b10 = -0.55
         gen b11 = -0.05
         gen b12 = 0.45
         gen b13 = 0.95
         gen b14 = 1.45
         gen b15 = 1.95
         gen b16 = 2.45
         gen b17 = 2.95
         gen b18 = 3.45
         gen b19 = 3.95
         gen b20 = 5.95
         gen b21 = 7.95
         gen b22 = 9.95

         if `endpoint' == 1 {
            gen b1 = -15.5 
         }
         else if `endpoint' == 2 { // the endpoint that we are actually using, the others idc about right now 
            gen b1 = -17.1
         }
         else if `endpoint' == 3 {
            gen b1 = -16.5
         }
         local group = 5
      }
      sum person 
	  	  
      local obs = r(N) 
      quietly: foreach percentile of numlist 1 5 10 15 20 25 50 70 75 80 85 90 95 99 { 
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
            if `bin' != 1 { 
               replace P`percentile' = b`bin'[`num'] + (`prior'/a`bin'[`num'])*.49 in `num' 
            } 
            else if (`bin' != 10 & `group' == 1) { 
               replace P`percentile' = b`bin'[`num'] + (`prior'/a`bin'[`num'])*.49 in `num' 
            } 
            else if (`bin' !=12 & `group' == 2) { 
               replace P`percentile' = b`bin'[`num'] + (`prior'/a`bin'[`num'])*.49 in `num' 
            } 
            else if (`bin' !=12 & `group' == 3) { 
               replace P`percentile' = b`bin'[`num'] + (`prior'/a`bin'[`num'])*.49 in `num' 
            } 
            else if (`bin' !=22 & (`group' == 4 | `group'==5)) { 
               replace P`percentile' = b`bin'[`num'] + (`prior'/a`bin'[`num'])*.49 in `num' 
            } 
            else { 
               if `endpoint' == 1 { 
                  replace P`percentile' = b`bin'[`num'] + (`prior'/a`bin'[`num'])*.44 in `num' 
               } 
               else if `endpoint' == 2 { 
                  replace P`percentile' = b`bin'[`num'] + (`prior'/a`bin'[`num'])*.94 in `num' 
               } 
               else if `endpoint' == 3 { 
                  replace P`percentile' = b`bin'[`num'] + (`prior'/a`bin'[`num'])*1.44 in `num' 
               } 
            } 
         replace Bin`percentile' = `bin' in `num' 
         } 
      }   

      if (`yy' == 1999 & `qq' == 1){ 
         save "${intermediate}/laxgdp_Percentile5_`sampcut'.dta", replace 
      } 
      else { 
         append using "${intermediate}/laxgdp_Percentile5_`sampcut'.dta" 
         save "${intermediate}/laxgdp_Percentile5_`sampcut'", replace 
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

   
   