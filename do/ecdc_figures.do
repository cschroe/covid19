* ecdc_figures.do

* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Globals and Options
* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
clear
set more off
set matsize 10000
*set linesize 200

global startdate = "1mar2020"
global today = "21mar2020"

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
global country = "DEU"

* Cumulative cases
twoway (connected cumu_cases_100k day_100 if country_code == "CAN", lcolor(red)) ///
(connected cumu_cases_100k day_100 if country_code == "$country", lcolor(blue)), ///
ytitle("Cumulative cases per 100,000") xtitle("Days since 100th case") ///
legend(label(1 "CAN") label(2 "$country") pos(6) row(1))
graph export "${output}/ecdc/ecdc_cases_CAN_${country}.pdf", as(pdf) replace

* Cumulative deaths
twoway (connected cumu_deaths_100k day_100 if country_code == "CAN", lcolor(red)) ///
(connected cumu_deaths_100k day_100 if country_code == "$country", lcolor(blue)), ///
ytitle("Cumulative deaths per 100,000") xtitle("Days since 100th case") ///
legend(label(1 "CAN") label(2 "$country") pos(6) row(1))
graph export "${output}/ecdc/ecdc_deaths_CAN_${country}.pdf", as(pdf) replace











