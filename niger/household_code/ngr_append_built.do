* Project: WB Weather
* Created on: July 2020
* Created by: ek
* Edited on: 7 June 2024
* Edited by: jdm
* Stata v.18

* does
	* reads in merged data sets
	* appends both complete data set (W1-W2)
	* outputs Niger data sets for analysis

* assumes
	* all Niger data has been cleaned and merged with rainfall
	* xfill.ado

* TO DO:
	* complete
	
	
* **********************************************************************
* 0 - setup
* **********************************************************************

* define paths
	global		root 	= 	"$data/merged_data/niger"
	global		export 	= 	"$data/regression_data/niger"
	global		logout 	= 	"$data/merged_data/niger/logs"

* open log	
	cap 		log 		close 
	log 		using 		"$logout/ngr_append_built", append

	
* **********************************************************************
* 1 - merge first three waves of Niger household data
* **********************************************************************

* using merge rather than append
* import wave 1 niger
	use 			"$root/wave_1/ecvmay1_merged", clear
	
* append wave 2 file
	append			using "$root/wave_2/ecvmay2_merged", force	
		
	
* check the number of observations again
	count
	*** 3,951 observations 
	count if 		year == 2011
	*** wave 1 has 2,223
	count if 		year == 2014
	*** wave 2 has  1,728

* create household panel id
	sort			hid year
	egen			ngr_id = group(hid)
	lab var			ngr_id "Niger panel household id"
	
	drop			if extension == "1" | extension == "2"
	*** 39 observations deleted

	gen				country = "niger"
	lab var			country "Country"

	gen				dtype = "lp"
	lab var			dtype "Data type"
	
	isid			ngr_id year

* fill in missing aez
	xtset			ngr_id
	xfill			aez, i(ngr_id)
	*** 97 still missing

	replace			aez = 311 if aez == . & region == 1
	replace			aez = 312 if aez == . & region == 3
	replace			aez = 312 if aez == . & region == 4
	replace			aez = 312 if aez == . & region == 8
	*** 41 still missing

	replace			aez = 311 if aez == . & dept == 21
	replace			aez = 312 if aez == . & dept == 51
	replace			aez = 312 if aez == . & dept == 53
	replace			aez = 312 if aez == . & dept == 56
	replace			aez = 312 if aez == . & dept == 57
	replace			aez = 311 if aez == . & dept == 61
	replace			aez = 312 if aez == . & dept == 62
	replace			aez = 312 if aez == . & dept == 63
	replace			aez = 312 if aez == . & dept == 64
	replace			aez = 312 if aez == . & dept == 65
	replace			aez = 312 if aez == . & dept == 66
	replace			aez = 312 if aez == . & dept == 71
	replace			aez = 311 if aez == . & dept == 72
	replace			aez = 312 if aez == . & dept == 75
	*** 0 missing
	
* order variables
	drop			extension region dept canton enumeration clusterid ///
						hhid_y2
	
	order			country dtype ngr_id pw aez year 
	
* label household variables	
	lab var			tf_lnd	"Total farmed area (ha)"
	lab var			tf_hrv	"Total value of harvest (2010 USD)"
	lab var			tf_yld	"value of yield (2010 USD/ha)"
	lab var			tf_lab	"labor rate (days/ha)"
	lab var			tf_frt	"fertilizer rate (kg/ha)"
	lab var			tf_pst	"Any plot has pesticide"
	lab var			tf_hrb	"Any plot has herbicide"
	lab var			tf_irr	"Any plot has irrigation"
	lab var			cp_lnd	"Total maize area (ha)"
	lab var			cp_hrv	"Total quantity of maize harvest (kg)"
	lab var			cp_yld	"Maize yield (kg/ha)"
	lab var			cp_lab	"labor rate for maize (days/ha)"
	lab var			cp_frt	"fertilizer rate for maize (kg/ha)"
	lab var			cp_pst	"Any maize plot has pesticide"
	lab var			cp_hrb	"Any maize plot has herbicide"
	lab var			cp_irr	"Any maize plot has irrigation"
	lab var 		data "Data Source"	

* generate remote sensing product variables
	gen				sat1 = 1
	order			sat1, before(v01_arc2r)
	gen				sat2 = 2
	order			sat2, before(v01_chirp)
	gen				sat3 = 3
	order			sat3, before(v01_cpcrf)
	gen				sat4 = 4
	order			sat4, before(v01_erarf)
	gen				sat5 = 5
	order			sat5, before(v01_merra)
	gen				sat6 = 6
	order			sat6, before(v01_tamsa)
	gen				sat7 = 7
	order			sat7, before(v15_cpctp)
	gen				sat8 = 8
	order			sat8, before(v15_eratp)
	gen				sat9 = 9
	order			sat9, before(v15_merra)
	lab define 		sat 1 "ARC2" 2 "CHIRPS" 3 "CPC" 4 "ERA5" 5 "MERRA-2" ///
						6 "TAMSAT" 7 "CPC" 8 "ERA5" 9 "MERRA-2"
						
* label satellites variables
	loc	sat			sat*
	foreach v of varlist `sat' {
		lab var 		`v' "Satellite/Extraction"
		lab val 		`v' sat
	}

* rename rainfall variables
foreach var of varlist *arc2r {
		loc 		dat = substr("`var'", 1, 3)
		rename		`var' `dat'_rf1
	}
foreach var of varlist *chirp {
		loc 		dat = substr("`var'", 1, 3)
		rename		`var' `dat'_rf2
	}
foreach var of varlist *cpcrf {
		loc 		dat = substr("`var'", 1, 3)
		rename		`var' `dat'_rf3
	}
foreach var of varlist *erarf {
		loc 		dat = substr("`var'", 1, 3)
		rename		`var' `dat'_rf4
	}
foreach var of varlist v01_merra - v14_merra {
		loc 		dat = substr("`var'", 1, 3)
		rename		`var' `dat'_rf5
	}
foreach var of varlist *tamsa {
		loc 		dat = substr("`var'", 1, 3)
		rename		`var' `dat'_rf6
	}
foreach var of varlist *cpctp {
		loc 		dat = substr("`var'", 1, 3)
		rename		`var' `dat'_rf7
	}
foreach var of varlist *eratp {
		loc 		dat = substr("`var'", 1, 3)
		rename		`var' `dat'_rf8
	}
foreach var of varlist v15_merra - v27_merra {
		loc 		dat = substr("`var'", 1, 3)
		rename		`var' `dat'_rf9
	}
	
* label rainfall variables	
	loc	v01			v01*
	foreach v of varlist `v01' {
		lab var 		`v' "Mean Daily Rainfall"	
	}	
	
	loc	v02			v02*
	foreach v of varlist `v02' {
		lab var 		`v' "Median Daily Rainfall"
	}					
	
	loc	v03			v03*
	foreach v of varlist `v03' {
		lab var 		`v' "Variance of Daily Rainfall"
	}					
	
	loc	v04			v04*
	foreach v of varlist `v04' {
		lab var 		`v'  "Skew of Daily Rainfall"
	}					
	
	loc	v05			v05*
	foreach v of varlist `v05' {
		lab var 		`v'  "Total Rainfall"
	}					
	
	loc	v06			v06*
	foreach v of varlist `v06' {
		lab var 		`v' "Deviation in Total Rainfalll"
	}					
	
	loc	v07			v07*
	foreach v of varlist `v07' {
		lab var 		`v' "Z-Score of Total Rainfall"	
	}					
	
	loc	v08			v08*
	foreach v of varlist `v08' {
		lab var 		`v' "Rainy Days"
	}					
	
	loc	v09			v09*
	foreach v of varlist `v09' {
		lab var 		`v' "Deviation in Rainy Days"	
	}					
	
	loc	v10			v10*
	foreach v of varlist `v10' {
		lab var 		`v' "No Rain Days"
	}					
	
	loc	v11			v11*
	foreach v of varlist `v11' {
		lab var 		`v' "Deviation in No Rain Days"
	}					
	
	loc	v12			v12*
	foreach v of varlist `v12' {
		lab var 		`v' "% Rainy Days"	
	}					
	
	loc	v13			v13*
	foreach v of varlist `v13' {
		lab var 		`v' "Deviation in % Rainy Days"	
	}					
	
	loc	v14			v14*
	foreach v of varlist `v14' {
		lab var 		`v' "Longest Dry Spell"	
	}									

* label weather variables	
	loc	v15			v15*
	foreach v of varlist `v15' {
		lab var 		`v' "Mean Daily Temperature"
	}
	
	loc	v16			v16*
	foreach v of varlist `v16' {
		lab var 		`v' "Median Daily Temperature"
	}
	
	loc	v17			v17*
	foreach v of varlist `v17' {
		lab var 		`v' "Variance of Daily Temperature"
	}
	
	loc	v18			v18*
	foreach v of varlist `v18' {
		lab var 		`v' "Skew of Daily Temperature"	
	}
	
	loc	v19			v19*
	foreach v of varlist `v19' {
		lab var 		`v' "Growing Degree Days (GDD)"	
	}
	
	loc	v20			v20*
	foreach v of varlist `v20' {
		lab var 		`v' "Deviation in GDD"		
	}
	
	loc	v21			v21*
	foreach v of varlist `v21' {
		lab var 		`v' "Z-Score of GDD"	
	}
	
	loc	v22			v22*
	foreach v of varlist `v22' {
		lab var 		`v' "Maximum Daily Temperature"
	}
	
	loc	v23			v23*
	foreach v of varlist `v23' {
		lab var 		`v' "Temperature Bin 0-20"	
	}
	
	loc	v24			v24*
	foreach v of varlist `v24' {
		lab var 		`v' "Temperature Bin 20-40"	
	}
	
	loc	v25			v25*
	foreach v of varlist `v25' {
		lab var 		`v' "Temperature Bin 40-60"
	}
	
	loc	v26			v26*
	foreach v of varlist `v26' {
		lab var 		`v' "Temperature Bin 60-80"		
	}
	
	
* **********************************************************************
* 4 - End matter
* **********************************************************************

* create household, country, and data identifiers
	sort			ngr_id year
	egen			uid = seq()
	lab var			uid "unique id"
	
* order variables
	order			uid ngr_id
	
* save file
	qui: compress
	save			"$export/ngr_complete.dta", replace 

* close the log
	log	close

/* END */

