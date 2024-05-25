* Project: WB Weather
* Created on: Feb 2024
* Created by: jet
* Edited on: 24 May 2024
* Edited by: reece
* Stata v.18

* does
	* reads in Nigeria, WAVE 4 (2018-2019) POST PLANTING, NIGERIA AG SECTA1
	* determines primary and secondary crops, cleans plot size (hecatres)
	* outputs clean data file ready for combination with wave 4 plot data
	* outputs clean data file ready for combination with wave 4 hh data

* assumes
	* access to the raw data
	* land-conversion.dta conversion file

* TO DO:
	* custom save, log
	
***********************************************************************
**# 0 - setup
***********************************************************************
	
* define paths	
	global	root			"$data/household_data/nigeria/wave_4/raw"
	global	cnvrt   		"$data/household_data/nigeria/conversion_files"
	global 	export  		"$data/household_data/nigeria/wave_4/refined"
	global 	logout  		"$data/household_data/nigeria/logs"

* open log	
	cap log close
	log using "$logout/2018_ph_sect11a1", append

***********************************************************************
**# 1 - find unique identifier and determine plot size
***********************************************************************
		
* import the relevant data file
		use "$root/sect11a1_plantingw4", clear 	

* find unique identifier	
		isid				hhid plotid
		
* determine self reported plotsize
		gen plot_size_SR = s11aq4aa
		rename s11aq4b plot_unit
		label variable plot_size_SR "self reported size of plot, not standardized"
		label variable plot_unit "self reported unit of measure, 1=heaps, 2=ridges, 3=stands, 4=plots, 5=acres, 6=hectares, 7=sq meters, 8=other"
		
* determine GPS plotsize
		gen plot_size_GPS = s11aq4c
		label variable plot_size_GPS "GPS plotsize in sq. meters"
		
***********************************************************************
**# 2 - conversions
***********************************************************************

* merge in conversion file
	merge 			m:1 	zone using 	"$cnvrt/land-conversion"
	
	***all observations matched

	
	keep 			if 		_merge == 3
	drop 			_merge

	tab 			plot_unit
	
	* convert SR to hectares
	gen 			plot_size_hec = .
	replace 		plot_size_hec = plot_size_SR*ridgecon	if plot_unit == 2
	*heaps
	replace 		plot_size_hec = plot_size_SR*heapcon	if plot_unit == 1
	*stands
	replace 		plot_size_hec = plot_size_SR*standcon	if plot_unit == 3
	*plots
	replace 		plot_size_hec = plot_size_SR*plotcon	if plot_unit == 4
	*acre
	replace 		plot_size_hec = plot_size_SR*acrecon	if plot_unit == 5
	*sqm
	replace 		plot_size_hec = plot_size_SR*sqmcon		if plot_unit == 7
	*hec
	replace 		plot_size_hec = plot_size_SR			if plot_unit == 6

	rename 			plot_size_hec plot_size_hec_SR
	lab var			plot_size_hec_SR 	"SR plot size converted to hectares"

	count 			if plot_size_hec_SR !=.
	count			if plot_size_hec_SR == . 
	*** 4 observations do not have plot_size_hec_SR
	*** 11072 observations have plot_size_hec_SR

	* convert GPS  to hectares
	count if plot_size_GPS == .
	*** 4,202 missing GPS
	gen 			plot_size_2 = .
	replace 		plot_size_2 = plot_size_GPS*sqmcon
	rename 			plot_size_2 plot_size_hec_GPS
	lab	var			plot_size_hec_GPS "GPS measured area of plot in hectares"

	count if plot_size_hec_GPS != .
	*** these 4202 observations have no value of GPS given so cannot be converted 
	*** will impute missing
	count if plot_size_hec_GPS == .
	*** 6,874 observations for plot size in hectares GPS 
	
	pwcorr 			plot_size_hec_SR plot_size_hec_GPS
	*** very low correlation = 0.017 between selfreported plot size and GPS

* check correlation within +/- 3sd of mean (GPS)
	sum 			plot_size_hec_GPS, detail
	pwcorr 			plot_size_hec_SR plot_size_hec_GPS if ///
						inrange(plot_size_hec_GPS,`r(p50)'-(3*`r(sd)'),`r(p50)'+(3*`r(sd)'))
	*** correlation of points with +/- 3sd is higher 0.0313

* check correlation within +/- 3sd of mean (GPS and SR)
	sum 			plot_size_hec_GPS, detail
	sum 			plot_size_hec_SR, detail
	pwcorr 			plot_size_hec_SR plot_size_hec_GPS if ///
						inrange(plot_size_hec_GPS,`r(p50)'-(3*`r(sd)'),`r(p50)'+(3*`r(sd)')) & ///
						inrange(plot_size_hec_SR,`r(p50)'-(3*`r(sd)'),`r(p50)'+(3*`r(sd)'))
	*** correlation between self reported and GPS for values within +/- 3 sd's of GPS and SR is higher 0.3929
	*** much higher than wave 3 correlation (0.1442 -> 0.3929)

* examine larger plot sizes
	tab				plot_size_hec_GPS 	if 	plot_size_hec_GPS > 2
	*** 308 GPS which are greater than 2
	tab				plot_size_hec_GPS 	if 	plot_size_hec_GPS > 20
	*** only one is greater than 20 

	* correlation at higher plot sizes
	list 			plot_size_hec_GPS plot_size_hec_SR 	if ///
						plot_size_hec_GPS > 3 & !missing(plot_size_hec_GPS), sep(0)
	pwcorr 			plot_size_hec_GPS plot_size_hec_SR 	if 	///
						plot_size_hec_GPS > 3 & !missing(plot_size_hec_GPS)
	*** much lower correlation at higher plot sizes than correlation among all values - 0.0647

* examine smaller plot sizes
	tab				plot_size_hec_GPS 	if 	plot_size_hec_GPS < 0.1
	*** 1,801  below 0.1
	tab				plot_size_hec_GPS 	if 	plot_size_hec_GPS < 0.05
	*** 980 below 0.5
	tab				plot_size_hec_GPS 	if 	plot_size_hec_GPS < 0.005
	*** 40 below 0.005
	*** the smallest plot is 4 square meters, could feasibly be a very small vegetable patch
	*** all small values are reasonable - give GPS sensing abilities 

*correlation at lower plot sizes
	list 			plot_size_hec_GPS plot_size_hec_SR 	if 	///
						plot_size_hec_GPS < 0.01, sep(0)
	pwcorr 			plot_size_hec_GPS plot_size_hec_SR 	if ///
						plot_size_hec_GPS < 0.01
	*** higher correlation between GPS and SR plotsize, correlation = 0.1086
	*** still comparatively low to wave 3, and relationship changed sign

	* compare GPS and SR
* examine GPS 
	sum 			plot_size_hec_GPS
	sum 			plot_size_hec_SR
	*** GPS tending to be smaller than self-reported - and more realistic
	*** as in wave 3, will not include SR in imputation - only will include GPS 
	
	*hist	 		plot_size_hec_GPS 	if 	plot_size_hec_GPS < 0.3
	*hist	 		plot_size_hec_GPS 	if 	plot_size_hec_GPS < 0.2
	*** distributions are very close to the shape of wave 3 distributions
	*** roughly uniform distribution until 0.5 to 0.3 hectares
	*** distribution looks okay! 

	* impute missing plot sizes using predictive mean matching
	mi set 			wide // declare the data to be wide.
	mi xtset		, clear // this is a precautinary step to clear any existing xtset
	mi register 	imputed plot_size_hec_GPS // identify plotsize_GPS as the variable being imputed
	sort			hhid plotid, stable // sort to ensure reproducability of results
	mi impute 		pmm plot_size_hec_GPS i.state, add(1) rseed(245780) noisily dots ///
						force knn(5) bootstrap
	mi unset

* look at the data 
* this piece of code gives three values to consider: SR, GPS before 	conversion, and GPS after conversion (indicated with _1_) 
	tab				mi_miss
	tabstat 		plot_size_hec_GPS plot_size_hec_SR plot_size_hec_GPS_1_, ///
						by(mi_miss) statistics(n mean min max) columns(statistics) ///
						longstub format(%9.3g)
						
* drop if anything else is still missing
	list			plot_size_hec_GPS plot_size_hec_SR 	if 	///
						missing(plot_size_hec_GPS_1_), sep(0)
	drop 			if missing(plot_size_hec_GPS_1_)
	*** 0 observations deleted
	
	rename			plot_size_hec_GPS_1_ plotsize
	lab	var			plotsize	"plot size (ha)"
	
************************************************************************
**# 3 - end matter, clean up to save
************************************************************************

	keep 			hhid zone state lga hhid ea plotid plotsize

* create unique household-plot identifier
	sort			hhid plotid
	egen			plot_id = group(hhid plotid)
	lab var			plot_id "unique plot identifier"

	compress
	describe
	summarize


* save file
	save 			"$export/ph_sect11a1.dta", replace 
	*** should this be "pp_sect11a1"? it is ph in wv3 as well, so i didn't change this
* close the log
	log	close

/* END */