################################################################################
# COVID-19 GRAPHER
#
# This code should
# -- Download the latest data from ECDC
# -- Creates graphs about the development in countries of choice regarding
#    - Number of cases since 100 cases
#    - Number of deaths since 10 deaths
#
# Author: Viking Waldén
#
# NB: If the ECDC hasn't updated their data today, the code download won't work.
#     It's then easiest to manually download the data and run it from there.
#
################################################################################

#-------------------------------------------------------------------------------
# PREAMBLE
#-------------------------------------------------------------------------------

rm(list = ls())

# Needed packages
packages <- c("rio",
              "data.table",
              "httr",
              "readxl",
              "tidyverse")

# Install new and load all packages
install_load <- function(x) {
  if (!require(x, character.only = TRUE)) {
    install.packages(x, dependencies = TRUE)
    library(x, character.only = TRUE)
  }
}

lapply(packages, install_load)

#-------------------------------------------------------------------------------
# AUTOMATIC DOWNLOAD
#-------------------------------------------------------------------------------

# # URL with daily aupdate
# url <- paste("https://www.ecdc.europa.eu/sites/default/files/documents/COVID-19-geographic-disbtribution-worldwide-",format(Sys.time(), "%Y-%m-%d"), ".xlsx", sep = "")
#
# # Download data to local temp file
# GET(url, authenticate(":", ":", type="ntlm"), write_disk(tf <- tempfile(fileext = ".xlsx")))
#
# # Import data
# data <- read_excel(tf)  %>%
#   arrange(GeoId, DateRep)

#-------------------------------------------------------------------------------
# MANUAL DOWNLOAD
#-------------------------------------------------------------------------------

data <- import("C:/Users/vi.3590/Desktop/Corona/data.xlsx")  %>%
        arrange(GeoId, DateRep)

#-------------------------------------------------------------------------------
# DEATH AND CASE DATASETS
#-------------------------------------------------------------------------------

# Create cumulative cases and deaths
dt <- data.table(data)
dt[, tot_cases := cumsum(Cases), by = list(GeoId)]
dt[, tot_deaths := cumsum(Deaths), by = list(GeoId)]

# Select countries
dt  <- dt %>%
  filter(GeoId == "SE" | GeoId == "NO" | GeoId == "DK" | GeoId == "FI" | GeoId == "IT")

# Death dataset
deaths <- dt %>%
  filter(tot_deaths >= 10)  %>%
  data.table

# Generate days since 10 dead
deaths[, days_since_10_dead := seq(1:.N), by = list(GeoId)]

# Cases dataset
cases <- dt %>%
  filter(tot_cases >= 100)  %>%
  data.table

# Generate days since 100 cases
cases[, days_since_100_cases := seq(1:.N), by = list(GeoId)]

#-------------------------------------------------------------------------------
# GRAPHS
#-------------------------------------------------------------------------------

# Cases
## Total
cases %>%
  filter(days_since_100_cases <= 20)  %>%
  ggplot(aes(x = days_since_100_cases, y = tot_cases, colour = GeoId)) +
    geom_line() + scale_y_continuous(name = "Total cases", trans = "log10") +
    scale_x_continuous(name = "Days since 100 cases") +
    ggtitle("Total Covid-19 cases") +
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
    panel.background = element_blank(), axis.line = element_line(colour = "black"))

## Per day
cases %>%
  filter(days_since_100_cases <= 20)  %>%
  ggplot(aes(x = days_since_100_cases, y = Cases, colour = GeoId)) +
    geom_line() + scale_y_continuous(name = "Total cases", trans = "log10") +
    scale_x_continuous(name = "Days since 100 cases") +
    ggtitle("New Covid-19 cases per day") +
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
    panel.background = element_blank(), axis.line = element_line(colour = "black"))

# Deaths
## Total
deaths %>%
  filter(days_since_10_dead <= 14) %>%
  ggplot(aes(x = days_since_10_dead, y = tot_deaths, colour = GeoId)) +
    geom_line() + scale_y_continuous(name = "Total deaths", trans = "log10") +
    scale_x_continuous(name = "Days since 10 deaths") +
    ggtitle("Total Covid-19 deaths") +
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
    panel.background = element_blank(), axis.line = element_line(colour = "black"))

## Per day
deaths %>%
  filter(days_since_10_dead <= 14) %>%
  ggplot(aes(x = days_since_10_dead, y = Deaths, colour = GeoId)) +
    geom_line() + scale_y_continuous(name = "Total deaths", trans = "log10") +
    scale_x_continuous(name = "Days since 10 deaths") +
    ggtitle("New Covid-19 deaths") +
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
    panel.background = element_blank(), axis.line = element_line(colour = "black"))
