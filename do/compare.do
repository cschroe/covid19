* compare.do

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

global abpop = 4413146 // Q1 2020 - Table 17-10-0009-01, Statistics Canada
global ab100k = $abpop / 100000

global canpop = 37894799 // Q1 2020 - Table 17-10-0009-01, Statistics Canada
global can100k = $canpop / 100000

global itpop = 60400000 // istat.it, January 2019
global it100k = $itpop / 100000

global skpop = 51269185 // worldometers.info South Korea Population 
global sk100k = $skpop / 100000

global swepop = 10333456 // https://www.scb.se/en/finding-statistics/statistics-by-subject-area/population/population-composition/population-statistics/, January 2020 
global swe100k = $swepop / 100000


* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Import and Prepare Data
* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
import excel "${input}/raw_data.xlsx", sheet("alberta") firstrow
keep day* new_cases_total cumu_cases_total new_deaths cumu_deaths
drop if day_50 == .
save "${temp}/ab_temp.dta", replace

clear

import excel "${input}/raw_data.xlsx", sheet("canada") firstrow
keep day* new_cases_total cumu_cases_total new_deaths cumu_deaths
drop if day_50 == .
save "${temp}/can_temp.dta", replace

clear

import excel "${input}/raw_data.xlsx", sheet("italy") firstrow
keep day* new_cases_total cumu_cases_total new_deaths cumu_deaths
drop if day_50 == .
save "${temp}/it_temp.dta", replace

clear

import excel "${input}/raw_data.xlsx", sheet("skorea") firstrow
keep day* new_cases_total cumu_cases_total new_deaths cumu_deaths
drop if day_50 == .
save "${temp}/sk_temp.dta", replace

clear

import excel "${input}/raw_data.xlsx", sheet("sweden") firstrow
keep day day* new_cases_total cumu_cases_total new_deaths cumu_deaths
drop if day_50 == .
save "${temp}/swe_temp.dta", replace

foreach var of varlist new_cases_total cumu_cases_total new_deaths cumu_deaths {
	replace `var' = `var' / $swe100k
	rename `var' `var'_swe
}

foreach region in ab can it sk {
	merge 1:1 day_50 using "${temp}/`region'_temp.dta"
	cap drop _merge

	foreach var of varlist new_cases_total cumu_cases_total new_deaths cumu_deaths {
		replace `var' = `var' / ${`region'100k}
		rename `var' `var'_`region'
	}
}


* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Cummulative cases
* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* All
twoway (connected cumu_cases_total_ab day_50 if new_cases_total_ab != ., color(blue)) ///
(connected cumu_cases_total_can day_50 if new_cases_total_ab != ., color(red)) ///
(connected cumu_cases_total_it day_50 if new_cases_total_ab != ., color(green)) ///
(connected cumu_cases_total_sk day_50 if new_cases_total_ab != .) ///
(connected cumu_cases_total_swe day_50 if new_cases_total_ab != ., color(yellow)), ///
ytitle("Cummulative Cases per 100,000 inhabitants") xtitle("Days since 50th case") ///
legend(label(1 "Alberta") label(2 "Canada") label(3 "Italy") label(4 "South Korea") label(5 "Sweden") pos(6) row(1)) ///
saving("${output}/cumu_cases_all.gph", replace)
graph export "${output}/cumu_cases_all.pdf", as(pdf) replace


* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Cummulative deaths
* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* All
twoway (connected cumu_deaths_ab day_50 if new_cases_total_ab != ., color(blue)) ///
(connected cumu_deaths_can day_50 if new_cases_total_ab != ., color(red)) ///
(connected cumu_deaths_it day_50 if new_cases_total_ab != ., color(green)) ///
(connected cumu_deaths_sk day_50 if new_cases_total_ab != .) ///
(connected cumu_deaths_swe day_50 if new_cases_total_ab != ., color(yellow)), ///
ytitle("Cummulative Deaths per 100,000 inhabitants") xtitle("Days since 50th case") ///
legend(label(1 "Alberta") label(2 "Canada") label(3 "Italy") label(4 "South Korea") label(5 "Sweden") pos(6) row(1)) ///
saving("${output}/cumu_deaths_all.gph", replace)
graph export "${output}/cumu_deaths_all.pdf", as(pdf) replace

