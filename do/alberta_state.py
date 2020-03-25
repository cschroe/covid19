# Import libraries
import pandas as pd
import numpy as np
import matplotlib.pyploy as plt
import epipylib.model as epipylib



#Read in data
data = pd.read_excel("input/raw_data_alberta.xlsx")


# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Cases
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# New cases




twoway bar new_cases_total date if new_cases_total != ., ///
ytitle("New Cases") xtitle("Date") ///
xlabel(${xstart}(7)${xend}, angle(45))


* Cummulative cases
twoway connected cumu_cases_total date if new_cases_total != ., ///
ytitle("Total Cummulative Cases") xtitle("Date") ///
xlabel(${xstart}(7)${xend}, angle(45))


* Cummulative cases by source of infection
twoway (connected cumu_cases_travel date if new_cases_total != .) ///
(connected cumu_cases_closecont date if new_cases_total != .) ///
(connected cumu_cases_comm date if new_cases_total != .), ///
ytitle("Cummulative Cases") xtitle("Date") ///
xlabel(${xstart}(7)${xend}, angle(45)) ///
legend(label(1 "Travel") label(2 "Close Contact of Traveler") label(3 "Community Transmission") pos(6) row(1))


* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Hospitalizations
* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* ------------------------------------------------------------------------------
* Total hospitalizations
* ------------------------------------------------------------------------------
* New hopsitalizations
twoway bar new_hospital date if new_cases_total != ., ///
ytitle("New Hospitalizations") xtitle("Date") ///
xlabel(${xstart}(7)${xend}, angle(45))


* Current hopsitalizations
twoway connected current_hospital date if new_cases_total != ., ///
ytitle("Current Hospitalizations") xtitle("Date") ///
xlabel(${xstart}(7)${xend}, angle(45))


* Cummulative hopsitalizations
twoway connected cumu_hospital date if new_cases_total != ., ///
ytitle("Cummulative Hospitalizations") xtitle("Date") ///
xlabel(${xstart}(7)${xend}, angle(45))


* ------------------------------------------------------------------------------
* ICU admissions
* ------------------------------------------------------------------------------
* New ICU admissions
twoway bar new_icu date if new_cases_total != ., ///
ytitle("New ICU Admissions") xtitle("Date") ///
xlabel(${xstart}(7)${xend}, angle(45))

* Current hopsitalizations
twoway connected current_icu date if new_cases_total != ., ///
ytitle("Current Hospitalized in ICU") xtitle("Date") ///
xlabel(${xstart}(7)${xend}, angle(45))

* Cummulative ICU admissions
twoway connected cumu_icu date if new_cases_total != ., ///
ytitle("Cummulative ICU Admissions") xtitle("Date") ///
xlabel(${xstart}(7)${xend}, angle(45))

