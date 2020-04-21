* alberta.do

* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Globals and Options
* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
clear
set more off
set matsize 10000
*set linesize 200

global startdate = "1mar2020"
global today = "20apr2020"

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
global mass15 = td("27mar2020") // Limit on mass gatherings of 15 people, March 27

foreach date in mass250 schools mass50 enforce mass15 {
	global `date'2w = $`date' + 21
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
title("New Cases per Day") ///
ytitle("New Cases") xtitle("Date reported to AHS") ///
xlabel(${xstart}(7)${xend}, angle(45)) ///
xline($mass2502w) text(150 $mass2502w "A  ", place(w) orientation(horizontal) size(small)) ///
xline($schools2w) text(150 $schools2w "B  ", place(w) orientation(horizontal) size(small)) ///
xline($mass502w) text(150 $mass502w "C  ", place(w) orientation(horizontal) size(small)) ///
xline($enforce2w) text(150 $enforce2w "D  ", place(w) orientation(horizontal) size(small)) ///
note("A: Mass gatherings restricted to 250 people, plus 3 weeks" ///
"B: Schools closed, plus 3 weeks" ///
"C: Mass gatherings restricted to 50 people, plus 3 weeks" ///
"D: Enforcement of mandatory publich health orders, plus 3 weeks", size(vsmall))
//saving("${output}/new_cases_ab.gph", replace)
graph export "${output}/alberta/new_cases_ab.pdf", as(pdf) replace

* Cumulative cases
twoway connected cumu_cases_total date if new_cases_total != ., ///
title("Total Cumulative Cases") ///
ytitle("Confirmed Cases") xtitle("Date reported to AHS") ///
xlabel(${xstart}(7)${xend}, angle(45)) ///
xline($mass2502w) text(150 $mass2502w "A  ", place(w) orientation(horizontal) size(small)) ///
xline($schools2w) text(150 $schools2w "B  ", place(w) orientation(horizontal) size(small)) ///
xline($mass502w) text(150 $mass502w "C  ", place(w) orientation(horizontal) size(small)) ///
xline($enforce2w) text(150 $enforce2w "D  ", place(w) orientation(horizontal) size(small)) ///
note("A: Mass gatherings restricted to 250 people, plus 3 weeks" ///
"B: Schools closed, plus 3 weeks" ///
"C: Mass gatherings restricted to 50 people, plus 3 weeks" ///
"D: Enforcement of mandatory publich health orders, plus 3 weeks", size(vsmall))
//saving("${output}/cumu_cases_ab.gph", replace)
graph export "${output}/alberta/cumulative_cases_ab.pdf", as(pdf) replace

* Cumulative cases by source of infection
twoway (connected cumu_cases_travel date if new_cases_total != .) ///
(connected cumu_cases_known date if new_cases_total != .) ///
(connected cumu_cases_comm date if new_cases_total != .), ///
title("Total Confirmed Cases by Source of Infection") ///
ytitle("Confirmed Cases") xtitle("Date reported to AHS") ///
legend(label(1 "Travel") label(2 "Known Source") label(3 "Community Transmission") pos(6) row(1)) ///
xlabel(${xstart}(7)${xend}, angle(45)) ///
xline($mass2502w) text(350 $mass2502w "A  ", place(w) orientation(horizontal) size(small)) ///
xline($schools2w) text(350 $schools2w "B  ", place(w) orientation(horizontal) size(small)) ///
xline($mass502w) text(350 $mass502w "C  ", place(w) orientation(horizontal) size(small)) ///
xline($enforce2w) text(350 $enforce2w "D  ", place(w) orientation(horizontal) size(small)) ///
note("A: Mass gatherings restricted to 250 people, plus 3 weeks" ///
"B: Schools closed, plus 3 weeks" ///
"C: Mass gatherings restricted to 50 people, plus 3 weeks" ///
"D: Enforcement of mandatory publich health orders, plus 3 weeks", size(vsmall))
//saving("${output}/cumu_cases_source_ab.gph", replace)
graph export "${output}/alberta/cumulative_cases_source_ab.pdf", as(pdf) replace

* ------------------------------------------------------------------------------
* Estimate exponential growth rate
* ------------------------------------------------------------------------------
* Generate logs
cap drop log_cumu_cases_total
gen log_cumu_cases_total = ln(cumu_cases_total)

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
title("Total Cumulative Cases vs. Best fit Exponential Growth") ///
ytitle("Confirmed Cases") xtitle("Date reported to AHS") ///
legend(label(1 "Data") label(2 "Exponential growth") pos(6) row(1)) ///
xlabel(${xstart}(7)${xend}, angle(45)) ///
xline($mass2502w) text(350 $mass2502w "A  ", place(w) orientation(horizontal) size(small)) ///
xline($schools2w) text(350 $schools2w "B  ", place(w) orientation(horizontal) size(small)) ///
xline($mass502w) text(350 $mass502w "C  ", place(w) orientation(horizontal) size(small)) ///
xline($enforce2w) text(350 $enforce2w "D  ", place(w) orientation(horizontal) size(small)) ///
note("Exponential growth factor: `ex_growth', Initial value: `init_value'" ///
"A: Mass gatherings restricted to 250 people, plus 3 weeks" ///
"B: Schools closed, plus 3 weeks" ///
"C: Mass gatherings restricted to 50 people, plus 3 weeks" ///
"D: Enforcement of mandatory publich health orders, plus 3 weeks", size(vsmall))
graph export "${output}/alberta/cumulative_cases_exp_ab.pdf", as(pdf) replace

* ------------------------------------------------------------------------------
* Doubling
* ------------------------------------------------------------------------------
* Doubling rate for each cumulative total
foreach var of varlist cumu_cases_total {
	cap drop gr_`var'
	gen gr_`var' = ((`var' - `var'[_n-5])/`var'[_n-5])*100
	cap drop dd_`var'
	gen dd_`var' = (70/gr_`var')*5
}

* Doubling days of total cumulative cases
twoway connected dd_cumu_cases_total date if new_cases_total != ., ///
title("Doubling Time in Days of Total Cumulative Cases") ///
ytitle("Days") xtitle("Date reported to AHS") ///
xlabel(${xstart}(7)${xend}, angle(45)) ///
xline($mass2502w) text(2 $mass2502w "A  ", place(w) orientation(horizontal) size(small)) ///
xline($schools2w) text(2 $schools2w "B  ", place(w) orientation(horizontal) size(small)) ///
xline($mass502w) text(2 $mass502w "C  ", place(w) orientation(horizontal) size(small)) ///
xline($enforce2w) text(2 $enforce2w "D  ", place(w) orientation(horizontal) size(small)) ///
note("A: Mass gatherings restricted to 250 people, plus 3 weeks" ///
"B: Schools closed, plus 3 weeks" ///
"C: Mass gatherings restricted to 50 people, plus 3 weeks" ///
"D: Enforcement of mandatory publich health orders, plus 3 weeks", size(vsmall))
graph export "${output}/alberta/cumulative_cases_dd_ab.pdf", as(pdf) replace


* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Hospitalizations
* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Load data
clear
import excel "${input}/raw_data_ab.xlsx", sheet("hospitalizations") firstrow

* New hopsitalizations
twoway bar new_hospital date if new_hospital != ., ///
title("New Hospitalizations per Day") ///
ytitle("New Hospitalizations") xtitle("Date") ///
xlabel(${xstart}(7)${xend}, angle(45)) ///
xline($mass2502w) text(15 $mass2502w "A  ", place(w) orientation(horizontal) size(small)) ///
xline($schools2w) text(15 $schools2w "B  ", place(w) orientation(horizontal) size(small)) ///
xline($mass502w) text(15 $mass502w "C  ", place(w) orientation(horizontal) size(small)) ///
xline($enforce2w) text(15 $enforce2w "D  ", place(w) orientation(horizontal) size(small)) ///
note("A: Mass gatherings restricted to 250 people, plus 3 weeks" ///
"B: Schools closed, plus 3 weeks" ///
"C: Mass gatherings restricted to 50 people, plus 3 weeks" ///
"D: Enforcement of mandatory publich health orders, plus 3 weeks", size(vsmall))
//saving("${output}/new_hospital_ab.gph", replace)
graph export "${output}/alberta/new_hospitalizations_ab.pdf", as(pdf) replace

* Cumulative hopsitalizations
twoway connected cumu_hospital date if new_hospital != ., ///
title("Total Cumulative Hospitalizations") ///
ytitle("Hospitalizations") xtitle("Date") ///
xlabel(${xstart}(7)${xend}, angle(45)) ///
xline($mass2502w) text(15 $mass2502w "A  ", place(w) orientation(horizontal) size(small)) ///
xline($schools2w) text(15 $schools2w "B  ", place(w) orientation(horizontal) size(small)) ///
xline($mass502w) text(15 $mass502w "C  ", place(w) orientation(horizontal) size(small)) ///
xline($enforce2w) text(15 $enforce2w "D  ", place(w) orientation(horizontal) size(small)) ///
note("A: Mass gatherings restricted to 250 people, plus 3 weeks" ///
"B: Schools closed, plus 3 weeks" ///
"C: Mass gatherings restricted to 50 people, plus 3 weeks" ///
"D: Enforcement of mandatory publich health orders, plus 3 weeks", size(vsmall))
//saving("${output}/cumu_hospital_ab.gph", replace)
graph export "${output}/alberta/cumulative_hospitalizations_ab.pdf", as(pdf) replace

* ------------------------------------------------------------------------------
* Estimate exponential growth rate
* ------------------------------------------------------------------------------
* Generate logs
cap drop log_cumu_hospital
gen log_cumu_hospital = ln(cumu_hospital)

* Regress
reg log_cumu_hospital day_1 if new_hospital != .

* Inital value
local init_value = exp(_b[_cons])

* Growth factor
local ex_growth = exp(_b[day_1])

* Exponential growth
cap drop ex_growth
gen ex_growth = (`init_value')*((`ex_growth')^(day_1))

* Plot
twoway (connected cumu_hospital date if new_hospital != .) ///
(connected ex_growth date if new_hospital != ., lcolor(blue)), ///
title("Total Cumulative Hospitalizations vs. Best fit Exponential Growth") ///
ytitle("Hospitalizations") xtitle("Date") ///
legend(label(1 "Data") label(2 "Exponential growth") pos(6) row(1)) ///
xlabel(${xstart}(7)${xend}, angle(45)) ///
xline($mass2502w) text(25 $mass2502w "A  ", place(w) orientation(horizontal) size(small)) ///
xline($schools2w) text(25 $schools2w "B  ", place(w) orientation(horizontal) size(small)) ///
xline($mass502w) text(25 $mass502w "C  ", place(w) orientation(horizontal) size(small)) ///
xline($enforce2w) text(25 $enforce2w "D  ", place(w) orientation(horizontal) size(small)) ///
note("Exponential growth factor: `ex_growth', Initial value: `init_value'" ///
"A: Mass gatherings restricted to 250 people, plus 3 weeks" ///
"B: Schools closed, plus 3 weeks" ///
"C: Mass gatherings restricted to 50 people, plus 3 weeks" ///
"D: Enforcement of mandatory publich health orders, plus 3 weeks", size(vsmall))
graph export "${output}/alberta/cumulative_hospitalizations_exp_ab.pdf", as(pdf) replace

* ------------------------------------------------------------------------------
* Doubling
* ------------------------------------------------------------------------------
* Doubling rate for each cumulative total
foreach var of varlist cumu_hospital {
	cap drop gr_`var'
	gen gr_`var' = ((`var' - `var'[_n-5])/`var'[_n-5])*100
	cap drop dd_`var'
	gen dd_`var' = (70/gr_`var')*5
}

* Doubling days of cumulative hospitalizations
twoway connected dd_cumu_hospital date if new_hospital != ., ///
title("Doubling Time in Days of Total Cumulative Hospitalizations") ///
ytitle("Days") xtitle("Date reported to AHS") ///
xlabel(${xstart}(7)${xend}, angle(45)) ///
xline($mass2502w) text(2 $mass2502w "A  ", place(w) orientation(horizontal) size(small)) ///
xline($schools2w) text(2 $schools2w "B  ", place(w) orientation(horizontal) size(small)) ///
xline($mass502w) text(2 $mass502w "C  ", place(w) orientation(horizontal) size(small)) ///
xline($enforce2w) text(2 $enforce2w "D  ", place(w) orientation(horizontal) size(small)) ///
note("A: Mass gatherings restricted to 250 people, plus 3 weeks" ///
"B: Schools closed, plus 3 weeks" ///
"C: Mass gatherings restricted to 50 people, plus 3 weeks" ///
"D: Enforcement of mandatory publich health orders, plus 3 weeks", size(vsmall))
graph export "${output}/alberta/cumulative_hospital_dd_ab.pdf", as(pdf) replace


* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* ICU admissions
* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Load data
clear
import excel "${input}/raw_data_ab.xlsx", sheet("icu") firstrow

* New ICU admissions
twoway bar new_icu date if new_icu != ., ///
title("New ICU Admissions per Day") ///
ytitle("New ICU Admissions") xtitle("Date") ///
xlabel(${xstart}(7)${xend}, angle(45)) ///
xline($mass2502w) text(5 $mass2502w "A  ", place(w) orientation(horizontal) size(small)) ///
xline($schools2w) text(5 $schools2w "B  ", place(w) orientation(horizontal) size(small)) ///
xline($mass502w) text(5 $mass502w "  C", place(e) orientation(horizontal) size(small)) ///
xline($enforce2w) text(5 $enforce2w "D  ", place(w) orientation(horizontal) size(small)) ///
note("A: Mass gatherings restricted to 250 people, plus 3 weeks" ///
"B: Schools closed, plus 3 weeks" ///
"C: Mass gatherings restricted to 50 people, plus 3 weeks" ///
"D: Enforcement of mandatory publich health orders, plus 3 weeks", size(vsmall))
//saving("${output}/new_icu_ab.gph", replace)
graph export "${output}/alberta/new_icu_ab.pdf", as(pdf) replace

* Cumulative ICU admissions
twoway connected cumu_icu date if new_icu != ., ///
title("Total Cumulative ICU Admissions") ///
ytitle("ICU Admissions") xtitle("Date") ///
xlabel(${xstart}(7)${xend}, angle(45)) ///
xline($mass2502w) text(2 $mass2502w "A  ", place(w) orientation(horizontal) size(small)) ///
xline($schools2w) text(2 $schools2w "B  ", place(w) orientation(horizontal) size(small)) ///
xline($mass502w) text(2 $mass502w "C  ", place(w) orientation(horizontal) size(small)) ///
xline($enforce2w) text(2 $enforce2w "D  ", place(w) orientation(horizontal) size(small)) ///
note("A: Mass gatherings restricted to 250 people, plus 3 weeks" ///
"B: Schools closed, plus 3 weeks" ///
"C: Mass gatherings restricted to 50 people, plus 3 weeks" ///
"D: Enforcement of mandatory publich health orders, plus 3 weeks", size(vsmall))
//saving("${output}/cumu_icu_ab.gph", replace)
graph export "${output}/alberta/cumulative_icu_ab.pdf", as(pdf) replace

* ------------------------------------------------------------------------------
* Estimate exponential growth rate
* ------------------------------------------------------------------------------
* Generate logs
cap drop log_cumu_icu
gen log_cumu_icu = ln(cumu_icu)

* Regress
reg log_cumu_icu day_1 if new_icu != .

* Inital value
local init_value = exp(_b[_cons])

* Growth factor
local ex_growth = exp(_b[day_1])

* Exponential growth
cap drop ex_growth
gen ex_growth = (`init_value')*((`ex_growth')^(day_1))

* Plot
twoway (connected cumu_icu date if new_icu != .) ///
(connected ex_growth date if new_icu != ., lcolor(blue)), ///
title("Total Cumulative ICU Admissions vs. Best fit Exponential Growth") ///
ytitle("ICU Admissions") xtitle("Date") ///
legend(label(1 "Data") label(2 "Exponential growth") pos(6) row(1)) ///
xlabel(${xstart}(7)${xend}, angle(45)) ///
xline($mass2502w) text(10 $mass2502w "A  ", place(w) orientation(horizontal) size(small)) ///
xline($schools2w) text(10 $schools2w "B  ", place(w) orientation(horizontal) size(small)) ///
xline($mass502w) text(10 $mass502w "C  ", place(w) orientation(horizontal) size(small)) ///
xline($enforce2w) text(10 $enforce2w "D  ", place(w) orientation(horizontal) size(small)) ///
note("Exponential growth factor: `ex_growth', Initial value: `init_value'" ///
"A: Mass gatherings restricted to 250 people, plus 3 weeks" ///
"B: Schools closed, plus 3 weeks" ///
"C: Mass gatherings restricted to 50 people, plus 3 weeks" ///
"D: Enforcement of mandatory publich health orders, plus 3 weeks", size(vsmall))
graph export "${output}/alberta/cumulative_icu_exp_ab.pdf", as(pdf) replace

* ------------------------------------------------------------------------------
* Doubling
* ------------------------------------------------------------------------------
* Doubling rate for each cumulative total
foreach var of varlist cumu_icu {
	cap drop gr_`var'
	gen gr_`var' = ((`var' - `var'[_n-5])/`var'[_n-5])*100
	cap drop dd_`var'
	gen dd_`var' = (70/gr_`var')*5
}

* Doubling days of total cumulative icu admissions
twoway connected dd_cumu_icu date if new_icu != ., ///
title("Doubling Time in Days of Total Cumulative ICU Admissions") ///
ytitle("Days") xtitle("Date reported to AHS") ///
xlabel(${xstart}(7)${xend}, angle(45)) ///
xline($mass2502w) text(2 $mass2502w "A  ", place(w) orientation(horizontal) size(small)) ///
xline($schools2w) text(2 $schools2w "B  ", place(w) orientation(horizontal) size(small)) ///
xline($mass502w) text(2 $mass502w "C  ", place(w) orientation(horizontal) size(small)) ///
xline($enforce2w) text(2 $enforce2w "D  ", place(w) orientation(horizontal) size(small)) ///
note("A: Mass gatherings restricted to 250 people, plus 3 weeks" ///
"B: Schools closed, plus 3 weeks" ///
"C: Mass gatherings restricted to 50 people, plus 3 weeks" ///
"D: Enforcement of mandatory publich health orders, plus 3 weeks", size(vsmall))
graph export "${output}/alberta/cumulative_icu_dd_ab.pdf", as(pdf) replace


* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Deaths
* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Load data
clear
import excel "${input}/raw_data_ab.xlsx", sheet("deaths") firstrow

* Cumulative deaths
twoway connected cumu_deaths date if new_deaths != ., ///
title("Total Cumulative Deaths") ///
ytitle("Deaths") xtitle("Date") ///
xlabel(${xstart}(7)${xend}, angle(45)) ///
xline($mass2502w) text(2 $mass2502w "A  ", place(w) orientation(horizontal) size(small)) ///
xline($schools2w) text(2 $schools2w "B  ", place(w) orientation(horizontal) size(small)) ///
xline($mass502w) text(2 $mass502w "C  ", place(w) orientation(horizontal) size(small)) ///
xline($enforce2w) text(2 $enforce2w "D  ", place(w) orientation(horizontal) size(small)) ///
note("A: Mass gatherings restricted to 250 people, plus 3 weeks" ///
"B: Schools closed, plus 3 weeks" ///
"C: Mass gatherings restricted to 50 people, plus 3 weeks" ///
"D: Enforcement of mandatory publich health orders, plus 3 weeks", size(vsmall))
//saving("${output}/cumu_deaths_ab.gph", replace)
graph export "${output}/alberta/cumulative_deaths_ab.pdf", as(pdf) replace

* ------------------------------------------------------------------------------
* Estimate exponential growth rate
* ------------------------------------------------------------------------------
* Generate logs
cap drop log_cumu_deaths
gen log_cumu_deaths = ln(cumu_deaths)

* Regress
reg log_cumu_deaths day_1 if new_deaths != .

* Inital value
local init_value = exp(_b[_cons])

* Growth factor
local ex_growth = exp(_b[day_1])

* Exponential growth
cap drop ex_growth
gen ex_growth = (`init_value')*((`ex_growth')^(day_1))

* Plot
twoway (connected cumu_deaths date if new_deaths != .) ///
(connected ex_growth date if new_deaths != ., lcolor(blue)), ///
title("Total Cumulative Deaths vs. Best fit Exponential Growth") ///
ytitle("Deaths") xtitle("Date") ///
legend(label(1 "Data") label(2 "Exponential growth") pos(6) row(1)) ///
xlabel(${xstart}(7)${xend}, angle(45)) ///
xline($mass2502w) text(5 $mass2502w "A  ", place(w) orientation(horizontal) size(small)) ///
xline($schools2w) text(5 $schools2w "B  ", place(w) orientation(horizontal) size(small)) ///
xline($mass502w) text(5 $mass502w "C  ", place(w) orientation(horizontal) size(small)) ///
xline($enforce2w) text(5 $enforce2w "D  ", place(w) orientation(horizontal) size(small)) ///
note("Exponential growth factor: `ex_growth', Initial value: `init_value'" ///
"A: Mass gatherings restricted to 250 people, plus 3 weeks" ///
"B: Schools closed, plus 3 weeks" ///
"C: Mass gatherings restricted to 50 people, plus 3 weeks" ///
"D: Enforcement of mandatory publich health orders, plus 3 weeks", size(vsmall))
graph export "${output}/alberta/cumulative_deaths_exp_ab.pdf", as(pdf) replace

* ------------------------------------------------------------------------------
* Doubling
* ------------------------------------------------------------------------------
* Doubling rate for each cumulative total
foreach var of varlist cumu_deaths {
	cap drop gr_`var'
	gen gr_`var' = ((`var' - `var'[_n-5])/`var'[_n-5])*100
	cap drop dd_`var'
	gen dd_`var' = (70/gr_`var')*5
}

* Doubling days of total cumulative deaths
twoway connected dd_cumu_deaths date if new_deaths != ., ///
title("Doubling Time in Days of Total Cumulative Deaths") ///
ytitle("Days") xtitle("Date reported to AHS") ///
xlabel(${xstart}(7)${xend}, angle(45)) ///
xline($mass2502w) text(8 $mass2502w "A  ", place(w) orientation(horizontal) size(small)) ///
xline($schools2w) text(8 $schools2w "B  ", place(w) orientation(horizontal) size(small)) ///
xline($mass502w) text(8 $mass502w "C  ", place(w) orientation(horizontal) size(small)) ///
xline($enforce2w) text(8 $enforce2w "D  ", place(w) orientation(horizontal) size(small)) ///
note("A: Mass gatherings restricted to 250 people, plus 3 weeks" ///
"B: Schools closed, plus 3 weeks" ///
"C: Mass gatherings restricted to 50 people, plus 3 weeks" ///
"D: Enforcement of mandatory publich health orders, plus 3 weeks", size(vsmall))
graph export "${output}/alberta/cumulative_deaths_dd_ab.pdf", as(pdf) replace









