*** START ***
* graphs for mismeasure 
* created by: alj
* created on: 19 august 2024
* edited by: jdm
* edited on: 11 Dec 2024

* this code is not currently replicable 


	
************************************************************************
**# 0 - setup
************************************************************************

* define paths
	global	root 	= 	"$data/mismeasure_weather_data/results_data"
	global	stab 	= 	"$data/mismeasure_weather_data/results_data/tables"
	global	xtab 	= 	"$data/mismeasure_weather_data/paper/tables"
	global	sfig	= 	"$data/mismeasure_weather_data/results_data/figures"	
	global 	xfig    =   "$data/mismeasure_weather_data/paper/figures"
	global	logout 	= 	"$data/mismeasure_weather_data/results_data/logs"
	* s indicates Stata figures, works in progress
	* x indicates final version for paper 
	
* open log	
	cap log close
	log 	using 	"$logout/mismeasure_bump", append


************************************************************************
**# 1 - set up frames for analysis
************************************************************************

*set scheme white_tableau  
graph set window fontface "Arial Narrow"

* load data 
	use 			"$root/lsms_complete_results", clear
	frames 			reset
	frame 			create rainfall
	frame 			rainfall: use "$root/lsms_complete_results"
	
	frame 			create temperature
	frame 			temperature: use "$root/lsms_complete_results"

	
************************************************************************
**# 2 - generate rainfall bumpline plots 
************************************************************************

frame change rainfall

lab define 	sat 3 "CPC" 4 "ERA5" 5 "MERRA-2", modify

*** TOTAL SEASONAL RAINFALL ***


preserve
keep if			varname == 5
keep if			regname < 4

sort country regname depvar varname sat

egen reg_num = group(country regname depvar)

replace reg_num = reg_num + 1 if country > 1
replace reg_num = reg_num + 1 if country > 2
replace reg_num = reg_num + 1 if country > 3
replace reg_num = reg_num + 1 if country > 4
replace reg_num = reg_num + 1 if country > 5
replace reg_num = reg_num + 1 if country > 6

lab define 		reg_name 1 "W, Qty" 2 "W, Val" 3 "W + FE, Qty" 4 "W + FE, Val" ///
					6 "W, Qty" 7 "W, Val" 8 "W+  FE, Qty" 9 "W + FE, Val" ///
					12 "W, Qty" 13 "W, Val" 14 "W + FE, Qty" 15 "W + FE, Val" ///
					17 "W, Qty" 18 "W, Val" 19 "W + FE, Qty" 20 "W + FE, Val" ///
					22 "W, Qty" 23 "W, Val" 24 "W + FE, Qty" 25 "W + FE, Val" ///
					27 "W, Qty" 28 "W, Val" 29 "W + FE, Qty" 30 "W + FE, Val", replace
					
label values reg_num reg_name

bumpline beta reg_num if country == 1, by(sat) top(6) xsize(2) ysize(1) smooth(4) ///
	lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
	xtitle("Ethiopia") ytitle("Coefficient Rank") palette(viridis) ///
	xlab(, valuelabel angle(45)) saving("$sfig/eth_v5_bump", replace)

bumpline beta reg_num if country == 2, by(sat) top(6) xsize(2) ysize(1) smooth(4) ///
	lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
	xtitle("Malawi") ytitle("") palette(viridis) ///
	xlab(, valuelabel angle(45)) saving("$sfig/mwi_v5_bump", replace)

bumpline beta reg_num if country == 4, by(sat) top(6) xsize(2) ysize(1) smooth(4) ///
	lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
	xtitle("Niger") ytitle("") palette(viridis) ///
	xlab(, valuelabel angle(45)) saving("$sfig/ngr_v5_bump", replace)

bumpline beta reg_num if country == 5, by(sat) top(6) xsize(2) ysize(1) smooth(4) ///
	lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
	xtitle("Nigeria") ytitle("") palette(viridis) ///
	xlab(, valuelabel angle(45)) saving("$sfig/nga_v5_bump", replace)

bumpline beta reg_num if country == 6, by(sat) top(6) xsize(2) ysize(1) smooth(4) ///
	lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
	xtitle("Tanzania") ytitle("") palette(viridis) ///
	xlab(, valuelabel angle(45)) saving("$sfig/tza_v5_bump", replace)

bumpline beta reg_num if country == 7, by(sat) top(6) xsize(2) ysize(1) smooth(4) ///
	lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
	xtitle("Uganda") ytitle("") palette(viridis) ///
	xlab(, valuelabel angle(45)) saving("$sfig/uga_v5_bump", replace)
	

restore

	gr combine 		"$sfig/eth_v5_bump.gph" "$sfig/mwi_v5_bump.gph" "$sfig/ngr_v5_bump.gph" ///
						"$sfig/nga_v5_bump.gph" "$sfig/tza_v5_bump.gph" "$sfig/uga_v5_bump.gph", ///
						col(2) iscale(.5) commonscheme
						
	graph export 	"$xfig\v5_bump.png", as(png) replace


*** DAYS WITHOUT RAIN ***

preserve
keep if			varname == 10
keep if			regname < 4

sort country regname depvar varname sat

egen reg_num = group(country regname depvar)

replace reg_num = reg_num + 1 if country > 1
replace reg_num = reg_num + 1 if country > 2
replace reg_num = reg_num + 1 if country > 3
replace reg_num = reg_num + 1 if country > 4
replace reg_num = reg_num + 1 if country > 5
replace reg_num = reg_num + 1 if country > 6


lab define 		reg_name 1 "W, Qty" 2 "W, Val" 3 "W + FE, Qty" 4 "W + FE, Val" ///
					6 "W, Qty" 7 "W, Val" 8 "W+  FE, Qty" 9 "W + FE, Val" ///
					12 "W, Qty" 13 "W, Val" 14 "W + FE, Qty" 15 "W + FE, Val" ///
					17 "W, Qty" 18 "W, Val" 19 "W + FE, Qty" 20 "W + FE, Val" ///
					22 "W, Qty" 23 "W, Val" 24 "W + FE, Qty" 25 "W + FE, Val" ///
					27 "W, Qty" 28 "W, Val" 29 "W + FE, Qty" 30 "W + FE, Val", replace
					
label values reg_num reg_name

bumpline beta reg_num if country == 1, by(sat) top(6) xsize(2) ysize(1) smooth(4) ///
	lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
	xtitle("Ethiopia") ytitle("Coefficient Rank") palette(viridis) ///
	xlab(, valuelabel angle(45)) saving("$sfig/eth_v10_bump", replace)

bumpline beta reg_num if country == 2, by(sat) top(6) xsize(2) ysize(1) smooth(4) ///
	lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
	xtitle("Malawi") ytitle("") palette(viridis) ///
	xlab(, valuelabel angle(45)) saving("$sfig/mwi_v10_bump", replace)

bumpline beta reg_num if country == 4, by(sat) top(6) xsize(2) ysize(1) smooth(4) ///
	lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
	xtitle("Niger") ytitle("") palette(viridis) ///
	xlab(, valuelabel angle(45)) saving("$sfig/ngr_v10_bump", replace)

bumpline beta reg_num if country == 5, by(sat) top(6) xsize(2) ysize(1) smooth(4) ///
	lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
	xtitle("Nigeria") ytitle("") palette(viridis) ///
	xlab(, valuelabel angle(45)) saving("$sfig/nga_v10_bump", replace)

bumpline beta reg_num if country == 6, by(sat) top(6) xsize(2) ysize(1) smooth(4) ///
	lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
	xtitle("Tanzania") ytitle("") palette(viridis) ///
	xlab(, valuelabel angle(45)) saving("$sfig/tza_v10_bump", replace)

bumpline beta reg_num if country == 7, by(sat) top(6) xsize(2) ysize(1) smooth(4) ///
	lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
	xtitle("Uganda") ytitle("") palette(viridis) ///
	xlab(, valuelabel angle(45)) saving("$sfig/uga_v10_bump", replace)
	

restore

	gr combine 		"$sfig/eth_v10_bump.gph" "$sfig/mwi_v10_bump.gph" "$sfig/ngr_v10_bump.gph" ///
						"$sfig/nga_v10_bump.gph" "$sfig/tza_v10_bump.gph" "$sfig/uga_v10_bump.gph", ///
						col(2) iscale(.5) commonscheme
						
	graph export 	"$xfig\v10_bump.png", as(png) replace
	
	

************************************************************************
**# 3 - generate temp bumpline plots 
************************************************************************

frame change temperature 

lab define 	sat 3 "CPC" 4 "ERA5" 5 "MERRA-2", modify

*** MEAN TEMPERATURE  ***


preserve
keep if			varname == 15
keep if			regname < 4

sort country regname depvar varname sat

egen reg_num = group(country regname depvar)

replace reg_num = reg_num + 1 if country > 1
replace reg_num = reg_num + 1 if country > 2
replace reg_num = reg_num + 1 if country > 3
replace reg_num = reg_num + 1 if country > 4
replace reg_num = reg_num + 1 if country > 5
replace reg_num = reg_num + 1 if country > 6

lab define 		reg_name 1 "W, Qty" 2 "W, Val" 3 "W + FE, Qty" 4 "W + FE, Val" ///
					6 "W, Qty" 7 "W, Val" 8 "W+  FE, Qty" 9 "W + FE, Val" ///
					12 "W, Qty" 13 "W, Val" 14 "W + FE, Qty" 15 "W + FE, Val" ///
					17 "W, Qty" 18 "W, Val" 19 "W + FE, Qty" 20 "W + FE, Val" ///
					22 "W, Qty" 23 "W, Val" 24 "W + FE, Qty" 25 "W + FE, Val" ///
					27 "W, Qty" 28 "W, Val" 29 "W + FE, Qty" 30 "W + FE, Val", replace
					
label values reg_num reg_name

bumpline beta reg_num if country == 1, by(sat) top(6) xsize(2) ysize(1) smooth(4) ///
	lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
	xtitle("Ethiopia") ytitle("Coefficient Rank") palette(viridis) ///
	xlab(, valuelabel angle(45)) saving("$sfig/eth_v15_bump", replace)

bumpline beta reg_num if country == 2, by(sat) top(6) xsize(2) ysize(1) smooth(4) ///
	lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
	xtitle("Malawi") ytitle("") palette(viridis) ///
	xlab(, valuelabel angle(45)) saving("$sfig/mwi_v15_bump", replace)

bumpline beta reg_num if country == 4, by(sat) top(6) xsize(2) ysize(1) smooth(4) ///
	lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
	xtitle("Niger") ytitle("") palette(viridis) ///
	xlab(, valuelabel angle(45)) saving("$sfig/ngr_v15_bump", replace)

bumpline beta reg_num if country == 5, by(sat) top(6) xsize(2) ysize(1) smooth(4) ///
	lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
	xtitle("Nigeria") ytitle("") palette(viridis) ///
	xlab(, valuelabel angle(45)) saving("$sfig/nga_v15_bump", replace)

bumpline beta reg_num if country == 6, by(sat) top(6) xsize(2) ysize(1) smooth(4) ///
	lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
	xtitle("Tanzania") ytitle("") palette(viridis) ///
	xlab(, valuelabel angle(45)) saving("$sfig/tza_v15_bump", replace)

bumpline beta reg_num if country == 7, by(sat) top(6) xsize(2) ysize(1) smooth(4) ///
	lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
	xtitle("Uganda") ytitle("") palette(viridis) ///
	xlab(, valuelabel angle(45)) saving("$sfig/uga_v15_bump", replace)
	

restore

	gr combine 		"$sfig/eth_v15_bump.gph" "$sfig/mwi_v15_bump.gph" "$sfig/ngr_v15_bump.gph" ///
						"$sfig/nga_v15_bump.gph" "$sfig/tza_v15_bump.gph" "$sfig/uga_v15_bump.gph", ///
						col(2) iscale(.5) commonscheme
						
	graph export 	"$xfig\v15_bump.png", as(png) replace


*** GDD ***

preserve
keep if			varname == 19
keep if			regname < 4

sort country regname depvar varname sat

egen reg_num = group(country regname depvar)

replace reg_num = reg_num + 1 if country > 1
replace reg_num = reg_num + 1 if country > 2
replace reg_num = reg_num + 1 if country > 3
replace reg_num = reg_num + 1 if country > 4
replace reg_num = reg_num + 1 if country > 5
replace reg_num = reg_num + 1 if country > 6

lab define 		reg_name 1 "W, Qty" 2 "W, Val" 3 "W + FE, Qty" 4 "W + FE, Val" ///
					6 "W, Qty" 7 "W, Val" 8 "W+  FE, Qty" 9 "W + FE, Val" ///
					12 "W, Qty" 13 "W, Val" 14 "W + FE, Qty" 15 "W + FE, Val" ///
					17 "W, Qty" 18 "W, Val" 19 "W + FE, Qty" 20 "W + FE, Val" ///
					22 "W, Qty" 23 "W, Val" 24 "W + FE, Qty" 25 "W + FE, Val" ///
					27 "W, Qty" 28 "W, Val" 29 "W + FE, Qty" 30 "W + FE, Val", replace
					
label values reg_num reg_name

bumpline beta reg_num if country == 1, by(sat) top(6) xsize(2) ysize(1) smooth(4) ///
	lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
	xtitle("Ethiopia") ytitle("Coefficient Rank") palette(viridis) ///
	xlab(, valuelabel angle(45)) saving("$sfig/eth_v19_bump", replace)

bumpline beta reg_num if country == 2, by(sat) top(6) xsize(2) ysize(1) smooth(4) ///
	lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
	xtitle("Malawi") ytitle("") palette(viridis) ///
	xlab(, valuelabel angle(45)) saving("$sfig/mwi_v19_bump", replace)

bumpline beta reg_num if country == 4, by(sat) top(6) xsize(2) ysize(1) smooth(4) ///
	lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
	xtitle("Niger") ytitle("") palette(viridis) ///
	xlab(, valuelabel angle(45)) saving("$sfig/ngr_v19_bump", replace)

bumpline beta reg_num if country == 5, by(sat) top(6) xsize(2) ysize(1) smooth(4) ///
	lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
	xtitle("Nigeria") ytitle("") palette(viridis) ///
	xlab(, valuelabel angle(45)) saving("$sfig/nga_v19_bump", replace)

bumpline beta reg_num if country == 6, by(sat) top(6) xsize(2) ysize(1) smooth(4) ///
	lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
	xtitle("Tanzania") ytitle("") palette(viridis) ///
	xlab(, valuelabel angle(45)) saving("$sfig/tza_v19_bump", replace)

bumpline beta reg_num if country == 7, by(sat) top(6) xsize(2) ysize(1) smooth(4) ///
	lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
	xtitle("Uganda") ytitle("") palette(viridis) ///
	xlab(, valuelabel angle(45)) saving("$sfig/uga_v19_bump", replace)
	

restore

	gr combine 		"$sfig/eth_v19_bump.gph" "$sfig/mwi_v19_bump.gph" "$sfig/ngr_v19_bump.gph" ///
						"$sfig/nga_v19_bump.gph" "$sfig/tza_v19_bump.gph" "$sfig/uga_v19_bump.gph", ///
						col(2) iscale(.5) commonscheme
						
	graph export 	"$xfig\v19_bump.png", as(png) replace
	

* close the log
	log	close

/* END */	
	