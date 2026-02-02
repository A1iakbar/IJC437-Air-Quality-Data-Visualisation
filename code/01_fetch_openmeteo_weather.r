# ============================================================
# IJC445 Data Visualisation (Coursework)
# Script: 01_fetch_openmeteo_weather.R
#
# Purpose:
# - Read the daily PM2.5 dataset to determine the temporal coverage (start and end dates).
# - Query the Open-Meteo Archive API for daily weather variables/
#   /(including humidity, which was not used in the introduction to data science coursework).
# - Save the raw weather dataset and a merged PM2.5 + weather dataset for downstream use.
#
# Inputs:
# - data/primary_pm25_daily_london.csv
#
# Outputs:
# - data/openmeteo_daily_london.csv
# - data/merged_pm25_weather.csv
#
# Notes:
# - This script handles data acquisition + merging only.
# - Feature engineering (rolling means, bins, thresholds) is done in 01_data_preparation.R
# ============================================================

# -------------------------------
# Libraries
# -------------------------------
library(dplyr)
library(readr)
library(lubridate)
library(httr)
library(jsonlite)
library(tibble)



# Creating output directory if needed
dir.create("data", recursive = TRUE, showWarnings = FALSE)

# -------------------------------
# Loading PM2.5 Data to Get Date Range
# -------------------------------
pm25 <- readr::read_csv("data/primary_pm25_daily_london.csv", show_col_types = FALSE) %>%
  mutate(date = as.Date(date)) %>%
  arrange(date)

# Defining Start and End Date
start_date <- min(pm25$date, na.rm = TRUE)
end_date   <- max(pm25$date, na.rm = TRUE)

if (is.na(start_date) || is.na(end_date)) {
  stop("start_date/end_date could not be computed (NA).")
}


# -------------------------------
# Query Open-Meteo Archive API
# -------------------------------

# Central London Coordinates
LAT <- 51.5074
LON <- -0.1278

# Daily Variables Requested from Open-Meteo
DAILY_VARS <- c(
  "temperature_2m_mean",
  "wind_speed_10m_mean",
  "precipitation_sum",
  "relative_humidity_2m_mean"
)

OPEN_METEO_URL <- "https://archive-api.open-meteo.com/v1/archive"

query <- list(
  latitude   = LAT,
  longitude  = LON,
  start_date = as.character(start_date),
  end_date   = as.character(end_date),
  daily      = paste(DAILY_VARS, collapse = ","),
  timezone   = "Europe/London"
)

res <- httr::GET(OPEN_METEO_URL, query = query)
txt <- httr::content(res, "text", encoding = "UTF-8")

# Fail Message If the Request Fails
if (httr::http_error(res)) {
  stop(
    "Open-Meteo request failed. HTTP ", httr::status_code(res),
    "\nResponse (first 500 chars): ", substr(txt, 1, 500)
  )
}

weather_json <- jsonlite::fromJSON(txt, flatten = TRUE)

# -------------------------------
# Building a Tidy Daily Weather Dataframe
# -------------------------------
weather_daily <- tibble(
  date        = as.Date(weather_json$daily$time),
  temp_mean_c = weather_json$daily$temperature_2m_mean,
  wind_mean_kmh= weather_json$daily$wind_speed_10m_mean,
  prcp_sum_mm = weather_json$daily$precipitation_sum,
  humidity    = weather_json$daily$relative_humidity_2m_mean
) %>%
  arrange(date)

# Saving the Raw Weather Dataset 
readr::write_csv(weather_daily, "data/openmeteo_daily_london.csv")

# -------------------------------
# Merging PM2.5 with Weather (by date)
# -------------------------------
merged <- pm25 %>%
  left_join(weather_daily, by = "date") %>%
  arrange(date)

# Checking Missing Values for the Merge Dataset
missing_weather_days <- merged %>%
  summarise(
    n = n(),
    missing_temp = sum(is.na(temp_mean_c)),
    missing_wind = sum(is.na(wind_mean_kmh)),
    missing_prcp = sum(is.na(prcp_sum_mm)),
    missing_hum  = sum(is.na(humidity))
  )

print(missing_weather_days)


# Saving Merged Dataset for the Rest of the Coursework Pipeline
readr::write_csv(merged, "data/merged_pm25_weather.csv")
