* canada_cases.do

* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Globals and Options
* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
clear
set more off
set matsize 10000
*set linesize 200

global startdate = "1mar2020"
global today = "27mar2020"

global xstart = td($startdate)
global xend = td($today)

* Environment
run "/Users/Chris/Desktop/covid19/do/environment.do"

do "${do}/canada_build.do"

* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Cumulative cases across provinces
* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
use "${temp}/can_cases.dta", clear

twoway (connected cumu_cases_100k day_50 if province == "Alberta", lcolor(blue)) ///
(connected cumu_cases_100k day_50 if province == "BC", lcolor(orange)) ///
(connected cumu_cases_100k day_50 if province == "Manitoba", lcolor(brown)) ///
(connected cumu_cases_100k day_50 if province == "NL") ///
(connected cumu_cases_100k day_50 if province == "NWT") ///
(connected cumu_cases_100k day_50 if province == "New Brunswick") ///
(connected cumu_cases_100k day_50 if province == "Nova Scotia") ///
(connected cumu_cases_100k day_50 if province == "Ontario", lcolor(red)) ///
(connected cumu_cases_100k day_50 if province == "PEI") ///
(connected cumu_cases_100k day_50 if province == "Quebec", lcolor(purple)) ///
(connected cumu_cases_100k day_50 if province == "Saskatchewan", lcolor(green)) ///
(connected cumu_cases_100k day_50 if province == "Yukon"), ///
ytitle("Cumulative cases per 100,000") xtitle("Days since 50th case") ///
legend(label(1 "AB") label(2 "BC") label(3 "MB") label(4 "NL") label(5 "NWT") label(6 "NB") label(7 "NS") label(8 "ONT") label(9 "PEI") label(10 "PQ") label(11 "SASK") label(12 "YU") pos(6) row(3))
graph export "${output}/canada/can_provinces.pdf", as(pdf) replace







