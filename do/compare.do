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
run "/Users/Chris/Desktop/covid19_alberta/do/environment.do"

global abpop = 4413146 // Q1 2020 - Table 17-10-0009-01, Statistics Canada
global ab100k = $abpop / 100000

global itpop = 60400000 // istat.it, January 2019
global it100k = $itpop / 100000

global skpop = 51269185 // worldometers.info South Korea Population 
global sk100k = $skpop / 100000



* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Load and Prepare Data
* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
import excel "${input}/raw_data.xlsx", sheet("alberta") firstrow
keep day new_cases_total cumu_cases_total new_deaths cumu_deaths
save "${temp}/ab_temp.dta", replace

clear

import excel "${input}/raw_data.xlsx", sheet("skorea") firstrow
keep day new_cases_total cumu_cases_total new_deaths cumu_deaths
save "${temp}/sk_temp.dta", replace

clear

import excel "${input}/raw_data.xlsx", sheet("italy") firstrow
keep day new_cases_total cumu_cases_total new_deaths cumu_deaths
save "${temp}/it_temp.dta", replace

foreach var of varlist new_cases_total cumu_cases_total new_deaths cumu_deaths {
	replace `var' = `var' / $it100k
	rename `var' `var'_it
}

merge 1:1 day using "${temp}/ab_temp.dta"
cap drop _merge

foreach var of varlist new_cases_total cumu_cases_total new_deaths cumu_deaths {
	replace `var' = `var' / $ab100k
	rename `var' `var'_ab
}

merge 1:1 day using "${temp}/sk_temp.dta"
cap drop _merge

foreach var of varlist new_cases_total cumu_cases_total new_deaths cumu_deaths {
	replace `var' = `var' / $sk100k
	rename `var' `var'_sk
}


* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Alberta vs. Elsewhere
* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Cummulative cases
twoway (connected cumu_cases_total_ab day if new_cases_total_ab != ., color(blue)) ///
(connected cumu_cases_total_it day if new_cases_total_ab != .), ///
ytitle("Cummulative Cases per 100,000 inhabitants") xtitle("Days since first case") ///
legend(label(1 "Alberta") label(2 "Italy") pos(6) row(1)) ///
saving("${output}/cumu_cases_ab_it.gph", replace)
graph export "${output}/cumu_cases_ab_it.pdf", as(pdf) replace

twoway (connected cumu_cases_total_ab day if new_cases_total_ab != ., color(blue)) ///
(connected cumu_cases_total_sk day if new_cases_total_ab != .), ///
ytitle("Cummulative Cases per 100,000 inhabitants") xtitle("Days since first case") ///
legend(label(1 "Alberta") label(2 "South Korea") pos(6) row(1)) ///
saving("${output}/cumu_cases_ab_sk.gph", replace)
graph export "${output}/cumu_cases_ab_sk.pdf", as(pdf) replace

* Cumulative deaths
twoway (connected cumu_deaths_ab day if new_cases_total_ab != .,color(blue)) ///
(connected cumu_deaths_it day if new_cases_total_ab != .), ///
ytitle("Cummulative Deaths per 100,000 inhabitants") xtitle("Days since first case") ///
legend(label(1 "Alberta") label(2 "Italy") pos(6) row(1)) ///
saving("${output}/cumu_deaths_ab_it.gph", replace)
graph export "${output}/cumu_deaths_ab_it.pdf", as(pdf) replace

twoway (connected cumu_deaths_ab day if new_cases_total_ab != .,color(blue)) ///
(connected cumu_deaths_sk day if new_cases_total_ab != .), ///
ytitle("Cummulative Deaths per 100,000 inhabitants") xtitle("Days since first case") ///
legend(label(1 "Alberta") label(2 "South Korea") pos(6) row(1)) ///
saving("${output}/cumu_deaths_ab_sk.gph", replace)
graph export "${output}/cumu_deaths_ab_sk.pdf", as(pdf) replace

twoway (connected cumu_deaths_ab day if new_cases_total_ab != .,color(blue)) ///
(connected cumu_deaths_it day if new_cases_total_ab != .,color(red)) ///
(connected cumu_deaths_sk day if new_cases_total_ab != .), ///
ytitle("Cummulative Deaths per 100,000 inhabitants") xtitle("Days since first case") ///
legend(label(1 "Alberta") label(2 "Italy") label(3 "South Korea") pos(6) row(1)) ///
saving("${output}/cumu_deaths_ab_it_sk.gph", replace)
graph export "${output}/cumu_deaths_ab_it_sk.pdf", as(pdf) replace
