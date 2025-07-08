* Project: WB Weather - mismeasure paper
* Created on: may 2020
* Created by: jdm
* Stata v.18.5

* does
	* establishes an identical workspace between users
	* sets globals that define absolute paths
	* serves as the starting point to find any do-file, dataset or output
	* runs all do-files needed for data work
	* loads any user written packages needed for analysis

* assumes
	* access to processed data on Zenodo and code

* TO DO:
	* add run time 


* **********************************************************************
* 0 - setup
* **********************************************************************

* set $pack to 0 to skip package installation
	global 			pack 	0
		
* Specify Stata version in use
    global stataVersion 18.5    // set Stata version
    version $stataVersion

* **********************************************************************
* 0 (a) - Create user specific paths
* **********************************************************************

* Define root folder globals

if `"`c(username)'"' == "jdmic" {
        global 		code  	"C:/Users/jdmic/git/mismeasure_weather"
		global 		data	"C:/Users/jdmic/OneDrive - University of Arizona/weather_and_agriculture"
    }
if `"`c(username)'"' == "annal" {
        global 		code  	"C:/Users/aljosephson/git/weather_and_agriculture"
		global 		data	"C:/Users/aljosephson/OneDrive - University of Arizona/weather_and_agriculture"
    }	


* **********************************************************************
* 0 (b) - Check if any required packages are installed:
* **********************************************************************

* install packages if global is set to 1
if $pack == 1 {
	
	* for packages/commands, make a local containing any required packages
		loc userpack "blindschemes mdesc estout distinct winsor2 bumpline colrspace palettes grc1leg2" 
	
	* install packages that are on ssc	
		foreach package in `userpack' {
			capture : which `package', all
			if (_rc) {
				capture window stopbox rusure "You are missing some packages." "Do you want to install `package'?"
				if _rc == 0 {
					capture ssc install `package', replace
					if (_rc) {
						window stopbox rusure `"This package is not on SSC. Do you want to proceed without it?"'
					}
				}
				else {
					exit 199
				}
			}
		}

	* install -xfill- package
		net install xfill, replace from(https://www.sealedenvelope.com/)

	* install -weather- package
		net install WeatherConfig, ///
		from(https://jdavidm.github.io/) replace

	* update all ado files
		ado update, update

	* set graph and Stata preferences
		set scheme plotplain, perm
		set more off
}


* **********************************************************************
* 1 - run weather data cleaning .do file
* **********************************************************************

/*	this code requires access to the raw weather data time series for each true 
	household coordinate, which are confidential and held by the world bank. 
	they are not publicly available.

	do 			"$code/ethiopia/weather_code/eth_ess_masterdo.do"
	do 			"$code/malawi/weather_code/mwi_ihs_masterdo.do"
	do 			"$code/niger/weather_code/ngr_ecvma_masterdo.do"
	do 			"$code/nigeria/weather_code/nga_ghs_masterdo.do"
	do 			"$code/tanzania/weather_code/tza_nps_masterdo.do"
	do 			"$code/uganda/weather_code/uga_unps_masterdo.do"
*/

* **********************************************************************
* 2 - run household data cleaning .do files and merge with weather data
* **********************************************************************

/*	this code requires a user to have downloaded the publicly available 
	household data sets and placed them into the folder structure detailed
	in the readme file accompanying this repo. it also requires access to
	the processed weather data, which is not publicly available but
	can be obtained from the authors by request and with a data sharing
	agreement in place

	do 			"$code/ethiopia/household_code/eth_hh_masterdo.do"
	do 			"$code/malawi/household_code/mwi_hh_masterdo.do"
	do 			"$code/niger/household_code/ngr_hh_masterdo.do"
	do 			"$code/nigeria/household_code/nga_hh_masterdo.do"
	do 			"$code/tanzania/household_code/tza_hh_masterdo.do"
	do 			"$code/uganda/household_code/uga_hh_masterdo.do"
*/

* **********************************************************************
* 4 - run panel build and regression .do files
* **********************************************************************

/*	this code can be run using the publicly available processed weather and
	household data that is posted on Zenodo along with the replication code.
	replication attempts should start here once the country panel data has 
	been placed into the folder structure detailed in the readme.
*/
	do			"$code/analysis/reg_code/panel_build.do"
	do			"$code/analysis/reg_code/regressions.do"

* **********************************************************************
* 4 - run analysis .do files
* **********************************************************************

	do			"$code/analysis/viz_code/mismeasure_sum_table.do"
	do			"$code/analysis/viz_code/mismeasure_sum_vis.do"
	do			"$code/analysis/viz_code/mismeasure_bumpline_vis.do"
	do			"$code/analysis/viz_code/mismeasure_coeff_vis.do"

