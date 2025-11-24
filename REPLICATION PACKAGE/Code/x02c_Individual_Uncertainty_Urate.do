*======================================================================
* x02c_Individual_Uncertainty_Urate.do
*====================================================================== 
/**********************************************************************
	Description: Creates percentile by individual forecast distribution.
**********************************************************************/
clear
set mem 100000
set more off

local data "Ac Bc Aroll Broll"
foreach sampcut in 100 {
foreach x of local data {

   use "${intermediate}/urate`x'.dta", clear
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
   
/* Create Mean and Dispersion Measure from the Point Forecasts by quarter */
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
   local endpoint = 2	// Want to double the width of the leftmost and rightmost bins
   local group = 0
   global file = "`x'"
   local p = "$file"

   // Create left endpoint values for each bin ("b")
	while (`z' == 0) {
		preserve
		keep if ydate == `yy' & qdate == `qq'
      
	   * ----------------------------------------------------------------  
	* Group 1 
		if (`yy' == 1999) | (`yy' == 2000 & `qq' == 1) {
			gen b2 = 8.95
		
			forvalues x = 3/14 {
				local y = `x' - 1
				gen b`x' = b`y' + 0.5
			}

			 if `endpoint' == 1 {
			    gen b1 = b2 - 0.45
			 }
			 else if `endpoint' == 2 {
			    gen b1 = b2 - 0.95
			 }
			 else if `endpoint' == 3 {
			    gen b1 = b2 - 1.45
			 }
			 local group = 1
		}
      
	* ----------------------------------------------------------------    
	  * Group 2 
      if (`yy' == 2000 & `qq' == 2) {
		gen b2 = 7.45
		
		forvalues x = 3/17 {
			local y = `x' - 1
			gen b`x' = b`y' + 0.5
		}

         if `endpoint' == 1 {
            gen b1 = b2 - 0.45
         }
         else if `endpoint' == 2 {
            gen b1 = b2 - 0.95
         }
         else if `endpoint' == 3 {
            gen b1 = b2 - 1.45
         }

         local group = 2
      }
	* ----------------------------------------------------------------  
	  
	  * Group 3 
      if `yy' == 2000 & (`qq' == 3 | `qq' == 4) {
		gen b2 = 6.95
        
		forvalues x = 3/11 {
			local y = `x' - 1
			gen b`x' = b`y' + 0.5
		}
      
         if `endpoint' == 1 {
            gen b1 = b2 - 0.45
         }
         else if `endpoint' == 2 {
            gen b1 = b2 - 0.95
         }
         else if `endpoint' == 3 {
            gen b1 = b2 - 1.45
         }

         local group = 3
      }
	 * ----------------------------------------------------------------  
	 * Group 4
      if (`yy' == 2001) | (`yy' == 2002 & `qq' == 1) {
		 gen b2 = 6.45
        
		 forvalues x = 3/19 {
			local y = `x' - 1
			gen b`x' = b`y' + 0.5
		 }
         
         if `endpoint' == 1 {
            gen b1 = b2 - 0.45
         }
         else if `endpoint' == 2 {
            gen b1 = b2 - 0.95
         }
		 else if `endpoint' == 3 {
            gen b1 = b2 - 1.45
         }
		 
         local group = 4
      }
	* ----------------------------------------------------------------  
	* Group 5 
		if (`yy' == 2002 & `qq' != 1) | (`yy' >= 2003 & `yy' <= 2008) | (`yy' == 2009 & `qq' == 1) {
		 gen b2 = 5.45
        
		 forvalues x = 3/13 {
			local y = `x' - 1
			gen b`x' = b`y' + 0.5
		 }
         
         if `endpoint' == 1 {
            gen b1 = b2 - 0.45
         }
         else if `endpoint' == 2 {
            gen b1 = b2 - 0.95
         }
		 else if `endpoint' == 3 {
            gen b1 = b2 - 1.45
         }
		 
         local group = 5
		}
	  * ----------------------------------------------------------------  
	  * Group 6 
		if ((`yy' == 2009 & `qq' >= 2 & `qq' <= 4) | (`yy' >2017))  {
			gen b2 = 5.45
        
			forvalues x = 3/21 {
				local y = `x' - 1
				gen b`x' = b`y' + 0.5
			}
         
			if `endpoint' == 1 {
				gen b1 = b2 - 0.45
			}
			
			else if `endpoint' == 2 {
				gen b1 = b2 - 0.95
			}
			
			else if `endpoint' == 3 {
				gen b1 = b2 - 1.45
			}
		 
         local group = 6
		}
		* ----------------------------------------------------------------  
		* Group 7 
		if ((`yy' == 2010) | (`yy' == 2011) | (`yy' == 2012) | (`yy' == 2013) | (`yy' == 2014) | (`yy' == 2015) | (`yy' == 2016) | (`yy' == 2017)) {
			gen b2 = 6.45
        
			forvalues x = 3/19 {
				local y = `x' - 1
				gen b`x' = b`y' + 0.5
			}
         
			if `endpoint' == 1 {
				gen b1 = b2 - 0.45
			}
			
			else if `endpoint' == 2 {
				gen b1 = b2 - 0.95
			}
			
			else if `endpoint' == 3 {
				gen b1 = b2 - 1.45
			}
		 
         local group = 7
		}
		
      disp ""
      disp "file = `p', year = `yy', quarter = `qq', group = `group'"
	  sum person
	  local obs = r(N)
      foreach percentile in 1 5 10 15 20 25 50 70 75 80 85 90 95 99 {
         gen P`percentile' = 0
         gen Bin`percentile' = 0
         forvalues num = 1/`obs' {
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
            else if (`bin' != 14 & `group' == 1) {
               replace P`percentile' = b`bin'[`num'] + (`prior'/a`bin'[`num'])*.49 in `num'
            }
            else if (`bin' !=17 & `group' == 2) {
               replace P`percentile' = b`bin'[`num'] + (`prior'/a`bin'[`num'])*.49 in `num'
            }
            else if (`bin' !=11 & `group' == 3) {
               replace P`percentile' = b`bin'[`num'] + (`prior'/a`bin'[`num'])*.49 in `num'
            }
            else if (`bin' !=19 & `group' == 4) {
               replace P`percentile' = b`bin'[`num'] + (`prior'/a`bin'[`num'])*.49 in `num'
            }
			else if (`bin' !=13 & `group' == 5) {
               replace P`percentile' = b`bin'[`num'] + (`prior'/a`bin'[`num'])*.49 in `num'
            }
			else if (`bin' !=21 & `group' == 6) {
               replace P`percentile' = b`bin'[`num'] + (`prior'/a`bin'[`num'])*.49 in `num'
            }
			else if (`bin' !=19 & `group' == 7) {
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
         save "${intermediate}/laxurate_Percentile`p'_`sampcut'.dta", replace
      }
      else {
         append using "${intermediate}/laxurate_Percentile`p'_`sampcut'.dta"
         save "${intermediate}/laxurate_Percentile`p'_`sampcut'.dta", replace
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
***************************************************
foreach sampcut in 100 {
use "${intermediate}/uratefiveyr.dta", clear
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
   local endpoint = 2	// 1 = single bin width, 2 = double bin width, 3 = triple bin width for left and rightmost bins
   local group = 0
   global file = "`x'"
   local p = "$file"

   // Create left endpoint values for each bin ("b")

   while (`z' == 0) {
      preserve
      keep if ydate == `yy' & qdate == `qq'
      
		if (`yy' == 1999) | (`yy' == 2000 & `qq' == 1) {
			gen b2 = 8.95
			
			forvalues x = 3/14 {
				local y = `x' - 1
				gen b`x' = b`y' + 0.5
			}

			 if `endpoint' == 1 {
				gen b1 = b2 - 0.45
			 }
			 else if `endpoint' == 2 {
				gen b1 = b2 - 0.95
			 }
			 else if `endpoint' == 3 {
				gen b1 = b2 - 1.45
			 }
			 local group = 1
      }
      
      if (`yy' == 2000 & `qq' == 2) {
		gen b2 = 7.45
		
		forvalues x = 3/17 {
			local y = `x' - 1
			gen b`x' = b`y' + 0.5
		}

         if `endpoint' == 1 {
            gen b1 = b2 - 0.45
         }
         else if `endpoint' == 2 {
            gen b1 = b2 - 0.95
         }
         else if `endpoint' == 3 {
            gen b1 = b2 - 1.45
         }

         local group = 2
      }
	  
      if `yy' == 2000 & (`qq' == 3 | `qq' == 4) {
		gen b2 = 6.95
        
		forvalues x = 3/11 {
			local y = `x' - 1
			gen b`x' = b`y' + 0.5
		}
      
         if `endpoint' == 1 {
            gen b1 = b2 - 0.45
         }
         else if `endpoint' == 2 {
            gen b1 = b2 - 0.95
         }
         else if `endpoint' == 3 {
            gen b1 = b2 - 1.45
         }

         local group = 3
      }
	  
      if (`yy' == 2001) | (`yy' == 2002 & `qq' == 1) {
		 gen b2 = 6.45
        
		 forvalues x = 3/19 {
			local y = `x' - 1
			gen b`x' = b`y' + 0.5
		 }
         
         if `endpoint' == 1 {
            gen b1 = b2 - 0.45
         }
         else if `endpoint' == 2 {
            gen b1 = b2 - 0.95
         }
		 else if `endpoint' == 3 {
            gen b1 = b2 - 1.45
         }
		 
         local group = 4
      }
	  
		if (`yy' == 2002 & `qq' != 1) | (`yy' >= 2003 & `yy' <= 2008) | (`yy' == 2009 & `qq' == 1) {
		 gen b2 = 5.45
        
		 forvalues x = 3/13 {
			local y = `x' - 1
			gen b`x' = b`y' + 0.5
		 }
         
         if `endpoint' == 1 {
            gen b1 = b2 - 0.45
         }
         else if `endpoint' == 2 {
            gen b1 = b2 - 0.95
         }
		 else if `endpoint' == 3 {
            gen b1 = b2 - 1.45
         }
		 
         local group = 5
		}
	  
		if ((`yy' == 2009 & `qq' >= 2 & `qq' <= 4) | (`yy' >2017))  {
			gen b2 = 5.45
        
			forvalues x = 3/21 {
				local y = `x' - 1
				gen b`x' = b`y' + 0.5
			}
         
			if `endpoint' == 1 {
				gen b1 = b2 - 0.45
			}
			
			else if `endpoint' == 2 {
				gen b1 = b2 - 0.95
			}
			
			else if `endpoint' == 3 {
				gen b1 = b2 - 1.45
			}
		 
         local group = 6
		}
		
		if ((`yy' == 2010) | (`yy' == 2011) | (`yy' == 2012) | (`yy' == 2013) | (`yy' == 2014) | (`yy' == 2015) | (`yy' == 2016) | (`yy' == 2017)) {
			gen b2 = 6.45
        
			forvalues x = 3/19 {
				local y = `x' - 1
				gen b`x' = b`y' + 0.5
			}
         
			if `endpoint' == 1 {
				gen b1 = b2 - 0.45
			}
			
			else if `endpoint' == 2 {
				gen b1 = b2 - 0.95
			}
			
			else if `endpoint' == 3 {
				gen b1 = b2 - 1.45
			}
		 
         local group = 7
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
		else if (`bin' != 14 & `group' == 1) {
			replace P`percentile' = b`bin'[`num'] + (`prior'/a`bin'[`num'])*.49 in `num'
		}
		else if (`bin' !=17 & `group' == 2) {
			replace P`percentile' = b`bin'[`num'] + (`prior'/a`bin'[`num'])*.49 in `num'
		}
		else if (`bin' !=11 & `group' == 3) {
			replace P`percentile' = b`bin'[`num'] + (`prior'/a`bin'[`num'])*.49 in `num'
		}
		else if (`bin' !=19 & `group' == 4) {
			replace P`percentile' = b`bin'[`num'] + (`prior'/a`bin'[`num'])*.49 in `num'
		}
		else if (`bin' !=13 & `group' == 5) {
			replace P`percentile' = b`bin'[`num'] + (`prior'/a`bin'[`num'])*.49 in `num'
		}
		else if (`bin' !=21 & `group' == 6) {
			replace P`percentile' = b`bin'[`num'] + (`prior'/a`bin'[`num'])*.49 in `num'
		}
		else if (`bin' !=19 & `group' == 7) {
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
		save "${intermediate}/laxurate_Percentile5_`sampcut'.dta", replace
	}
	
	else {
		append using "${intermediate}/laxurate_Percentile5_`sampcut'.dta"
		save "${intermediate}/laxurate_Percentile5_`sampcut'", replace
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


