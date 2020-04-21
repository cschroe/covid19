* canada_deaths.do

* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Globals and Options
* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
clear
set more off
set matsize 10000
*set linesize 200

global startdate = "1mar2020"
global today = "19apr2020"

global xstart = td($startdate)
global xend = td($today)

* Environment
run "/Users/Chris/Desktop/covid19/do/environment.do"

do "${do}/canada_build.do"

* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Cumulative cases across provinces
* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
use "${temp}/can_deaths.dta", clear

twoway (line cumu_deaths_100k day_1 if province == "Alberta", lcolor(blue)) ///
(line cumu_deaths_100k day_1 if province == "BC", lcolor(orange)) ///
(line cumu_deaths_100k day_1 if province == "Manitoba", lcolor(brown)) ///
(line cumu_deaths_100k day_1 if province == "NL") ///
(line cumu_deaths_100k day_1 if province == "NWT") ///
(line cumu_deaths_100k day_1 if province == "New Brunswick") ///
(line cumu_deaths_100k day_1 if province == "Nova Scotia") ///
(line cumu_deaths_100k day_1 if province == "Ontario", lcolor(red)) ///
(line cumu_deaths_100k day_1 if province == "PEI") ///
(line cumu_deaths_100k day_1 if province == "Quebec", lcolor(purple)) ///
(line cumu_deaths_100k day_1 if province == "Saskatchewan", lcolor(green)) ///
(line cumu_deaths_100k day_1 if province == "Yukon"), ///
ytitle("Cumulative deaths per 100,000") xtitle("Days since 1st death") ///
legend(label(1 "AB") label(2 "BC") label(3 "MB") label(4 "NL") label(5 "NWT") label(6 "NB") label(7 "NS") label(8 "ONT") label(9 "PEI") label(10 "PQ") label(11 "SASK") label(12 "YU") pos(6) row(3))
graph export "${output}/canada/can_provinces_deaths.pdf", as(pdf) replace







