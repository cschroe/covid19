* alberta.do

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

* ------------------------------------------------------------------------------
* Parameters, Capactiy, Dates of Implemented Measures
* ------------------------------------------------------------------------------
global abpop = 4413146 // Q1 2020 - Table 17-10-0009-01, Statistics Canada
global ab100k = $abpop / 100000

global icucap = 207

* Measures implemented in Alberta
global mass250 = td("12mar2020") // Limit on mass gatherings of 250 people, March 12
global schools = td("15mar2020") // Closure of schools, March 15
global mass50 = td("17mar2020") // Limit on mass gatherings of 50 people, March 17
global enforce = td("25mar2020") // Enforcement of mandatory public health orders, March 25

* Measures implemented in Canada


foreach date in mass250 schools mass50 enforce {
	global `date'2w = $`date' + 14
}


* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Cases
* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Load data
clear
import excel "${input}/raw_data_ab.xlsx", sheet("cases") firstrow

* ------------------------------------------------------------------------------
* Descriptives
* ------------------------------------------------------------------------------
* New cases
twoway bar new_cases_total date if new_cases_total != ., ///
ytitle("New Cases") xtitle("Date reported to AHS") ///
xlabel(${xstart}(7)${xend}, angle(45)) ///
xline($mass2502w) text(80 $mass2502w "< 250 + 2 weeks", place(w) orientation(horizontal) size(small)) ///
xline($schools2w) text(90 $schools2w "Schools closed + 2 weeks", place(w) orientation(horizontal) size(small)) ///
xline($mass502w) text(100 $mass502w "< 50 + 2 weeks", place(w) orientation(horizontal) size(small)) ///
//xline($enforce2w) text(110 $enforce2w "Enforcement + 2 weeks", place(w) orientation(horizontal) size(small)) ///
//saving("${output}/new_cases_ab.gph", replace)
graph export "${output}/alberta/new_cases_ab.pdf", as(pdf) replace

* Cumulative cases
twoway connected cumu_cases_total date if new_cases_total != ., ///
ytitle("Total Cumulative Cases") xtitle("Date reported to AHS") ///
xlabel(${xstart}(7)${xend}, angle(45)) ///
xline($mass2502w) text(100 $mass2502w "< 250 + 2 weeks", place(w) orientation(horizontal) size(small)) ///
xline($schools2w) text(150 $schools2w "Schools closed + 2 weeks", place(w) orientation(horizontal) size(small)) ///
xline($mass502w) text(200 $mass502w "< 50 + 2 weeks", place(w) orientation(horizontal) size(small)) ///
//xline($enforce2w) text(250 $enforce2w "Enforcement + 2 weeks", place(w) orientation(horizontal) size(small)) ///
//saving("${output}/cumu_cases_ab.gph", replace)
graph export "${output}/alberta/cumulative_cases_ab.pdf", as(pdf) replace

* Cumulative cases by source of infection
twoway (connected cumu_cases_travel date if new_cases_total != .) ///
(connected cumu_cases_closecont date if new_cases_total != .) ///
(connected cumu_cases_comm date if new_cases_total != .), ///
ytitle("Cumulative Cases") xtitle("Date reported to AHS") ///
legend(label(1 "Travel") label(2 "Close Contact of Traveller") label(3 "Community Transmission") pos(6) row(1)) ///
xlabel(${xstart}(7)${xend}, angle(45)) ///
xline($mass2502w) text(50 $mass2502w "< 250 + 2 weeks", place(w) orientation(horizontal) size(small)) ///
xline($schools2w) text(100 $schools2w "Schools closed + 2 weeks", place(w) orientation(horizontal) size(small)) ///
xline($mass502w) text(150 $mass502w "< 50 + 2 weeks", place(w) orientation(horizontal) size(small)) ///
//xline($enforce2w) text(200 $enforce2w "Enforcement + 2 weeks", place(w) orientation(horizontal) size(small)) ///
//saving("${output}/cumu_cases_source_ab.gph", replace)
graph export "${output}/alberta/cumulative_cases_source_ab.pdf", as(pdf) replace

* ------------------------------------------------------------------------------
* Estimate exponential growth rate
* ------------------------------------------------------------------------------
* Generate logs
foreach var in cumu_cases_total {
	cap drop log_`var'
	gen log_`var' = ln(`var')
}

* Regress
reg log_cumu_cases_total day_1 if new_cases_total != .

* Inital value
*scalar init_value = exp(_b[_cons])
local init_value = exp(_b[_cons])

* Growth factor
*scalar ex_growth = exp(_b[day_1])
local ex_growth = exp(_b[day_1])

* Exponential growth
cap drop ex_growth
gen ex_growth = (`init_value')*((`ex_growth')^(day_1))

* Plot
twoway (connected cumu_cases_total date if new_cases_total != .) ///
(connected ex_growth date if new_cases_total != ., lcolor(blue)), ///
ytitle("Total Cumulative Cases") xtitle("Date reported to AHS") ///
legend(label(1 "Data") label(2 "Exponential growth") pos(6) row(1)) ///
note("Exponential growth factor: `ex_growth', Initial value: `init_value'")
graph export "${output}/alberta/cumulative_cases_exp_ab.pdf", as(pdf) replace


* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Hospitalizations
* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Load data
clear
import excel "${input}/raw_data_ab.xlsx", sheet("hospitalizations") firstrow

* New hopsitalizations
twoway bar new_hospital date if new_hospital != ., ///
ytitle("New Hospitalizations") xtitle("Date") ///
xlabel(${xstart}(7)${xend}, angle(45)) ///
xline($mass2502w) text(8 $mass2502w "< 250 + 2 weeks", place(w) orientation(horizontal) size(small)) ///
xline($schools2w) text(9 $schools2w "Schools closed + 2 weeks", place(w) orientation(horizontal) size(small)) ///
xline($mass502w) text(10 $mass502w "< 50 + 2 weeks", place(w) orientation(horizontal) size(small)) ///
//xline($enforce2w) text(11 $enforce2w "Enforcement + 2 weeks", place(w) orientation(horizontal) size(small)) ///
//saving("${output}/new_hospital_ab.gph", replace)
graph export "${output}/alberta/new_hospitalizations_ab.pdf", as(pdf) replace

* Hospital beds occupied
twoway connected current_hospital date if new_hospital != ., ///
ytitle("Hospital Beds Occupied") xtitle("Date") ///
xlabel(${xstart}(7)${xend}, angle(45)) ///
xline($mass2502w) text(5 $mass2502w "< 250 + 2 weeks", place(w) orientation(horizontal) size(small)) ///
xline($schools2w) text(10 $schools2w "Schools closed + 2 weeks", place(w) orientation(horizontal) size(small)) ///
xline($mass502w) text(15 $mass502w "< 50 + 2 weeks", place(w) orientation(horizontal) size(small)) ///
//xline($enforce2w) text(20 $enforce2w "Enforcement + 2 weeks", place(w) orientation(horizontal) size(small)) ///
//saving("${output}/current_hospital_ab.gph", replace)
graph export "${output}/alberta/current_hospitalizations_ab.pdf", as(pdf) replace

* Cumulative hopsitalizations
twoway connected cumu_hospital date if new_hospital != ., ///
ytitle("Cumulative Hospitalizations") xtitle("Date") ///
xlabel(${xstart}(7)${xend}, angle(45)) ///
xline($mass2502w) text(5 $mass2502w "< 250 + 2 weeks", place(w) orientation(horizontal) size(small)) ///
xline($schools2w) text(10 $schools2w "Schools closed + 2 weeks", place(w) orientation(horizontal) size(small)) ///
xline($mass502w) text(15 $mass502w "< 50 + 2 weeks", place(w) orientation(horizontal) size(small)) ///
//xline($enforce2w) text(20 $enforce2w "Enforcement + 2 weeks", place(w) orientation(horizontal) size(small)) ///
//saving("${output}/cumu_hospital_ab.gph", replace)
graph export "${output}/alberta/cumulative_hospitalizations_ab.pdf", as(pdf) replace

* ------------------------------------------------------------------------------
* Estimate exponential growth rate
* ------------------------------------------------------------------------------
* Generate logs
foreach var in current_hospital {
	cap drop log_`var'
	gen log_`var' = ln(`var')
}

* Regress
reg log_current_hospital day_1 if new_hospital != .

* Inital value
local init_value = exp(_b[_cons])

* Growth factor
local ex_growth = exp(_b[day_1])

* Exponential growth
cap drop ex_growth
gen ex_growth = (`init_value')*((`ex_growth')^(day_1))

* Plot
twoway (connected current_hospital date if new_hospital != .) ///
(connected ex_growth date if new_hospital != ., lcolor(blue)), ///
ytitle("Hospital beds occupied") xtitle("Date") ///
legend(label(1 "Data") label(2 "Exponential growth") pos(6) row(1)) ///
note("Exponential growth factor: `ex_growth', Initial value: `init_value'")
graph export "${output}/alberta/current_hospitalizations_exp_ab.pdf", as(pdf) replace


* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* ICU admissions
* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Load data
clear
import excel "${input}/raw_data_ab.xlsx", sheet("icu") firstrow

* New ICU admissions
twoway bar new_icu date if new_icu != ., ///
ytitle("New ICU Admissions") xtitle("Date") ///
xlabel(${xstart}(7)${xend}, angle(45)) ///
xline($mass2502w) text(2 $mass2502w "< 250 + 2 weeks", place(w) orientation(horizontal) size(small)) ///
xline($schools2w) text(3 $schools2w "Schools closed + 2 weeks", place(w) orientation(horizontal) size(small)) ///
xline($mass502w) text(4 $mass502w "< 50 + 2 weeks", place(w) orientation(horizontal) size(small)) ///
//xline($enforce2w) text(5 $enforce2w "Enforcement + 2 weeks", place(w) orientation(horizontal) size(small)) ///
//saving("${output}/new_icu_ab.gph", replace)
graph export "${output}/alberta/new_icu_ab.pdf", as(pdf) replace

* ICU beds occupied
twoway connected current_icu date if new_icu != ., ///
ytitle("ICU beds occupied") xtitle("Date") ///
xlabel(${xstart}(7)${xend}, angle(45)) ///
xline($mass2502w) text(2 $mass2502w "< 250 + 2 weeks", place(w) orientation(horizontal) size(small)) ///
xline($schools2w) text(4 $schools2w "Schools closed + 2 weeks", place(w) orientation(horizontal) size(small)) ///
xline($mass502w) text(6 $mass502w "< 50 + 2 weeks", place(w) orientation(horizontal) size(small)) ///
//xline($enforce2w) text(8 $enforce2w "Enforcement + 2 weeks", place(w) orientation(horizontal) size(small)) ///
//saving("${output}/current_icu_ab.gph", replace)
graph export "${output}/alberta/current_icu_ab.pdf", as(pdf) replace

* Cumulative ICU admissions
twoway connected cumu_icu date if new_icu != ., ///
ytitle("Cumulative ICU Admissions") xtitle("Date") ///
xlabel(${xstart}(7)${xend}, angle(45)) ///
xline($mass2502w) text(2 $mass2502w "< 250 + 2 weeks", place(w) orientation(horizontal) size(small)) ///
xline($schools2w) text(4 $schools2w "Schools closed + 2 weeks", place(w) orientation(horizontal) size(small)) ///
xline($mass502w) text(6 $mass502w "< 50 + 2 weeks", place(w) orientation(horizontal) size(small)) ///
//xline($enforce2w) text(8 $enforce2w "Enforcement + 2 weeks", place(w) orientation(horizontal) size(small)) ///
//saving("${output}/cumu_icu_ab.gph", replace)
graph export "${output}/alberta/cumulative_icu_ab.pdf", as(pdf) replace

* ------------------------------------------------------------------------------
* Estimate exponential growth rate
* ------------------------------------------------------------------------------
* Generate logs
foreach var in current_icu {
	cap drop log_`var'
	gen log_`var' = ln(`var')
}

* Regress
reg log_current_icu day_1 if new_icu != .

* Inital value
local init_value = exp(_b[_cons])

* Growth factor
local ex_growth = exp(_b[day_1])

* Exponential growth
cap drop ex_growth
gen ex_growth = (`init_value')*((`ex_growth')^(day_1))

* Plot
twoway (connected current_icu date if new_icu != .) ///
(connected ex_growth date if new_icu != ., lcolor(blue)), ///
ytitle("ICU beds occupied") xtitle("Date") ///
legend(label(1 "Data") label(2 "Exponential growth") pos(6) row(1)) ///
note("Exponential growth factor: `ex_growth', Initial value: `init_value'")
graph export "${output}/alberta/current_icu_exp_ab.pdf", as(pdf) replace













