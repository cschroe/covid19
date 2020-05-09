* ecdc_figures.do

* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Globals and Options
* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
clear
set more off
set matsize 10000
*set linesize 200

global startdate = "1mar2020"
global today = "9may2020"

global xstart = td($startdate)
global xend = td($today)

* Environment
run "/Users/Chris/Desktop/covid19/do/environment.do"

do "${do}/ecdc_build.do"


* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Figures
* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
use "${temp}/ecdc_temp.dta", clear

* ------------------------------------------------------------------------------
* Canada vs. ____
* ------------------------------------------------------------------------------
global country = "AUT"

foreach country in AUT AUS DEU FRA ESP ITA SWE USA KOR CHN CHE FIN GBR NOR {

	* Cumulative cases
	twoway (connected cumu_cases_100k day_100 if country_code == "CAN", lcolor(red)) ///
	(connected cumu_cases_100k day_100 if country_code == "`country'", lcolor(blue)), ///
	ytitle("Cumulative cases per 100,000") xtitle("Days since 100th case") ///
	legend(label(1 "CAN") label(2 "`country'") pos(6) row(1))
	graph export "${output}/ecdc/ecdc_cases_CAN_`country'.pdf", as(pdf) replace

	* Cumulative deaths
	twoway (connected cumu_deaths_100k day_100 if country_code == "CAN", lcolor(red)) ///
	(connected cumu_deaths_100k day_100 if country_code == "`country'", lcolor(blue)), ///
	ytitle("Cumulative deaths per 100,000") xtitle("Days since 100th case") ///
	legend(label(1 "CAN") label(2 "`country'") pos(6) row(1))
	graph export "${output}/ecdc/ecdc_deaths_CAN_`country'.pdf", as(pdf) replace

}

* ------------------------------------------------------------------------------
* Country 1 vs. Country 2
* ------------------------------------------------------------------------------
global country1 = "SWE"
global country2 = "ESP"

foreach country2 in FIN NOR DEU DNK FRA ITA ESP USA {

	* Cumulative cases
	twoway (connected cumu_cases_100k day_100 if country_code == "$country1", lcolor(red)) ///
	(connected cumu_cases_100k day_100 if country_code == "`country2'", lcolor(blue)), ///
	ytitle("Cumulative cases per 100,000") xtitle("Days since 100th case") ///
	legend(label(1 "$country1") label(2 "`country2'") pos(6) row(1))
	graph export "${output}/ecdc/ecdc_cases_${country1}_`country2'.pdf", as(pdf) replace

	* Cumulative deaths
	twoway (connected cumu_deaths_100k day_100 if country_code == "$country1", lcolor(red)) ///
	(connected cumu_deaths_100k day_100 if country_code == "`country2'", lcolor(blue)), ///
	ytitle("Cumulative deaths per 100,000") xtitle("Days since 100th case") ///
	legend(label(1 "$country1") label(2 "`country2'") pos(6) row(1))
	graph export "${output}/ecdc/ecdc_deaths_${country1}_`country2'.pdf", as(pdf) replace

}






