*======================================================================
* x00a_Main.do
*======================================================================
/**********************************************************************
	Description: Run all .do files. Use ssc install to download the
	following packages: estout, ivreg2, asdoc, and sxpose. The entire
	replication package takes about 20 minutes to run on a standard 
	desktop.
**********************************************************************/
clear all
set more off

program globalcreation
	** change filepath here
	global replication  "...\...\REPLICATION PACKAGE"
	
	** filepaths
	global data         "${replication}\Data"
	global raw          "${data}\Raw"
	global intermediate "${data}\Intermediate"
	global ready    	"${data}\Ready"
	
	global code         "${replication}\Code"
	
	global output		"${replication}\Output"
	global reference    "${output}\Reference"
	global regressions  "${output}\Regressions"
	
	global start_year    = 1999 // *  start = first possible survey date
	global start_quarter = 1
	global end_year      = 2019 // *  end   = current survey
	global end_quarter   = 4
	global next_year     = 2020 // *  next  = next quarter
	global next_quarter  = 1
end
globalcreation


do "${code}/x01_Raw_Data_Shell"                            			// import raw data
do "${code}/x02a_Individual_Uncertainty_GDP"               			// gdp
do "${code}/x02b_Individual_Uncertainty_HICP"              			// inflation
do "${code}/x02c_Individual_Uncertainty_Urate"             			// unemployment rate
do "${code}/x03_Pull_Data"                                 			// pull in historical data for comparison to SPF forecasts 
do "${code}/x04_Data_Clean_And_Merge"                      			// drop forecasters with missing or invalid data
do "${code}/x05_Drop_Low_Counts"                           			// implement participation criteria

	** change filepaths in the following script @ lines 22 and 39:
python script "${code}/x06a_Density_Data_Prep.py"             		// prepare density forecasts

	** change filepaths in the following script @ line 324:
python script "${code}/x06b_Density_Performance_Metrics.py"  		// compute density performance metrics

do "${code}/x07_Common_Factor_Panel_Regs"                          // fixed effects and loading factor regressions

	** change filepaths in the following script @ lines 11, 12, 18, 23:
pause on
disp "Run x08_Significance_Testing_and_Charts.m"					// Tables 1 and 2
pause enter q to continue.

	** change filepaths in the following script @ lines 10, 11, 12, 20, 21, and 217:
pause on
disp "Run x09_Simulations.m"										// simulated alphas and lambdas for each target variable
pause enter q to continue

do "${code}/x10_Selected_GDP_Forecasters"							// performance data from forecasters used in Figure 7
do "${code}/x11_Disagreement_Prep"									// disagreement measures for Figure 6
do "${code}/x12_Forecast_Performance_Rankings"						// Table 3
do "${code}/x13_Forecast_Combinations"								// Table 5A
do "${code}/x18_HL_Prep"											// prepare for Hounyo and Lahiri (2023) bootstrap procedure

disp "Switch to x00b_Main.R"
