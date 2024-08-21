*** START ***
* graphs for mismeasure 
* created by: alj
* created on: 19 august 2024
* edited by: alj
* edited on: 20 august 2024

* this code is not currently replicable 


	
************************************************************************
**# 0 - setup
************************************************************************

* define paths
	global	root 	= 	"$data/results_data"
	global	stab 	= 	"$data/results_data/tables"
	global	xtab 	= 	"$data/output/mismeasure_paper/tables"
	global	sfig	= 	"$data/results_data/figures"	
	global 	xfig    =   "$data/output/mismeasure_paper/figures"
	global	logout 	= 	"$data/results_data/logs"
	* s indicates Stata figures, works in progress
	* x indicates final version for paper 
	
* open log	
	cap log close
	log 	using 	"$logout/mismeasure_bump", append


************************************************************************
**# 1 - generate (non)-significant indicators
************************************************************************

set scheme white_tableau  
graph set window fontface "Arial Narrow"

* load data 
	use 			"$root/lsms_complete_results", clear
	frames 			reset
	frame 			create rainfall
	frame 			rainfall: use "$root/lsms_complete_results"
	
	frame 			create temperature
	frame 			temperature: use "$root/lsms_complete_results"


frame change rainfall

lab define 	sat 3 "CPC" 4 "ERA5" 5 "MERRA-2", modify

*** TOTAL SEASONAL RAINFALL ***

preserve
keep if			varname == 5
keep if			regname < 4

sort country depvar regname varname sat

egen reg_num = group(country regname depvar)

replace reg_num = reg_num + 1 if country > 1
replace reg_num = reg_num + 1 if country > 2
replace reg_num = reg_num + 1 if country > 3
replace reg_num = reg_num + 1 if country > 4
replace reg_num = reg_num + 1 if country > 5
replace reg_num = reg_num + 1 if country > 6

lab define 		reg_name 1 "Eth, W, Q" 2 "Eth, W, V" 3 "Eth, W+FE, Q" ///
					4 "Eth, W+FE, V" 5 "Eth, W+FE+I, Q" 6 "Eth, W+FE+I, V" ///
					8 "Mwi, W, Q" 9 "Mwi, W, V" 10 "Mwi, W+FE, Q" ///
					11 "Mwi, W+FE, V" 12 "Mwi, W+FE+I, Q" 13 "Mwi, W+FE+I, V" ///
					16 "Ngr, W, Q" 17 "Ngr, W, V" 18 "Ngr, W+FE, Q" ///
					19 "Ngr, W+FE, V" 20 "Ngr, W+FE+I, Q" 21 "Ngr, W+FE+I, V" ///
					23 "Nga, W, Q" 24 "Nga, W, V" 25 "Nga, W+FE, Q" ///
					26 "Nga, W+FE, V" 27 "Nga, W+FE+I, Q" 28 "Nga, W+FE+I, V" ///
					30 "Tza, W, Q" 31 "Tza, W, V" 32 "Tza, W+FE, Q" ///
					33 "Tza, W+FE, V" 34 "Tza, W+FE+I, Q" 34 "Tza, W+FE+I, V" ///
					37 "Uga, W, Q" 38 "Uga, W, V" 39 "Uga, W+FE, Q" ///
					40 "Uga, W+FE, V" 41 "Uga, W+FE+I, Q" 42 "Uga, W+FE+I, V", replace
					
label values reg_num reg_name

bumpline beta reg_num, by(sat) top(6) xsize(2) ysize(1) smooth(4) ///
	lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
	xtitle("Regression") ytitle("Coefficient Rank") ///
	xlab(, valuelabel angle(45))
	
	graph export 	"$xfig\v5_bump.pdf", as(pdf) replace
	
restore

*** TOTAL SEASONAL RAINFALL ***


clear

import excel "$data\output\mismeasure_paper\bumpline.xlsx", sheet("total_seasonal") firstrow



rename F ord6
rename G ord5
rename H ord4
rename I ord3
rename J ord2
rename K ord1

egen rg_vg = concat(country reg_type value1quantity2)

reshape long ord, i(rg_vg) j(count)

rename ord source
replace source = "ARC2" if source == "ARC"
replace source = "ERA5" if source == "ERA"
replace source = "ERA5" if source == "ERA5 "
replace source = "MERRA2" if source == "MERRA "
replace source = "MERRA2" if source == "MERRA"
replace source = "TAMSAT" if source == "TAMSAT "
tab source

destring rg_vg, generate(reg_vg)

egen reg_num = group(reg_vg)

bumpline count reg_num, by(source) xsize(2) ysize(1)  ///
	lw(0.5) msym(square) mlwid(0.3) msize(1.1) xlaba(45) offset(20) ///
	xtitle("Regression Number") ytitle("Coefficient Rank") 

*** NO RAIN DAYS ***

clear

import excel "C:\Users\aljosephson\OneDrive - University of Arizona\weather_and_agriculture\output\mismeasure_paper\bumpline.xlsx", sheet("no_rain_days") firstrow
rename F ord6
rename G ord5
rename H ord4
rename I ord3
rename J ord2
rename K ord1

egen rg_vg = concat(country reg_type value1quantity2)

reshape long ord, i(rg_vg) j(count)

rename ord source
replace source = "ARC2" if source == "ARC"
replace source = "MERRA2" if source == "MERRA"
tab source

destring rg_vg, generate(reg_vg)

bumpline count reg_vg , by(source)


*** MEAN TEMPERATURE ***

clear

import excel "C:\Users\aljosephson\OneDrive - University of Arizona\weather_and_agriculture\output\mismeasure_paper\bumpline.xlsx", sheet("mean_temp") firstrow
rename F ord3
rename G ord2
rename H ord1


egen rg_vg = concat(country reg_type value1quantity2)

reshape long ord, i(rg_vg) j(count)

rename ord source

destring rg_vg, generate(reg_vg)

bumpline count reg_vg , by(source)


*** GDD ***

clear

import excel "C:\Users\aljosephson\OneDrive - University of Arizona\weather_and_agriculture\output\mismeasure_paper\bumpline.xlsx", sheet("GDD") firstrow
rename F ord3
rename G ord2
rename H ord1


egen rg_vg = concat(country reg_type value1quantity2)

reshape long ord, i(rg_vg) j(count)

rename ord source
replace source = "ERA5" if source == "ERA5 "
replace source = "MERRA2" if source == "MER"
replace source = "MERRA2" if source == "MERA"

destring rg_vg, generate(reg_vg)

bumpline count reg_vg , by(source)

*** END *** 