* Project: WB Weather - mismeasure paper
* Created on: august 2024
* Created by: alj
* Edited on: 8 july 2025
* Edited by: jdm
* Stata v.18.5

* does
	* reads in results data set
	* makes visualziations of results using bumpline
	* graphs represent coefficient rank

* assumes
	* you have results file 
	* bumpline.ado

* TO DO:
	* add bumpline for all variables and all specifications

	
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


************************************************************************
**## 2.1 - total seasonal rainfall
************************************************************************

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
					6 "W, Qty" 7 "W, Val" 8 "W +  FE, Qty" 9 "W + FE, Val" ///
					12 "W, Qty" 13 "W, Val" 14 "W + FE, Qty" 15 "W + FE, Val" ///
					17 "W, Qty" 18 "W, Val" 19 "W + FE, Qty" 20 "W + FE, Val" ///
					22 "W, Qty" 23 "W, Val" 24 "W + FE, Qty" 25 "W + FE, Val" ///
					27 "W, Qty" 28 "W, Val" 29 "W + FE, Qty" 30 "W + FE, Val", replace
					
label values reg_num reg_name

bumpline beta reg_num if country == 1, by(sat) top(6) xsize(2) ysize(1) smooth(4) ///
	lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
	title("Ethiopia") xtitle("") ytitle("Coefficient Rank") palette(viridis) ///
	xlab(, valuelabel angle(45)) saving("$sfig/eth_v5_bump", replace)

bumpline beta reg_num if country == 2, by(sat) top(6) xsize(2) ysize(1) smooth(4) ///
	lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
	title("Malawi") xtitle("") ytitle("") palette(viridis) ///
	xlab(, valuelabel angle(45)) saving("$sfig/mwi_v5_bump", replace)

bumpline beta reg_num if country == 4, by(sat) top(6) xsize(2) ysize(1) smooth(4) ///
	lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
	title("Niger") xtitle("") ytitle("Coefficient Rank") palette(viridis) ///
	xlab(, valuelabel angle(45)) saving("$sfig/ngr_v5_bump", replace)

bumpline beta reg_num if country == 5, by(sat) top(6) xsize(2) ysize(1) smooth(4) ///
	lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
	title("Nigeria") xtitle("") ytitle("") palette(viridis) ///
	xlab(, valuelabel angle(45)) saving("$sfig/nga_v5_bump", replace)

bumpline beta reg_num if country == 6, by(sat) top(6) xsize(2) ysize(1) smooth(4) ///
	lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
	title("Tanzania") xtitle("") ytitle("Coefficient Rank") palette(viridis) ///
	xlab(, valuelabel angle(45)) saving("$sfig/tza_v5_bump", replace)

bumpline beta reg_num if country == 7, by(sat) top(6) xsize(2) ysize(1) smooth(4) ///
	lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
	title("Uganda") xtitle("") ytitle("") palette(viridis) ///
	xlab(, valuelabel angle(45)) saving("$sfig/uga_v5_bump", replace)
	

restore

	gr combine 		"$sfig/eth_v5_bump.gph" "$sfig/mwi_v5_bump.gph" "$sfig/ngr_v5_bump.gph" ///
						"$sfig/nga_v5_bump.gph" "$sfig/tza_v5_bump.gph" "$sfig/uga_v5_bump.gph", ///
						col(2) iscale(.5) commonscheme
						
	graph export 	"$xfig\v5_bump.pdf", as(pdf) replace


************************************************************************
**## 2.2 - days without rain
************************************************************************

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
					6 "W, Qty" 7 "W, Val" 8 "W +  FE, Qty" 9 "W + FE, Val" ///
					12 "W, Qty" 13 "W, Val" 14 "W + FE, Qty" 15 "W + FE, Val" ///
					17 "W, Qty" 18 "W, Val" 19 "W + FE, Qty" 20 "W + FE, Val" ///
					22 "W, Qty" 23 "W, Val" 24 "W + FE, Qty" 25 "W + FE, Val" ///
					27 "W, Qty" 28 "W, Val" 29 "W + FE, Qty" 30 "W + FE, Val", replace
					
label values reg_num reg_name

bumpline beta reg_num if country == 1, by(sat) top(6) xsize(2) ysize(1) smooth(4) ///
	lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
	title("Ethiopia") xtitle("") ytitle("Coefficient Rank") palette(viridis) ///
	xlab(, valuelabel angle(45)) saving("$sfig/eth_v10_bump", replace)

bumpline beta reg_num if country == 2, by(sat) top(6) xsize(2) ysize(1) smooth(4) ///
	lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
	title("Malawi") xtitle("") ytitle("") palette(viridis) ///
	xlab(, valuelabel angle(45)) saving("$sfig/mwi_v10_bump", replace)

bumpline beta reg_num if country == 4, by(sat) top(6) xsize(2) ysize(1) smooth(4) ///
	lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
	title("Niger") xtitle("") ytitle("Coefficient Rank") palette(viridis) ///
	xlab(, valuelabel angle(45)) saving("$sfig/ngr_v10_bump", replace)

bumpline beta reg_num if country == 5, by(sat) top(6) xsize(2) ysize(1) smooth(4) ///
	lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
	title("Nigeria") xtitle("") ytitle("") palette(viridis) ///
	xlab(, valuelabel angle(45)) saving("$sfig/nga_v10_bump", replace)

bumpline beta reg_num if country == 6, by(sat) top(6) xsize(2) ysize(1) smooth(4) ///
	lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
	title("Tanzania") xtitle("") ytitle("Coefficient Rank") palette(viridis) ///
	xlab(, valuelabel angle(45)) saving("$sfig/tza_v10_bump", replace)

bumpline beta reg_num if country == 7, by(sat) top(6) xsize(2) ysize(1) smooth(4) ///
	lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
	title("Uganda") xtitle("") ytitle("") palette(viridis) ///
	xlab(, valuelabel angle(45)) saving("$sfig/uga_v10_bump", replace)
	

restore

	gr combine 		"$sfig/eth_v10_bump.gph" "$sfig/mwi_v10_bump.gph" "$sfig/ngr_v10_bump.gph" ///
						"$sfig/nga_v10_bump.gph" "$sfig/tza_v10_bump.gph" "$sfig/uga_v10_bump.gph", ///
						col(2) iscale(.5) commonscheme
						
	graph export 	"$xfig/v10_bump.pdf", as(pdf) replace
	

************************************************************************
**# 3 - generate temp bumpline plots 
************************************************************************

frame change temperature 

lab define 	sat 3 "CPC" 4 "ERA5" 5 "MERRA-2", modify


************************************************************************
**## 3.1 - mean temp
************************************************************************

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
					6 "W, Qty" 7 "W, Val" 8 "W +  FE, Qty" 9 "W + FE, Val" ///
					12 "W, Qty" 13 "W, Val" 14 "W + FE, Qty" 15 "W + FE, Val" ///
					17 "W, Qty" 18 "W, Val" 19 "W + FE, Qty" 20 "W + FE, Val" ///
					22 "W, Qty" 23 "W, Val" 24 "W + FE, Qty" 25 "W + FE, Val" ///
					27 "W, Qty" 28 "W, Val" 29 "W + FE, Qty" 30 "W + FE, Val", replace
					
label values reg_num reg_name

bumpline beta reg_num if country == 1, by(sat) top(6) xsize(2) ysize(1) smooth(4) ///
	lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
	title("Ethiopia") xtitle("") ytitle("Coefficient Rank") palette(viridis) ///
	xlab(, valuelabel angle(45)) saving("$sfig/eth_v15_bump", replace)

bumpline beta reg_num if country == 2, by(sat) top(6) xsize(2) ysize(1) smooth(4) ///
	lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
	title("Malawi") xtitle("") ytitle("") palette(viridis) ///
	xlab(, valuelabel angle(45)) saving("$sfig/mwi_v15_bump", replace)

bumpline beta reg_num if country == 4, by(sat) top(6) xsize(2) ysize(1) smooth(4) ///
	lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
	title("Niger") xtitle("") ytitle("Coefficient Rank") palette(viridis) ///
	xlab(, valuelabel angle(45)) saving("$sfig/ngr_v15_bump", replace)

bumpline beta reg_num if country == 5, by(sat) top(6) xsize(2) ysize(1) smooth(4) ///
	lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
	title("Nigeria") xtitle("") ytitle("") palette(viridis) ///
	xlab(, valuelabel angle(45)) saving("$sfig/nga_v15_bump", replace)

bumpline beta reg_num if country == 6, by(sat) top(6) xsize(2) ysize(1) smooth(4) ///
	lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
	title("Tanzania") xtitle("") ytitle("Coefficient Rank") palette(viridis) ///
	xlab(, valuelabel angle(45)) saving("$sfig/tza_v15_bump", replace)

bumpline beta reg_num if country == 7, by(sat) top(6) xsize(2) ysize(1) smooth(4) ///
	lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
	title("Uganda") xtitle("") ytitle("") palette(viridis) ///
	xlab(, valuelabel angle(45)) saving("$sfig/uga_v15_bump", replace)
	

restore

	gr combine 		"$sfig/eth_v15_bump.gph" "$sfig/mwi_v15_bump.gph" "$sfig/ngr_v15_bump.gph" ///
						"$sfig/nga_v15_bump.gph" "$sfig/tza_v15_bump.gph" "$sfig/uga_v15_bump.gph", ///
						col(2) iscale(.5) commonscheme
						
	graph export 	"$xfig\v15_bump.pdf", as(pdf) replace


************************************************************************
**## 3.2 - gdd
************************************************************************

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
					6 "W, Qty" 7 "W, Val" 8 "W +  FE, Qty" 9 "W + FE, Val" ///
					12 "W, Qty" 13 "W, Val" 14 "W + FE, Qty" 15 "W + FE, Val" ///
					17 "W, Qty" 18 "W, Val" 19 "W + FE, Qty" 20 "W + FE, Val" ///
					22 "W, Qty" 23 "W, Val" 24 "W + FE, Qty" 25 "W + FE, Val" ///
					27 "W, Qty" 28 "W, Val" 29 "W + FE, Qty" 30 "W + FE, Val", replace
					
label values reg_num reg_name

bumpline beta reg_num if country == 1, by(sat) top(6) xsize(2) ysize(1) smooth(4) ///
	lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
	title("Ethiopia") xtitle("") ytitle("Coefficient Rank") palette(viridis) ///
	xlab(, valuelabel angle(45)) saving("$sfig/eth_v19_bump", replace)

bumpline beta reg_num if country == 2, by(sat) top(6) xsize(2) ysize(1) smooth(4) ///
	lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
	title("Malawi") xtitle("") ytitle("") palette(viridis) ///
	xlab(, valuelabel angle(45)) saving("$sfig/mwi_v19_bump", replace)

bumpline beta reg_num if country == 4, by(sat) top(6) xsize(2) ysize(1) smooth(4) ///
	lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
	title("Niger") xtitle("") ytitle("Coefficient Rank") palette(viridis) ///
	xlab(, valuelabel angle(45)) saving("$sfig/ngr_v19_bump", replace)

bumpline beta reg_num if country == 5, by(sat) top(6) xsize(2) ysize(1) smooth(4) ///
	lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
	title("Nigeria") xtitle("") ytitle("") palette(viridis) ///
	xlab(, valuelabel angle(45)) saving("$sfig/nga_v19_bump", replace)

bumpline beta reg_num if country == 6, by(sat) top(6) xsize(2) ysize(1) smooth(4) ///
	lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
	title("Tanzania") xtitle("") ytitle("Coefficient Rank") palette(viridis) ///
	xlab(, valuelabel angle(45)) saving("$sfig/tza_v19_bump", replace)

bumpline beta reg_num if country == 7, by(sat) top(6) xsize(2) ysize(1) smooth(4) ///
	lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
	title("Uganda") xtitle("") ytitle("") palette(viridis) ///
	xlab(, valuelabel angle(45)) saving("$sfig/uga_v19_bump", replace)
	

restore

	gr combine 		"$sfig/eth_v19_bump.gph" "$sfig/mwi_v19_bump.gph" "$sfig/ngr_v19_bump.gph" ///
						"$sfig/nga_v19_bump.gph" "$sfig/tza_v19_bump.gph" "$sfig/uga_v19_bump.gph", ///
						col(2) iscale(.5) commonscheme
						
	graph export 	"$xfig\v19_bump.pdf", as(pdf) replace
	

	
************************************************************************
**# 4 - generate appendix bumpline plots 
************************************************************************
	
	
************************************************************************
**## 4.1 - generate appendix rainfall bumpline plots 
************************************************************************

frame rainfall {
	keep if			varname < 15
	keep if			regname < 4

	lab define 		sat 3 "CPC" 4 "ERA5" 5 "MERRA-2", modify

	levelsof 		varname, local(varrain)
	foreach 		i of local varrain {

		preserve
			keep if			varname == `i'

			sort 			country regname depvar varname sat

			egen 			reg_num = group(country regname depvar)

			replace reg_num = reg_num + 1 if country > 1
			replace reg_num = reg_num + 1 if country > 2
			replace reg_num = reg_num + 1 if country > 3
			replace reg_num = reg_num + 1 if country > 4
			replace reg_num = reg_num + 1 if country > 5
			replace reg_num = reg_num + 1 if country > 6

			lab define 		reg_name 1 "W, Qty" 2 "W, Val" 3 "W + FE, Qty" ///
								4 "W + FE, Val" 6 "W, Qty" 7 "W, Val" ///
								8 "W +  FE, Qty" 9 "W + FE, Val" 12 "W, Qty" ///
								13 "W, Val" 14 "W + FE, Qty" 15 "W + FE, Val" ///
								17 "W, Qty" 18 "W, Val" 19 "W + FE, Qty" ///
								20 "W + FE, Val" 22 "W, Qty" 23 "W, Val" ///
								24 "W + FE, Qty" 25 "W + FE, Val" ///
								27 "W, Qty" 28 "W, Val" 29 "W + FE, Qty" ///
								30 "W + FE, Val", replace
					
			label values reg_num reg_name

			bumpline beta reg_num if country == 1, by(sat) top(6) xsize(2) ysize(1) smooth(4) ///
				lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
				title("Ethiopia") xtitle("") ytitle("Coefficient Rank") palette(viridis) ///
				xlab(, valuelabel angle(45)) saving("$sfig/eth_v`i'_bump", replace)

			bumpline beta reg_num if country == 2, by(sat) top(6) xsize(2) ysize(1) smooth(4) ///
				lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
				title("Malawi") xtitle("") ytitle("") palette(viridis) ///
				xlab(, valuelabel angle(45)) saving("$sfig/mwi_v`i'_bump", replace)

			bumpline beta reg_num if country == 4, by(sat) top(6) xsize(2) ysize(1) smooth(4) ///
				lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
				title("Niger") xtitle("") ytitle("Coefficient Rank") palette(viridis) ///
				xlab(, valuelabel angle(45)) saving("$sfig/ngr_v`i'_bump", replace)

			bumpline beta reg_num if country == 5, by(sat) top(6) xsize(2) ysize(1) smooth(4) ///
				lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
				title("Nigeria") xtitle("") ytitle("") palette(viridis) ///
				xlab(, valuelabel angle(45)) saving("$sfig/nga_v`i'_bump", replace)

			bumpline beta reg_num if country == 6, by(sat) top(6) xsize(2) ysize(1) smooth(4) ///
				lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
				title("Tanzania") xtitle("") ytitle("Coefficient Rank") palette(viridis) ///
				xlab(, valuelabel angle(45)) saving("$sfig/tza_v`i'_bump", replace)

			bumpline beta reg_num if country == 7, by(sat) top(6) xsize(2) ysize(1) smooth(4) ///
				lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
				title("Uganda") xtitle("") ytitle("") palette(viridis) ///
				xlab(, valuelabel angle(45)) saving("$sfig/uga_v`i'_bump", replace)
	
				gr combine 		"$sfig/eth_v`i'_bump.gph" "$sfig/mwi_v`i'_bump.gph" ///
								"$sfig/ngr_v`i'_bump.gph" "$sfig/nga_v`i'_bump.gph" ///
								"$sfig/tza_v`i'_bump.gph" "$sfig/uga_v`i'_bump.gph", ///
								col(2) iscale(.5) commonscheme
						
				graph export 	"$xfig/v`i'_bump.pdf", as(pdf) replace

	restore
}
}
	
************************************************************************
**## 4.2 - generate appendix temperature bumpline plots 
************************************************************************

frame temperature {
	keep if			varname > 14
	keep if			regname < 4

	lab define 	sat 3 "CPC" 4 "ERA5" 5 "MERRA-2", modify

	levelsof 		varname, local(vartemp)
	foreach 		i of local vartemp {

		preserve
			keep if			varname == `i'

			sort country regname depvar varname sat

			egen reg_num = group(country regname depvar)

			replace reg_num = reg_num + 1 if country > 1
			replace reg_num = reg_num + 1 if country > 2
			replace reg_num = reg_num + 1 if country > 3
			replace reg_num = reg_num + 1 if country > 4
			replace reg_num = reg_num + 1 if country > 5
			replace reg_num = reg_num + 1 if country > 6

			lab define 		reg_name 1 "W, Qty" 2 "W, Val" 3 "W + FE, Qty" ///
								4 "W + FE, Val" 6 "W, Qty" 7 "W, Val" ///
								8 "W +  FE, Qty" 9 "W + FE, Val" 12 "W, Qty" ///
								13 "W, Val" 14 "W + FE, Qty" 15 "W + FE, Val" ///
								17 "W, Qty" 18 "W, Val" 19 "W + FE, Qty" ///
								20 "W + FE, Val" 22 "W, Qty" 23 "W, Val" ///
								24 "W + FE, Qty" 25 "W + FE, Val" 27 "W, Qty" ///
								28 "W, Val" 29 "W + FE, Qty" 30 "W + FE, Val", replace
					
			label values reg_num reg_name

			bumpline beta reg_num if country == 1, by(sat) top(6) xsize(2) ysize(1) smooth(4) ///
				lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
				title("Ethiopia") xtitle("") ytitle("Coefficient Rank") palette(viridis) ///
				xlab(, valuelabel angle(45)) saving("$sfig/eth_v`i'_bump", replace)

			bumpline beta reg_num if country == 2, by(sat) top(6) xsize(2) ysize(1) smooth(4) ///
				lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
				title("Malawi") xtitle("") ytitle("") palette(viridis) ///
				xlab(, valuelabel angle(45)) saving("$sfig/mwi_v`i'_bump", replace)

			bumpline beta reg_num if country == 4, by(sat) top(6) xsize(2) ysize(1) smooth(4) ///
				lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
				title("Niger") xtitle("") ytitle("Coefficient Rank") palette(viridis) ///
				xlab(, valuelabel angle(45)) saving("$sfig/ngr_v`i'_bump", replace)

			bumpline beta reg_num if country == 5, by(sat) top(6) xsize(2) ysize(1) smooth(4) ///
				lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
				title("Nigeria") xtitle("") ytitle("") palette(viridis) ///
				xlab(, valuelabel angle(45)) saving("$sfig/nga_v`i'_bump", replace)

			bumpline beta reg_num if country == 6, by(sat) top(6) xsize(2) ysize(1) smooth(4) ///
				lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
				title("Tanzania") xtitle("") ytitle("Coefficient Rank") palette(viridis) ///
				xlab(, valuelabel angle(45)) saving("$sfig/tza_v`i'_bump", replace)

			bumpline beta reg_num if country == 7, by(sat) top(6) xsize(2) ysize(1) smooth(4) ///
				lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
				title("Uganda") xtitle("") ytitle("") palette(viridis) ///
				xlab(, valuelabel angle(45)) saving("$sfig/uga_v`i'_bump", replace)
	
	
				gr combine 		"$sfig/eth_v`i'_bump.gph" "$sfig/mwi_v`i'_bump.gph" ///
								"$sfig/ngr_v`i'_bump.gph" "$sfig/nga_v`i'_bump.gph" ///
								"$sfig/tza_v`i'_bump.gph" "$sfig/uga_v`i'_bump.gph", ///
								col(2) iscale(.5) commonscheme
						
				graph export 	"$xfig/v`i'_bump.pdf", as(pdf) replace

	restore
}
}

************************************************************************
**# 5 - end matter
************************************************************************
		
* close the log
	log	close

/* END */	
	