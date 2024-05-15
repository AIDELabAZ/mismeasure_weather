* Project: WB Weather
* Created by: jdm
* Created on: April 2020
* edited by: jdm
* edited on: 15 May 2024
* Stata v.18

* does
	* reads in Ethiopia, wave 1 .dta files with daily values
    * runs weather_command .ado file
	* outputs .dta file of the relevant weather variables
	* does the above for both rainfall and temperature data
	/* 	-the growing season that we care about is defined on the FAO website:
			http://www.fao.org/giews/countrybrief/country.jsp?code=ETH
		-we measure rainfall during the months that the FAO defines as sowing and growing
		-we define the relevant months as March 1 - November 30 */

* assumes
	* ETH_ESSY1_converter.do
	* weather_command.ado

* TO DO:
	* completed

	
* **********************************************************************
* 0 - setup
* **********************************************************************

* set global user
*	global user "jdmichler"

* define paths	
	loc root = "$data/weather_data/ethiopia/wave_1/daily"
	loc export = "$data/weather_data/ethiopia/wave_1/refined"
	loc logout = "$data/weather_data/ethiopia/logs"

* open log	
	cap log		close
	log using "`logout'/eth_essy1_weather", replace


* **********************************************************************
* 1 - run command for rainfall
* **********************************************************************

* define local with all sub-folders in it
	loc folderList : dir "`root'" dirs "ERSSY1_rf*"

* loop through each of the sub-folders in the above local
foreach folder of local folderList {
	
	* create directories to write output to
	qui: capture mkdir "`export'/`folder'/"
	
	* define local with all files in each sub-folder
		loc fileList : dir "`root'/`folder'" files "*.dta"
	
	* loop through each file in the above local
	foreach file in `fileList' {
		
		* import the daily data file
		use "`root'/`folder'/`file'", clear
		
		* define locals to govern file naming
			loc dat = substr("`file'", 1, 6)
			loc ext = substr("`file'", 8, 2)
			loc sat = substr("`file'", 11, 3)
		
		* run the user written weather command - this takes a while
		weather rf_ , rain_data ini_month(3) fin_month(12) day_month(1) keep(household_id)
		
		* save file
		customsave , idvar(household_id) filename("`dat'_`ext'_`sat'.dta") ///
			path("`export'/`folder'") dofile(ETH_ESSY1_weather) user($user)
	}
}


* **********************************************************************
* 2 - run command for temperature
* **********************************************************************

* define local with all sub-folders in it
	loc folderList : dir "`root'" dirs "ERSSY1_t*"

* loop through each of the sub-folders in the above local
foreach folder of local folderList {
	
	* create directories to write output to
	qui: capture mkdir "`export'/`folder'/"

	* define local with all files in each sub-folder	
	loc fileList : dir "`root'/`folder'" files "*.dta"
	
	* loop through each file in the above local
	foreach file in `fileList' {
		
		* import the daily data file		
		use "`root'/`folder'/`file'", clear
		
		* define locals to govern file naming
			loc dat = substr("`file'", 1, 6)
			loc ext = substr("`file'", 8, 2)
			loc sat = substr("`file'", 11, 2)
		
		* run the user written weather command - this takes a while		
		weather tmp_ , temperature_data growbase_low(10) growbase_high(30) ini_month(3) fin_month(12) day_month(1) keep(household_id)
		
		* save file
		customsave , idvar(household_id) filename("`dat'_`ext'_`sat'.dta") ///
			path("`export'/`folder'") dofile(ETH_ESSY1_weather) user($user)
		}
}

* close the log
	log	close

/* END */
