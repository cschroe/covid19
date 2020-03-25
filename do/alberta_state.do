* alberta_state.do

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

global icucap = 207


* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Load Data
* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
import excel "${input}/raw_data.xlsx", sheet("alberta") firstrow
drop if cumu_cases_total == 0

cap drop day
gen day = _n

cap drop exp
gen exp = (1.11)^(day)


* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Cases
* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* New cases
twoway bar new_cases_total date if new_cases_total != ., ///
ytitle("New Cases") xtitle("Date reported to AHS") ///
xlabel(${xstart}(7)${xend}, angle(45)) ///
saving("${output}/new_cases_ab.gph", replace)
graph export "${output}/new_cases_ab.pdf", as(pdf) replace

* Cummulative cases
twoway connected cumu_cases_total date if new_cases_total != ., ///
ytitle("Total Cummulative Cases") xtitle("Date reported to AHS") ///
xlabel(${xstart}(7)${xend}, angle(45)) ///
saving("${output}/cumu_cases_ab.gph", replace)
graph export "${output}/cumu_cases_ab.pdf", as(pdf) replace

* Cummulative cases by source of infection
twoway (connected cumu_cases_travel date if new_cases_total != .) ///
(connected cumu_cases_closecont date if new_cases_total != .) ///
(connected cumu_cases_comm date if new_cases_total != .), ///
ytitle("Cummulative Cases") xtitle("Date reported to AHS") ///
xlabel(${xstart}(7)${xend}, angle(45)) ///
legend(label(1 "Travel") label(2 "Close Contact of Traveler") label(3 "Community Transmission") pos(6) row(1)) ///
saving("${output}/cumu_cases_source_ab.gph", replace)
graph export "${output}/cumu_cases_source_ab.pdf", as(pdf) replace


* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Hospitalizations
* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* ------------------------------------------------------------------------------
* Total hospitalizations
* ------------------------------------------------------------------------------
* New hopsitalizations
twoway bar new_hospital date if new_cases_total != ., ///
ytitle("New Hospitalizations") xtitle("Date") ///
xlabel(${xstart}(7)${xend}, angle(45)) ///
saving("${output}/new_hospital_ab.gph", replace)
graph export "${output}/new_hospital_ab.pdf", as(pdf) replace

* Hospital beds occupied
twoway connected current_hospital date if new_cases_total != ., ///
ytitle("Hospital Beds Occupied") xtitle("Date") ///
xlabel(${xstart}(7)${xend}, angle(45)) ///
saving("${output}/current_hospital_ab.gph", replace)
graph export "${output}/current_hospital_ab.pdf", as(pdf) replace

* Cummulative hopsitalizations
twoway connected cumu_hospital date if new_cases_total != ., ///
ytitle("Cummulative Hospitalizations") xtitle("Date") ///
xlabel(${xstart}(7)${xend}, angle(45)) ///
saving("${output}/cumu_hospital_ab.gph", replace)
graph export "${output}/cumu_hospital_ab.pdf", as(pdf) replace


* ------------------------------------------------------------------------------
* ICU admissions
* ------------------------------------------------------------------------------
* New ICU admissions
twoway bar new_icu date if new_cases_total != ., ///
ytitle("New ICU Admissions") xtitle("Date") ///
xlabel(${xstart}(7)${xend}, angle(45)) ///
saving("${output}/new_icu_ab.gph", replace)
graph export "${output}/new_icu_ab.pdf", as(pdf) replace

* ICU beds occupied
twoway connected current_icu date if new_cases_total != ., ///
ytitle("ICU beds occupied") xtitle("Date") ///
xlabel(${xstart}(7)${xend}, angle(45)) ///
saving("${output}/current_icu_ab.gph", replace)
graph export "${output}/current_icu_ab.pdf", as(pdf) replace

* Cummulative ICU admissions
twoway connected cumu_icu date if new_cases_total != ., ///
ytitle("Cummulative ICU Admissions") xtitle("Date") ///
xlabel(${xstart}(7)${xend}, angle(45)) ///
saving("${output}/cumu_icu_ab.gph", replace)
graph export "${output}/cumu_icu_ab.pdf", as(pdf) replace


* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Projections
* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
cap drop exp
gen exp = (1.11)^(day)

* ICU bed capacity
replace current_icu = . if new_cases_total == .
twoway connected exp date if exp <= ($icucap + 50), yline($icucap) ///
ytitle("ICU Beds Occupied") xtitle("Date")









