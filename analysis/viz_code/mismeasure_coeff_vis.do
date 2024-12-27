* Project: WB Weather - mismeasure paper
* Created on: 4 April 2023
* Created by: jdm
* Edited by: jdm
* Last edit: 27 Dec 2024
* Stata v.18.5

* does
	* reads in results data set
	* makes visualziations of results using specification charts
	* graphs represent sign and significance of coefficients

* assumes
	* you have results file 
	* grc1leg2.ado

* TO DO:
	* experimenting in section 4
	
	
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
	log 	using 	"$logout/mismeasure_coeff_vis", append


************************************************************************
**# 1 - set data frames for rainfall and temperature
************************************************************************

* load data 
	use 			"$root/lsms_complete_results", clear
	frames 			reset
	frame 			create rainfall
	frame 			rainfall: use "$root/lsms_complete_results"
	
	frame 			create temperature
	frame 			temperature: use "$root/lsms_complete_results"

	
************************************************************************
**# 2 - generate specification chart for rainfall
************************************************************************		

	frame change rainfall
	drop			obs

	replace			country = country - 1 if country > 2
	
************************************************************************
**## 2.1 - total seasonal rainfall
************************************************************************		
	
preserve	
	keep			if varname == 5 & regname == 2
	sort 			country beta
	gen 			obs = _n

* stack values of the specification indicators
	gen				k1		= 	depvar
	gen 			k2 		= 	sat + 4
	
* label new variables	
	lab				var obs "Specification # - sorted by effect size"

	lab 			var k1 "Dep. Var."
	lab 			var k2 "Weather Product"

	qui sum			ci_up
	global			bmax = r(max)
	
	qui sum			ci_lo
	global			bmin = r(min)
	
	global			brange	=	$bmax - $bmin
	global			from_y	=	$bmin - 2.5*$brange
	global			gheight	=	15

* country labels at top
	twoway 			scatter k1 k2 obs, xlab(0(4)72) xsize(10) ysize(6) xtitle("") ytitle("") ///
						title("")  ylab(0(1)$gheight ) ///
						msize(small small small) mcolor(gs10 gs10 gs10) ylabel( ///
						1 "Quantity" 2 "Value" 3 "*{bf:Dep. Var.}*" ///
						5 "ARC2" 6 "CHIRPS" 7 "CPC" 8 "ERA5" 9 "MERRA-2" ///
						10 "TAMSAT" 11 "*{bf:Weather Product}*" 15 " ", ///
						angle(0) labsize(vsmall) tstyle(notick)) ///
						text(16 6 "Ethiopia" 16 18 "Malawi" 16 30 "Niger" ///
						16 42 "Nigeria" 16 54 "Tanzania" 16 66 "Uganda") ///
						plotregion(margin(4 4 4 7)) || ///
						(scatter k2 obs if b_sig != . & beta > 0, ///
						msize(small small) mcolor(edkblue) msymbol(d)) || ///
						(scatter k2 obs if b_sig != . & beta < 0, ///
						msize(small small) mcolor(maroon) msymbol(d)) || ///
						(scatter b_ns obs, yaxis(2) mcolor(black%75) msymbol(Th) ///
						ylab(,axis(2) labsize(vsmall) angle(0) ) yscale( ///
						range($from_y $bmax ) axis(2)) ) || ///
						(scatter b_sig obs if beta > 0, yaxis(2) mcolor(edkblue%75) msymbol(+) ///
						ylab(,axis(2) labsize(vsmall) angle(0) ) yscale( ///
						range($from_y $bmax ) axis(2)) ) || ///
						(scatter b_sig obs if beta < 0, yaxis(2) mcolor(maroon%75) msymbol(+) ///
						ylab(,axis(2) labsize(vsmall) angle(0) ) yscale( ///
						range($from_y $bmax ) axis(2)) ) || ///
						(rbar ci_lo ci_up obs if b_sig == ., ///
						barwidth(.1) color(black%50) yaxis(2) ) || ///
						(rbar ci_lo ci_up obs if b_sig != . & beta < 0, ///
						barwidth(.1) color(maroon%50) yaxis(2) ) || ///
						(rbar ci_lo ci_up obs if b_sig != . & beta > 0, ///
						barwidth(.1) color(edkblue%50) yaxis(2)  ///
						xline(12.5, lcolor(black) lstyle(solid)) ///
						xline(24.5, lcolor(black) lstyle(solid)) ///
						xline(36.5, lcolor(black) lstyle(solid)) ///
						xline(48.5, lcolor(black) lstyle(solid)) ///
						xline(60.5, lcolor(black) lstyle(solid)) ///
						yline(0, lcolor(maroon) axis(2) lstyle(solid)) ), ///
						legend(order(7 5 6) cols(3) size(small) rowgap(.5) pos(6)) 
				
	graph export 	"$xfig\v5_spec.pdf", as(pdf) replace
restore


************************************************************************
**## 2.2 - days without rain
************************************************************************		
	
preserve	
	keep			if varname == 10 & regname == 2
	sort 			country beta
	gen 			obs = _n

* stack values of the specification indicators
	gen				k1		= 	depvar
	gen 			k2 		= 	sat + 4
	
* label new variables	
	lab				var obs "Specification # - sorted by effect size"

	lab 			var k1 "Dep. Var."
	lab 			var k2 "Weather Product"

	qui sum			ci_up
	global			bmax = r(max)
	
	qui sum			ci_lo
	global			bmin = r(min)
	
	global			brange	=	$bmax - $bmin
	global			from_y	=	$bmin - 2.5*$brange
	global			gheight	=	16

* country labels at top
	twoway 			scatter k1 k2 obs, xlab(0(4)72) xsize(10) ysize(6) xtitle("") ytitle("") ///
						title("")  ylab(0(1)$gheight ) ///
						msize(small small small) mcolor(gs10 gs10 gs10) ylabel( ///
						1 "Quantity" 2 "Value" 3 "*{bf:Dep. Var.}*" ///
						5 "ARC2" 6 "CHIRPS" 7 "CPC" 8 "ERA5" 9 "MERRA-2" ///
						10 "TAMSAT" 11 "*{bf:Weather Product}*" 16 " ", ///
						angle(0) labsize(vsmall) tstyle(notick)) ///
						text(17 6 "Ethiopia" 17 18 "Malawi" 17 30 "Niger" ///
						17 42 "Nigeria" 17 54 "Tanzania" 17 66 "Uganda") ///
						plotregion(margin(4 4 4 7)) || ///
						(scatter k2 obs if b_sig != . & beta > 0, ///
						msize(small small) mcolor(edkblue) msymbol(d)) || ///
						(scatter k2 obs if b_sig != . & beta < 0, ///
						msize(small small) mcolor(maroon) msymbol(d)) || ///
						(scatter b_ns obs, yaxis(2) mcolor(black%75) msymbol(Th) ///
						ylab(,axis(2) labsize(vsmall) angle(0) ) yscale( ///
						range($from_y $bmax ) axis(2)) ) || ///
						(scatter b_sig obs if beta > 0, yaxis(2) mcolor(edkblue%75) msymbol(+) ///
						ylab(,axis(2) labsize(vsmall) angle(0) ) yscale( ///
						range($from_y $bmax ) axis(2)) ) || ///
						(scatter b_sig obs if beta < 0, yaxis(2) mcolor(maroon%75) msymbol(+) ///
						ylab(,axis(2) labsize(vsmall) angle(0) ) yscale( ///
						range($from_y $bmax ) axis(2)) ) || ///
						(rbar ci_lo ci_up obs if b_sig == ., ///
						barwidth(.1) color(black%50) yaxis(2) ) || ///
						(rbar ci_lo ci_up obs if b_sig != . & beta < 0, ///
						barwidth(.1) color(maroon%50) yaxis(2) ) || ///
						(rbar ci_lo ci_up obs if b_sig != . & beta > 0, ///
						barwidth(.1) color(edkblue%50) yaxis(2)  ///
						xline(12.5, lcolor(black) lstyle(solid)) ///
						xline(24.5, lcolor(black) lstyle(solid)) ///
						xline(36.5, lcolor(black) lstyle(solid)) ///
						xline(48.5, lcolor(black) lstyle(solid)) ///
						xline(60.5, lcolor(black) lstyle(solid)) ///
						yline(0, lcolor(maroon) axis(2) lstyle(solid)) ), ///
						legend(order(7 5 6) cols(3) size(small) rowgap(.5) pos(6)) 
				
	graph export 	"$xfig\v10_spec.pdf", as(pdf) replace
restore
	
	
************************************************************************
**# 3 - generate specification chart for temperature
************************************************************************		

	frame change temperature
	drop			obs

	replace			country = country - 1 if country > 2
	
	
************************************************************************
**## 3.1 - mean temperature
************************************************************************		
	
preserve	
	keep			if varname == 15 & regname == 2
	sort 			country beta
	gen 			obs = _n

* stack values of the specification indicators
	gen				k1		= 	depvar
	gen 			k2 		= 	sat + 4 - 6
	
* label new variables	
	lab				var obs "Specification # - sorted by effect size"

	lab 			var k1 "Dep. Var."
	lab 			var k2 "Weather Product"

	qui sum			ci_up
	global			bmax = r(max)
	
	qui sum			ci_lo
	global			bmin = r(min)
	
	global			brange	=	$bmax - $bmin
	global			from_y	=	$bmin - 2.5*$brange
	global			gheight	=	14

* country labels at top
	twoway 			scatter k1 k2 obs, xlab(0(4)36) xsize(10) ysize(6) xtitle("") ytitle("") ///
						title("")  ylab(0(1)$gheight ) ///
						msize(small small small) mcolor(gs10 gs10 gs10) ylabel( ///
						1 "Quantity" 2 "Value" 3 "*{bf:Dep. Var.}*" ///
						5 "CPC" 6 "ERA5" 7 "MERRA-2" 8 "*{bf:Weather Product}*" 12 " ", ///
						angle(0) labsize(vsmall) tstyle(notick)) ///
						text(13 3 "Ethiopia" 13 9 "Malawi" 13 15 "Niger" ///
						13 21 "Nigeria" 13 27 "Tanzania" 13 33 "Uganda") ///
						plotregion(margin(4 4 4 7)) || ///
						(scatter k2 obs if b_sig != . & beta > 0, ///
						msize(small small) mcolor(edkblue) msymbol(d)) || ///
						(scatter k2 obs if b_sig != . & beta < 0, ///
						msize(small small) mcolor(maroon) msymbol(d)) || ///
						(scatter b_ns obs, yaxis(2) mcolor(black%75) msymbol(Th) ///
						ylab(,axis(2) labsize(vsmall) angle(0) ) yscale( ///
						range($from_y $bmax ) axis(2)) ) || ///
						(scatter b_sig obs if beta > 0, yaxis(2) mcolor(edkblue%75) msymbol(+) ///
						ylab(,axis(2) labsize(vsmall) angle(0) ) yscale( ///
						range($from_y $bmax ) axis(2)) ) || ///
						(scatter b_sig obs if beta < 0, yaxis(2) mcolor(maroon%75) msymbol(+) ///
						ylab(,axis(2) labsize(vsmall) angle(0) ) yscale( ///
						range($from_y $bmax ) axis(2)) ) || ///
						(rbar ci_lo ci_up obs if b_sig == ., ///
						barwidth(.1) color(black%50) yaxis(2) ) || ///
						(rbar ci_lo ci_up obs if b_sig != . & beta < 0, ///
						barwidth(.1) color(maroon%50) yaxis(2) ) || ///
						(rbar ci_lo ci_up obs if b_sig != . & beta > 0, ///
						barwidth(.1) color(edkblue%50) yaxis(2)  ///
						xline(6.5, lcolor(black) lstyle(solid)) ///
						xline(12.5, lcolor(black) lstyle(solid)) ///
						xline(18.5, lcolor(black) lstyle(solid)) ///
						xline(24.5, lcolor(black) lstyle(solid)) ///
						xline(30.5, lcolor(black) lstyle(solid)) ///
						yline(0, lcolor(maroon) axis(2) lstyle(solid)) ), ///
						legend(order(7 5 6) cols(3) size(small) rowgap(.5) pos(6)) 
				
	graph export 	"$xfig\v15_spec.pdf", as(pdf) replace
restore


************************************************************************
**## 3.2 - gdd
************************************************************************		
	
preserve	
	keep			if varname == 19 & regname == 2
	sort 			country beta
	gen 			obs = _n

* stack values of the specification indicators
	gen				k1		= 	depvar
	gen 			k2 		= 	sat + 4 - 6
	
* label new variables	
	lab				var obs "Specification # - sorted by effect size"

	lab 			var k1 "Dep. Var."
	lab 			var k2 "Weather Product"

	qui sum			ci_up
	global			bmax = r(max)
	
	qui sum			ci_lo
	global			bmin = r(min)
	
	global			brange	=	$bmax - $bmin
	global			from_y	=	$bmin - 2.5*$brange
	global			gheight	=	14

* country labels at top
	twoway 			scatter k1 k2 obs, xlab(0(4)36) xsize(10) ysize(6) xtitle("") ytitle("") ///
						title("")  ylab(0(1)$gheight ) ///
						msize(small small small) mcolor(gs10 gs10 gs10) ylabel( ///
						1 "Quantity" 2 "Value" 3 "*{bf:Dep. Var.}*" ///
						5 "CPC" 6 "ERA5" 7 "MERRA-2" 8 "*{bf:Weather Product}*" 12 " ", ///
						angle(0) labsize(vsmall) tstyle(notick)) ///
						text(13 3 "Ethiopia" 13 9 "Malawi" 13 15 "Niger" ///
						13 21 "Nigeria" 13 27 "Tanzania" 13 33 "Uganda") ///
						plotregion(margin(4 4 4 7)) || ///
						(scatter k2 obs if b_sig != . & beta > 0, ///
						msize(small small) mcolor(edkblue) msymbol(d)) || ///
						(scatter k2 obs if b_sig != . & beta < 0, ///
						msize(small small) mcolor(maroon) msymbol(d)) || ///
						(scatter b_ns obs, yaxis(2) mcolor(black%75) msymbol(Th) ///
						ylab(,axis(2) labsize(vsmall) angle(0) ) yscale( ///
						range($from_y $bmax ) axis(2)) ) || ///
						(scatter b_sig obs if beta > 0, yaxis(2) mcolor(edkblue%75) msymbol(+) ///
						ylab(,axis(2) labsize(vsmall) angle(0) ) yscale( ///
						range($from_y $bmax ) axis(2)) ) || ///
						(scatter b_sig obs if beta < 0, yaxis(2) mcolor(maroon%75) msymbol(+) ///
						ylab(,axis(2) labsize(vsmall) angle(0) ) yscale( ///
						range($from_y $bmax ) axis(2)) ) || ///
						(rbar ci_lo ci_up obs if b_sig == ., ///
						barwidth(.1) color(black%50) yaxis(2) ) || ///
						(rbar ci_lo ci_up obs if b_sig != . & beta < 0, ///
						barwidth(.1) color(maroon%50) yaxis(2) ) || ///
						(rbar ci_lo ci_up obs if b_sig != . & beta > 0, ///
						barwidth(.1) color(edkblue%50) yaxis(2)  ///
						xline(6.5, lcolor(black) lstyle(solid)) ///
						xline(12.5, lcolor(black) lstyle(solid)) ///
						xline(18.5, lcolor(black) lstyle(solid)) ///
						xline(24.5, lcolor(black) lstyle(solid)) ///
						xline(30.5, lcolor(black) lstyle(solid)) ///
						yline(0, lcolor(maroon) axis(2) lstyle(solid)) ), ///
						legend(order(7 5 6) cols(3) size(small) rowgap(.5) pos(6)) 
				
	graph export 	"$xfig\v19_spec.pdf", as(pdf) replace
restore
		

************************************************************************
**# 4 - generate appendix specification plots 
************************************************************************		
	

************************************************************************
**## 4.1 - generate appendix rainfall specification plots 
************************************************************************		

frame rainfall {
	keep if			varname < 15
	drop			obs

	replace			country = country - 1 if country > 2
	
	keep if			regname == 2
	
	levelsof 		varname, local(varrain)
	foreach 		i of local varrain {
		
	preserve	
		keep			if varname == `i'
		sort 			country beta
		gen 			obs = _n

	* stack values of the specification indicators
		gen				k1		= 	depvar
		gen 			k2 		= 	sat + 4
	
	* label new variables	
		lab				var obs "Specification # - sorted by effect size"

		lab 			var k1 "Dep. Var."
		lab 			var k2 "Weather Product"

		qui sum			ci_up
		global			bmax = r(max)
	
		qui sum			ci_lo
		global			bmin = r(min)
	
		global			brange	=	$bmax - $bmin
		global			from_y	=	$bmin - 2.5*$brange
		global			gheight	=	15

	* country labels at top
		twoway 			scatter k1 k2 obs, xlab(0(4)72) xsize(10) ysize(6) xtitle("") ytitle("") ///
							title("")  ylab(0(1)$gheight ) ///
							msize(small small small) mcolor(gs10 gs10 gs10) ylabel( ///
							1 "Quantity" 2 "Value" 3 "*{bf:Dep. Var.}*" ///
							5 "ARC2" 6 "CHIRPS" 7 "CPC" 8 "ERA5" 9 "MERRA-2" ///
							10 "TAMSAT" 11 "*{bf:Weather Product}*" 15 " ", ///
							angle(0) labsize(vsmall) tstyle(notick)) ///
							text(16 6 "Ethiopia" 16 18 "Malawi" 16 30 "Niger" ///
							16 42 "Nigeria" 16 54 "Tanzania" 16 66 "Uganda") ///
							plotregion(margin(4 4 4 7)) || ///
							(scatter k2 obs if b_sig != . & beta > 0, ///
							msize(small small) mcolor(edkblue) msymbol(d)) || ///
							(scatter k2 obs if b_sig != . & beta < 0, ///
							msize(small small) mcolor(maroon) msymbol(d)) || ///
							(scatter b_ns obs, yaxis(2) mcolor(black%75) msymbol(Th) ///
							ylab(,axis(2) labsize(vsmall) angle(0) ) yscale( ///
							range($from_y $bmax ) axis(2)) ) || ///
							(scatter b_sig obs if beta > 0, yaxis(2) mcolor(edkblue%75) msymbol(+) ///
							ylab(,axis(2) labsize(vsmall) angle(0) ) yscale( ///
							range($from_y $bmax ) axis(2)) ) || ///
							(scatter b_sig obs if beta < 0, yaxis(2) mcolor(maroon%75) msymbol(+) ///
							ylab(,axis(2) labsize(vsmall) angle(0) ) yscale( ///
							range($from_y $bmax ) axis(2)) ) || ///
							(rbar ci_lo ci_up obs if b_sig == ., ///
							barwidth(.1) color(black%50) yaxis(2) ) || ///
							(rbar ci_lo ci_up obs if b_sig != . & beta < 0, ///
							barwidth(.1) color(maroon%50) yaxis(2) ) || ///
							(rbar ci_lo ci_up obs if b_sig != . & beta > 0, ///
							barwidth(.1) color(edkblue%50) yaxis(2)  ///
							xline(12.5, lcolor(black) lstyle(solid)) ///
							xline(24.5, lcolor(black) lstyle(solid)) ///
							xline(36.5, lcolor(black) lstyle(solid)) ///
							xline(48.5, lcolor(black) lstyle(solid)) ///
							xline(60.5, lcolor(black) lstyle(solid)) ///
							yline(0, lcolor(maroon) axis(2) lstyle(solid)) ), ///
							legend(order(7 5 6) cols(3) size(small) rowgap(.5) pos(6)) 
				
		graph export 	"$xfig\v`i'_spec.pdf", as(pdf) replace
	restore
	}
}
************************************************************************
**## 4.2 - generate appendix temperature specification plots 
************************************************************************		

frame temperature {
	keep if			varname > 14
	drop			obs

	replace			country = country - 1 if country > 2
	
	keep if			regname == 2
	
	levelsof 		varname, local(vartemp)
	foreach 		i of local vartemp {
		
	preserve	
		keep			if varname == `i'
	sort 			country beta
	gen 			obs = _n

* stack values of the specification indicators
	gen				k1		= 	depvar
	gen 			k2 		= 	sat + 4 - 6
	
* label new variables	
	lab				var obs "Specification # - sorted by effect size"

	lab 			var k1 "Dep. Var."
	lab 			var k2 "Weather Product"

	qui sum			ci_up
	global			bmax = r(max)
	
	qui sum			ci_lo
	global			bmin = r(min)
	
	global			brange	=	$bmax - $bmin
	global			from_y	=	$bmin - 2.5*$brange
	global			gheight	=	14

* country labels at top
	twoway 			scatter k1 k2 obs, xlab(0(4)36) xsize(10) ysize(6) xtitle("") ytitle("") ///
						title("")  ylab(0(1)$gheight ) ///
						msize(small small small) mcolor(gs10 gs10 gs10) ylabel( ///
						1 "Quantity" 2 "Value" 3 "*{bf:Dep. Var.}*" ///
						5 "CPC" 6 "ERA5" 7 "MERRA-2" 8 "*{bf:Weather Product}*" 12 " ", ///
						angle(0) labsize(vsmall) tstyle(notick)) ///
						text(13 3 "Ethiopia" 13 9 "Malawi" 13 15 "Niger" ///
						13 21 "Nigeria" 13 27 "Tanzania" 13 33 "Uganda") ///
						plotregion(margin(4 4 4 7)) || ///
						(scatter k2 obs if b_sig != . & beta > 0, ///
						msize(small small) mcolor(edkblue) msymbol(d)) || ///
						(scatter k2 obs if b_sig != . & beta < 0, ///
						msize(small small) mcolor(maroon) msymbol(d)) || ///
						(scatter b_ns obs, yaxis(2) mcolor(black%75) msymbol(Th) ///
						ylab(,axis(2) labsize(vsmall) angle(0) ) yscale( ///
						range($from_y $bmax ) axis(2)) ) || ///
						(scatter b_sig obs if beta > 0, yaxis(2) mcolor(edkblue%75) msymbol(+) ///
						ylab(,axis(2) labsize(vsmall) angle(0) ) yscale( ///
						range($from_y $bmax ) axis(2)) ) || ///
						(scatter b_sig obs if beta < 0, yaxis(2) mcolor(maroon%75) msymbol(+) ///
						ylab(,axis(2) labsize(vsmall) angle(0) ) yscale( ///
						range($from_y $bmax ) axis(2)) ) || ///
						(rbar ci_lo ci_up obs if b_sig == ., ///
						barwidth(.1) color(black%50) yaxis(2) ) || ///
						(rbar ci_lo ci_up obs if b_sig != . & beta < 0, ///
						barwidth(.1) color(maroon%50) yaxis(2) ) || ///
						(rbar ci_lo ci_up obs if b_sig != . & beta > 0, ///
						barwidth(.1) color(edkblue%50) yaxis(2)  ///
						xline(6.5, lcolor(black) lstyle(solid)) ///
						xline(12.5, lcolor(black) lstyle(solid)) ///
						xline(18.5, lcolor(black) lstyle(solid)) ///
						xline(24.5, lcolor(black) lstyle(solid)) ///
						xline(30.5, lcolor(black) lstyle(solid)) ///
						yline(0, lcolor(maroon) axis(2) lstyle(solid)) ), ///
						legend(order(7 5 6) cols(3) size(small) rowgap(.5) pos(6)) 
				
		graph export 	"$xfig\v`i'_spec.pdf", as(pdf) replace
	restore
	}
}
	

************************************************************************
**# 5 - end matter
************************************************************************

* close the log
	log	close

/* END */				
	