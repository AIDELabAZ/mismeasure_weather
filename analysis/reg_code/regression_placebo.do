* Project: WB Weather
* Created on: January 2025
* Created by: jdm
* Edited on: 16 Jan 2025
* Edited by: jdm
* Stata v.18

* does
	* NOTE IT TAKES 7 MIN TO RUN ALL REGRESSIONS
	* loads multi country data set
	* runs rainfall and temperature regressions
	* outputs results file for analysis

* assumes
	* cleaned, merged (weather), and appended (waves) data

* TO DO:
	* complete

	
* **********************************************************************
* 0 - setup
* **********************************************************************

* define paths
	global		source	 	"$data/mismeasure_weather_data/regression_data"
	global		results   	"$data/mismeasure_weather_data/results_data"
	global		stab 		"$data/mismeasure_weather_data/results_data/tables"
	global		xtab 	 	"$data/mismeasure_weather_data/paper/tables"
	global		sfig	 	"$data/mismeasure_weather_data/results_data/figures"	
	global 		xfig       "$data/mismeasure_weather_data/paper/figures"
	global		logout 	 	"$data/mismeasure_weather_data/regression_data/logs"

* open log	
	cap log 	close
	log 		using 		"$logout/reg_placebo", append

	
* **********************************************************************
* 1 - read in cross country panel
* **********************************************************************

* read in data file
	use			"$source/lsms_panel.dta", clear

	
* **********************************************************************
* 2 - regressions on weather data
* **********************************************************************

* generate affine transforms of cpc data
	gen			wp_1 = v05_rf3
	gen			wp_2 = v05_rf3 + 100
	gen			wp_3 = 10*v05_rf3
	gen			wp_4 = 10*v05_rf3 + 100


* create locals for total farm and just for maize
	loc		weather 	wp_*
	loc		inputstf 	lntf_lab lntf_frt tf_pst tf_hrb tf_irr
	loc 	inputscp 	lncp_lab lncp_frt cp_pst cp_hrb cp_irr

* create file to post results to
	tempname 	reg_placebo
	postfile 	`reg_placebo' country str3 sat str2 depvar str4 regname str4 varname ///
					betarain serain adjustedr loglike dfr obs ///
					using "$results/reg_placebo.dta", replace
					
* define loop through levels of the data type variable	
levelsof 	country		, local(levels)
foreach l of local levels {
	
	* set panel id so it varies by dtype
		xtset		hhid
		
	* rainfall			
		foreach 	v of varlist `weather' { 

		* define locals for naming conventions
			loc 	varn = 	substr("`v'", 1, 4)
			loc 	sat = 	substr("`v'", 5, 3)

		* 2.1: Value of Harvest
		
		* weather
			reg 		lntf_yld `v' if country == `l', vce(cluster hhid)
			post 		`reg_placebo' (`l') ("`sat'") ("tf") ("reg1") ///
						("`varn'") (`=_b[`v']') (`=_se[`v']') (`=e(r2_a)') ///
						(`=e(ll)') (`=e(df_r)') (`=e(N)')

		* weather and fe	
			xtreg 		lntf_yld `v' i.year if country == `l', fe vce(cluster hhid)
			post 		`reg_placebo' (`l') ("`sat'") ("tf") ("reg2") ///
						("`varn'") (`=_b[`v']') (`=_se[`v']') (`=e(r2_a)') ///
						(`=e(ll)') (`=e(df_r)') (`=e(N)')
						
		* 2.2: Quantity of Maize
		
		* weather
			reg 		lncp_yld `v' if country == `l', vce(cluster hhid)
			post 		`reg_placebo' (`l') ("`sat'") ("cp") ("reg1") ///
						("`varn'") (`=_b[`v']') (`=_se[`v']') (`=e(r2_a)') ///
						(`=e(ll)') (`=e(df_r)') (`=e(N)')

		* weather and fe	
			xtreg 		lncp_yld `v' i.year if country == `l', fe vce(cluster hhid)
			post 		`reg_placebo' (`l') ("`sat'") ("cp") ("reg2") ///
						("`varn'") (`=_b[`v']') (`=_se[`v']') (`=e(r2_a)') ///
						(`=e(ll)') (`=e(df_r)') (`=e(N)')
	}
}

* close the post file and open the data file
	postclose	`reg_placebo' 
	use 		"$results/reg_placebo", clear

* drop the cross section FE results
	drop if		loglike == .
	
* create country type variable
	lab def		country 1 "Ethiopia" 2 "Malawi" 3 "Mali" ///
					4 "Niger" 5 "Nigeria" 6 "Tanzania" ///
					7 "Uganda"
	lab val		country country
	lab var		country "Country"
	
* create data type variables
*	lab define 	dtype 0 "cx" 1 "lp" 2 "sp"
*	label val 	data dtype

* create variables for statistical testing
	gen 		tstat = betarain/serain
	lab var		tstat "t-statistic"
	gen 		pval = 2*ttail(dfr,abs(tstat))
	lab var		pval "p-value"
	gen 		ci_lo =  betarain - invttail(dfr,0.025)*serain
	lab var		ci_lo "Lower confidence interval"
	gen 		ci_up =  betarain + invttail(dfr,0.025)*serain
	lab var		ci_up "Upper confidence interval"

* label variables
	rename		betarain beta
	lab var		beta "Coefficient"
	rename		serain stdrd_err
	lab var		stdrd_err "Standard error"
	lab var		adjustedr "Adjusted R^2"
	lab var		loglike "Log likelihood"
	lab var		dfr "Degrees of freedom"
	lab var		obs "Number of observations"

* create unique id variable
	egen 		reg_id = group(country sat depvar regname varname)
	lab var 	reg_id "unique regression id"

* create variable to record the dependent variable
	sort 		depvar
	egen 		aux_dep = group(depvar)

* order and label the varaiable
	order 		aux_dep, after(depvar)
	lab def		depvar 	1 "Quantity" ///
						2 "Value"
	lab val		aux_dep depvar
	lab var		aux_dep "Dependent variable"
	drop 		depvar
	rename 		aux_dep depvar
	
* create variable to record the regressions specification
	sort 		regname
	gen 		aux_reg = 1 if regname == "reg1"
	replace 	aux_reg = 2 if regname == "reg2"
	replace 	aux_reg = 3 if regname == "reg3"
	replace 	aux_reg = 4 if regname == "reg4"
	replace 	aux_reg = 5 if regname == "reg5"
	replace 	aux_reg = 6 if regname == "reg6"

* order and label the varaiable
	order 		aux_reg, after(regname)
	lab def		regname 	1 "Weather Only" ///
							2 "Weather + FE" ///
							3 "Weather + FE + Inputs" ///
							4 "Weather + Weather^2" ////
							5 "Weather + Weather^2 + FE" ///
							6 "Weather + Weather^2 + FE + Inputs" ///
							7 "Weather + Year FE" ///
							8 "Weather + Year FE + Inputs" ///
							9 "Weather + Weather^2 + Year FE" ///
							10 "Weather + Weather^2 + Year FE + Inputs"
	lab val		aux_reg regname
	lab var		aux_reg "Regression Name"
	drop 		regname
	rename 		aux_reg regname

* create variable to record the regressions specification
	sort 		varname
	gen 		aux_var = 1 if varname == "wp_1"
	replace 	aux_var = 2 if varname == "wp_2"
	replace 	aux_var = 3 if varname == "wp_3"
	replace 	aux_var = 4 if varname == "wp_4"
	replace 	aux_var = 5 if varname == "wp_5"
	replace 	aux_var = 6 if varname == "wp_6"
	
* order and label the transform
	order 		aux_var, after(varname)
	lab def		varname 	1 "Original (W)" ///
							2 "W + 100" ///
							3 "10*W" ///
							4 "10*W + 100" ////
							5 "ln(W)" ///
							6 "ihs(W)" 
	lab val		aux_var varname
	lab var		aux_var "Affine Transform"
	drop 		varname
	rename 		aux_var varname

order	reg_id
	
*generate different betas based on signficance
	gen 			b_sig = beta
	replace 		b_sig = . if pval > .05
	lab var 		b_sig "p < 0.05"
	
	gen 			b_ns = beta
	replace 		b_ns= . if p <= .05
	lab var 		b_ns "n.s."
	
* generate significance dummy
	gen				sig = 1 if b_sig != .
	replace			sig = 0 if b_ns != .
	lab	def			yesno 0 "Not Significant" 1 "Significant"
	lab val			sig yesno
	lab var			sig "Weather variable is significant"
	
* generate sign dummy
	gen 			b_sign = 1 if b_sig > 0 & b_sig != .
	replace 		b_sign = 0 if b_sig < 0 & b_sig != .
	lab	def			posneg 0 "Negative" 1 "Positive"
	lab val			b_sign posneg
	lab var			b_sign "Sign on weather variable"

	
	
************************************************************************
**# 2 - generate rainfall bumpline plots 
************************************************************************

sort country regname depvar varname

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

bumpline beta reg_num if country == 1, by(varname) top(6) xsize(2) ysize(1) smooth(4) ///
	lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
	title("Ethiopia") xtitle("") ytitle("Coefficient Rank") palette(viridis) ///
	xlab(, valuelabel angle(45)) saving("$sfig/eth_pl_bump", replace)

bumpline beta reg_num if country == 2, by(varname) top(6) xsize(2) ysize(1) smooth(4) ///
	lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
	title("Malawi") xtitle("") ytitle("") palette(viridis) ///
	xlab(, valuelabel angle(45)) saving("$sfig/mwi_pl_bump", replace)

bumpline beta reg_num if country == 4, by(varname) top(6) xsize(2) ysize(1) smooth(4) ///
	lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
	title("Niger") xtitle("") ytitle("") palette(viridis) ///
	xlab(, valuelabel angle(45)) saving("$sfig/ngr_pl_bump", replace)

bumpline beta reg_num if country == 5, by(varname) top(6) xsize(2) ysize(1) smooth(4) ///
	lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
	title("Nigeria") xtitle("") ytitle("") palette(viridis) ///
	xlab(, valuelabel angle(45)) saving("$sfig/nga_pl_bump", replace)

bumpline beta reg_num if country == 6, by(varname) top(6) xsize(2) ysize(1) smooth(4) ///
	lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
	title("Tanzania") xtitle("") ytitle("") palette(viridis) ///
	xlab(, valuelabel angle(45)) saving("$sfig/tza_pl_bump", replace)

bumpline beta reg_num if country == 7, by(varname) top(6) xsize(2) ysize(1) smooth(4) ///
	lw(0.5) msym(square) mlwid(0.3) msize(1.1)  offset(20) ///
	title("Uganda") xtitle("") ytitle("") palette(viridis) ///
	xlab(, valuelabel angle(45)) saving("$sfig/uga_pl_bump", replace)
	
	gr combine 		"$sfig/eth_pl_bump.gph" "$sfig/mwi_pl_bump.gph" "$sfig/ngr_pl_bump.gph" ///
						"$sfig/nga_pl_bump.gph" "$sfig/tza_pl_bump.gph" "$sfig/uga_pl_bump.gph", ///
						col(2) iscale(.5) commonscheme
						
	graph export 	"$xfig\placebo_bump.pdf", as(pdf) replace
	
* close the log
	log	close

/* END */