* canada.do

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
* Population (Q1 2020 - Table 17-10-0009-01, Statistics Canada)
global abpop = 4413146
global ab100k = $abpop / 100000

global bcpop = 5110917
global bc100k = $bcpop / 100000

global manpop = 1377517
global man100k = $manpop / 100000

global nbpop = 779993
global nb100k = $nbpop / 100000

global nlpop = 521365
global nl100k = $nlpop / 100000

global nwtpop = 44904
global nwt100k = $nwtpop / 100000

global nspop = 977457
global ns100k = $nspop / 100000

global ontpop = 14711827
global ont100k = $ontpop / 100000

global peipop = 158158
global pei100k = $peipop / 100000

global pqpop = 8537674
global pq100k = $pqpop / 100000

global saskpop = 1181666
global sask100k = $saskpop / 100000

global yukpop = 41078
global yuk100k = $yukpop / 100000


* Measures implemented in Canada

/*
foreach date in mass250 schools mass50 enforce {
	global `date'2w = $`date' + 14
}
*/

* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Load and prepare data
* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
clear
import excel "${input}/Public_COVID-19_Canada.xlsx", sheet("Cases")
drop if _n<4
drop P-AA
drop if A == ""

* Rename variables
foreach var of varlist _all {
	global test = `var'[_n==1]
	rename `var' $test
}
drop if _n==1

drop case_source additional_info additional_source

* Reformat variables
destring case_id provincial_case_id, replace

foreach var of varlist date_report report_week {
	rename `var' temp 
	gen `var' = date(temp, "DMY")
	format `var' %td
	drop temp
}

* New cases in province on reporting day
cap drop temp
gen temp = 1
cap drop new_cases
bysort province date_report: egen new_cases = total(temp)

* Cumulative cases in province on reporting day
cap drop cumu_cases
bysort province date_report: egen cumu_cases = max(provincial_case_id)

* Days since 1,50,100 case in province
cap drop temp
bysort province date_report: gen temp = _n==1

cap drop day_1
bysort province: gen day_1 = _n==1
sort province date_report
replace day_1 = day_1[_n-1] + temp if day_1 == 0
replace day_1 = day_1 - 1

cap drop temp2
gen temp2 = temp if cumu_cases > 50
sort province date_report
cap drop day_50
gen day_50 = temp2
replace day_50 = 0 if temp2 == 1 & temp2[_n-1] != .
replace day_50 = day_50[_n-1] + temp2 if day_50 == 0
replace day_50 = day_50 - 1

cap drop temp3
gen temp3 = temp if cumu_cases > 100
sort province date_report
cap drop day_100
gen day_100 = temp3
replace day_100 = 0 if temp3 == 1 & temp3[_n-1] != .
replace day_100 = day_100[_n-1] + temp3 if day_100 == 0
replace day_100 = day_100 - 1

drop temp*

* Per capita counts
cap drop new_cases_100k
gen new_cases_100k = .
cap drop cumu_cases_100k
gen cumu_cases_100k = .

foreach var of varlist new_cases cumu_cases {
	replace `var'_100k = `var' / $ab100k if province == "Alberta"
	replace `var'_100k = `var' / $bc100k if province == "BC"
	replace `var'_100k = `var' / $man100k if province == "Manitoba"
	replace `var'_100k = `var' / $nl100k if province == "NL"
	replace `var'_100k = `var' / $nwt100k if province == "NWT"
	replace `var'_100k = `var' / $nb100k if province == "New Brunswick"
	replace `var'_100k = `var' / $ns100k if province == "Nova Scotia"
	replace `var'_100k = `var' / $ont100k if province == "Ontario"
	replace `var'_100k = `var' / $pei100k if province == "PEI"
	replace `var'_100k = `var' / $pq100k if province == "Quebec"
	replace `var'_100k = `var' / $sask100k if province == "Saskatchewan"
	replace `var'_100k = `var' / $yuk100k if province == "Yukon"
}

save "${temp}/can_temp.dta", replace


* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Cumulative cases across provinces
* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
use "${temp}/can_temp.dta", clear

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
graph export "${output}/can_provinces.pdf", as(pdf) replace







