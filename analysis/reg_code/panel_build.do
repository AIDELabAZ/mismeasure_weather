* Project: WB Weather - mismeasure paper
* Created on: september 2020
* Created by: jdm
* Edited on: 20 june 2024
* Edited by: jdm
* Stata v.18.5

* does
	* combines data from all countries
	* drops cross sectional data in Malawi and Tanzania
	* outputs data set for final cleaing

* assumes
	* cleaned, merged (weather), and appended (waves) data

* TO DO:
	* need to add new malawi data

	
* **********************************************************************
* 0 - setup
* **********************************************************************

* define paths
	global		source	 	"$data/mismeasure_weather_data/regression_data"
	global		export   	"$data/mismeasure_weather_data/regression_data"
	global		logout 	 	"$data/mismeasure_weather_data/regression_data/logs"

* open log	
	cap log 	close
	log 		using 		"$logout/panel_build", append

	
* **********************************************************************
* 1 - load in ethiopia data
* **********************************************************************

* read in ethiopia
	use				"$source/ethiopia/eth_complete", clear
				
* organize variables
	order			eth_id

* drop unnecessary variables
	drop			uid


* **********************************************************************
* 2 - load in malawi data
* **********************************************************************

* read in data file
	append			using "$source/malawi/mwi_complete.dta"

* organize variables
	order			mwi_id, after(eth_id)		
	
* drop unnecessary variables
	drop			uid cx_id sp_id lp_id
		
		
* **********************************************************************
* 3 - load in niger data
* **********************************************************************

* append niger
	append			using "$source/niger/ngr_complete"
			
* organize variables
	order			ngr_id, after(mwi_id)		
		
* drop unnecessary variables
	drop			uid

	
* **********************************************************************
* 4 - load in nigeria data
* **********************************************************************

* append nigeria
	append			using "$source/nigeria/nga_complete"
			
* organize variables
	order			nga_id, after(ngr_id)	
	order			nga_id, after(eth_id)		
		
* drop unnecessary variables
	drop			uid hhid
		

* **********************************************************************
* 5 - load in tanzania data
* **********************************************************************

* append tanzania
	append			using "$source/tanzania/tza_complete"		

* organize variables
	order			tza_id, after(nga_id)					

* drop unnecessary variables
	drop			uid lp_id sp_id
	
	
* **********************************************************************
* 6 - load in uganda data
* **********************************************************************

* append uganda
	append			using "$source/uganda/uga_complete"		

* organize variables
	order			uga_id, after(tza_id)			
	
* drop unnecessary variables
	drop			uid

	
* **********************************************************************
* 7 - clean combined data
* **********************************************************************

* destring data type
	gen				Dtype = 0 if dtype == "cx"
	replace			Dtype = 1 if dtype == "lp"
	replace			Dtype = 2 if dtype == "sp"
	lab var			Dtype "Data type"
	drop			dtype
	rename			Dtype dtype
	order			dtype, after(country)
	lab def 		dtype 0 "cx" 1 "lp" 2 "sp"
	lab val 		dtype dtype		

* destring country
	gen				Country = 1 if country == "ethiopia"
	replace			Country = 2 if country == "malawi"
	replace			Country = 3 if country == "mali"
	replace			Country = 4 if country == "niger"
	replace			Country = 5 if country == "nigeria"
	replace			Country = 6 if country == "tanzania"
	replace			Country = 7 if country == "uganda"
	lab var			Country "Country"
	drop			country
	rename			Country country
	order			country
	lab def			country 1 "Ethiopia" 2 "Malawi" 3 "Mali" ///
							4 "Niger" 5 "Nigeria" 6 "Tanzania" ///
							7 "Uganda"
	lab val			country country
	sort 			country

* redefine country household ids
	sort 			country eth_id year
	tostring		eth_id, replace
	replace 		eth_id = "eth" + eth_id if eth_id != "."
	replace			eth_id = "" if eth_id == "."
	
	sort 			country mwi_id year
	tostring		mwi_id, replace
	replace 		mwi_id = "mwi" + mwi_id if mwi_id != "."
	replace			mwi_id = "" if mwi_id == "."

	sort 			country ngr_id year
	tostring		ngr_id, replace
	replace 		ngr_id = "ngr" + ngr_id if ngr_id != "."
	replace			ngr_id = "" if ngr_id == "."

	sort 			country nga_id year
	tostring		nga_id, replace
	replace 		nga_id = "nga" + nga_id if nga_id != "."
	replace			nga_id = "" if nga_id == "."
	
	sort 			country tza_id year
	tostring		tza_id, replace
	replace 		tza_id = "tza" + tza_id if tza_id != "."
	replace			tza_id = "" if tza_id == "."
	
	sort 			country uga_id year
	tostring		uga_id, replace
	replace 		uga_id = "uga" + uga_id if uga_id != "."
	replace			uga_id = "" if uga_id == "."

* define cross country household id
	gen				HHID = eth_id if eth_id != ""
	replace			HHID = mwi_id if mwi_id != ""
	replace			HHID = ngr_id if ngr_id != ""
	replace			HHID = nga_id if nga_id != ""
	replace			HHID = tza_id if tza_id != ""
	replace			HHID = uga_id if uga_id != ""
	
	sort			country HHID year
	egen			hhid = group(HHID)
	
	drop			HHID eth_id mwi_id ngr_id nga_id tza_id uga_id ///
					hid old_new track
	order			hhid, after(country)
	lab var			hhid "Unique household ID"
	
* drop temperature bins (for now)
	drop			v23* v24* v25* v26* v27*
		
* create locals for sets of variables
	loc		output		tf_yld cp_yld
	loc 	continputs 	tf_lab tf_frt cp_lab cp_frt		
		
* winsorize data at 1% and 99% per pre-analysis plan
	winsor2 	`output' `continputs', by(country) replace

* convert output variables to logs using invrse hyperbolic sine 
	foreach 		v of varlist `output' {
		qui: gen 		ln`v' = asinh(`v') 
		qui: lab var 	ln`v' "ln of `v'" 
	}

* convert continuous input variables to logs using invrse hyperbolic sine 
	foreach 		v of varlist `continputs' {
		qui: gen 		ln`v' = asinh(`v') 
		qui: lab var 	ln`v' "ln of `v'" 
	}

	order			lntf_yld, before(tf_yld)
	order			lncp_yld, before(cp_yld)
	
	order			lntf_la, before(tf_la)
	order			lncp_lab, before(cp_lab)
	
	order			lntf_frt, before(tf_frt)
	order			lncp_frt, before(cp_frt)
					
					
* **********************************************************************
* 8 - replace missing weather values with zero
* **********************************************************************
	
* replace missing values with zero - cycle through variables
	forvalues		v = 1/9 {
	    
	* cycle through satellites
	    forvalues		s = 1/6 {
			    
				qui: replace			v0`v'_rf`s' = 0 if v0`v'_rf`s' == .	
		}
	}
	
* replace missing values with zero - cycle through variables
	forvalues		v = 10/14 {
	    
	* cycle through satellites
	    forvalues		s = 1/6 {
 
				qui: replace			v`v'_rf`s' = 0 if v`v'_rf`s' == .	
		}
	}
	
* summarize fainfall variables - make sure everything went well
	sum				*rf*
	
* rename variables to have *tp* in name
	forvalues		v = 15/22 {
	    
	* cycle through satellites
	    forvalues		s = 7/9 {

				qui: rename			v`v'_rf`s' v`v'_tp`s'
		}
	}
	
* replace missing values with zero - cycle through variables
	forvalues		v = 15/22 {
	    
	* cycle through satellites
	    forvalues		s = 7/9 {

				qui: replace			v`v'_tp`s' = 0 if v`v'_tp`s' == .	
		}
	}
	
* summarize temp variables - make sure everything went well
	sum				*tp*
/*
* produce list of hhids for Siobhan
	keep 			country hhid year household_id case_id hid nhid y1_hhid y2_hhid y3_hhid y4_hhid uhid
	export 			delimited using "1export'\lsms_panel.csv", replace
*/	
* **********************************************************************
* 9 - end matter
* **********************************************************************

* drop cross section households
	drop if			dtype == 0

* save complete results
	qui: compress
	save "$export/lsms_panel.dta", replace

* close the log
	log	close

/* END */