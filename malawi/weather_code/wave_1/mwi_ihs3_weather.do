* Project: WB Weather
* Created on: April 2020
* Created by: jdm
* edited by: jdm
* edited on: 18 May 2024
* Stata v.18

* does
	* reads in Malawi IHS3, which we term wave 1, .dta files with daily values
    * runs weather_command .ado file
	* outputs .dta file of the relevant weather variables
	* does the above for both rainfall and temperature data
	/* 	-the growing season that we care about is defined on the FAO website:
			http://www.fao.org/giews/countrybrief/country.jsp?code=MWI
		-we measure rainfall during the months that the FAO defines as sowing and growing
		-we define the relevant months as November 1 - April 30 
		-but in code below we keep the Jan 1 to Jul 1 since these are "rename" months */

* assumes
	* daily data converted to .dta
	* weather_command.ado

* TO DO:
	* completed


* **********************************************************************
* 0 - setup
* **********************************************************************

* define paths
	loc 		root 	= 	"$data/weather_data/malawi/wave_1/daily/ihs3_up"
	loc 		export 	= 	"$data/weather_data/malawi/wave_1/refined/ihs3_up"
	loc 		logout 	= 	"$data/weather_data/malawi/logs"

* open log
	cap log		close
	log 		using 		"`logout'/mwi_ihs3_weather", append


* **********************************************************************
* 1 - run command for rainfall
* **********************************************************************

* import the daily ARC2 data file
	use "`root'/ihs3_arc2rf_daily.dta", clear
		
	* define locals to govern file naming	
		loc dat = substr("`file'", 1, length("`file'") - 4) 
		
	* run the user written weather command - this takes a while
		weather rf_ , rain_data ini_month(1) fin_month(7) day_month(1) keep(case_id)
		
	* save file
		compress
		save			"`export'/ihs3_arc2rf.dta", replace

* import the daily CHIRPS data file
	use "`root'/ihs3_chirpsrf_daily.dta", clear
		
	* define locals to govern file naming	
		loc dat = substr("`file'", 1, length("`file'") - 4) 
		
	* run the user written weather command - this takes a while
		weather rf_ , rain_data ini_month(1) fin_month(7) day_month(1) keep(case_id)
		
	* save file
		compress
		save			"`export'/ihs3_chirpsrf.dta", replace

* import the daily CPC RF data file
	use "`root'/ihs3_cpcrf_daily.dta", clear
		
	* define locals to govern file naming	
		loc dat = substr("`file'", 1, length("`file'") - 4) 
		
	* run the user written weather command - this takes a while
		weather rf_ , rain_data ini_month(1) fin_month(7) day_month(1) keep(case_id)
		
	* save file
		compress
		save			"`export'/ihs3_cpcrf.dta", replace

* import the daily ERA5 RF data file
	use "`root'/ihs3_erarf_daily.dta", clear
		
	* define locals to govern file naming	
		loc dat = substr("`file'", 1, length("`file'") - 4) 
		
	* run the user written weather command - this takes a while
		weather rf_ , rain_data ini_month(1) fin_month(7) day_month(1) keep(case_id)
		
	* save file
		compress
		save			"`export'/ihs3_erarf.dta", replace

* import the daily TAMSAT data file
	use "`root'/ihs3_tamsatrf_daily.dta", clear
		
	* define locals to govern file naming	
		loc dat = substr("`file'", 1, length("`file'") - 4) 
		
	* run the user written weather command - this takes a while
		weather rf_ , rain_data ini_month(1) fin_month(7) day_month(1) keep(case_id)
		
	* save file
		compress
		save			"`export'/ihs3_tamsatrf.dta", replace

* import the daily MERRA-2 RF data file
	use "`root'/ihs3_merrarf_daily.dta", clear
		
	* define locals to govern file naming	
		loc dat = substr("`file'", 1, length("`file'") - 4) 
		
	* run the user written weather command - this takes a while
		weather rf_ , rain_data ini_month(1) fin_month(7) day_month(1) keep(case_id)
		
	* save file
		compress
		save			"`export'/ihs3_merrarf.dta", replace

* **********************************************************************
* 2 - run command for temperature
* **********************************************************************

* import the daily CPC TP data file
	use "`root'/ihs3_cpctp_daily.dta", clear
		
	* define locals to govern file naming	
		loc dat = substr("`file'", 1, length("`file'") - 4) 
		
	* run the user written weather command - this takes a while
		weather tmp_ , temperature_data growbase_low(10) growbase_high(30) ini_month(1) fin_month(7) day_month(1) keep(case_id)
		
	* save file
		compress
		save			"`export'/ihs3_cpctp.dta", replace

* import the daily ERA5 TP data file
	use "`root'/ihs3_eratp_daily.dta", clear
		
	* define locals to govern file naming	
		loc dat = substr("`file'", 1, length("`file'") - 4) 
		
	* run the user written weather command - this takes a while
		weather tmp_ , temperature_data growbase_low(10) growbase_high(30) ini_month(1) fin_month(7) day_month(1) keep(case_id)
		
	* save file
		compress
		save			"`export'/ihs3_eratp.dta", replace

* import the daily MERRA-2 TP data file
	use "`root'/ihs3_merratp_daily.dta", clear
		
	* define locals to govern file naming	
		loc dat = substr("`file'", 1, length("`file'") - 4) 
		
	* run the user written weather command - this takes a while
		weather tmp_ , temperature_data growbase_low(10) growbase_high(30) ini_month(1) fin_month(7) day_month(1) keep(case_id)
		
	* save file
		compress
		save			"`export'/ihs3_merratp.dta", replace


* close the log
	log	close

/* END */
