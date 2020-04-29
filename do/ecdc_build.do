* ecdc_build.do


* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Import and Prepare Data
* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
import excel "${input}/COVID-19-geographic-disbtribution-worldwide-2020-04-28.xlsx", firstrow
drop day month year geoId
rename countriesAndTerritories country
rename countryterritoryCode country_code

sort country dateRep

* Cumulative cases in country on reporting day
cap drop cumu_cases
gen cumu_cases = 0
by country: replace cumu_cases = cumu_cases[_n-1] + cases if _n != 1

drop if cumu_cases == 0

* Cumulative deaths in country on reporting day
cap drop cumu_deaths
gen cumu_deaths = 0
by country: replace cumu_deaths = cumu_deaths[_n-1] + deaths if _n != 1

* Days since 1,50,100 case in country
sort country dateRep
cap drop day_1
gen day_1 = _n
replace day_1 = day_1 - 1

cap drop day_50
gen day_50 = 1 if cumu_cases > 50
sort country dateRep
by country: replace day_50 = 0 if day_50[_n-1] != .
by country: replace day_50 = day_50[_n-1] + 1 if day_50[_n-1] != .
replace day_50 = day_50 - 1

cap drop day_100
gen day_100 = 1 if cumu_cases > 100
sort country dateRep
by country: replace day_100 = 0 if day_100[_n-1] != .
by country: replace day_100 = day_100[_n-1] + 1 if day_100[_n-1] != .
replace day_100 = day_100 - 1

* Per capita counts
foreach var of varlist cumu_cases cumu_deaths {
		cap drop `var'_100k
		gen `var'_100k = (`var'/popData2018)*100000
}

save "${temp}/ecdc_temp.dta", replace
