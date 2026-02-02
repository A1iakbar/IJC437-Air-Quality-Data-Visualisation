# ============================================================
# IJC445 Data Visualisation (Coursework)
# Script: 02_data_preparation.R
#
# Purpose:
# - Load the merged daily PM2.5 + weather dataset (London)
# - Perform lightweight cleaning + QA checks
# - Create derived variables for visualisation (rolling metrics, thresholds,
#   seasons, extremes, and weather categories/bins)
# - Save an analysis-ready dataset for 03_visualisations.R
#
# Inputs:
# - data/merged_pm25_weather.csv   (created by 01_fetch_openmeteo_weather.R)
#
# Outputs:
# - data/processed/pm25_weather_viz_ready.csv
#
# Notes:
# - PM2.5 is the primary signal; weather variables provide context.
# ============================================================

# -------------------------------
# Libraries
# -------------------------------
library(dplyr)
library(readr)
library(lubridate)

# Optional Packages for Rolling Calculations
has_zoo    <- requireNamespace("zoo", quietly = TRUE)
has_slider <- requireNamespace("slider", quietly = TRUE)


dir.create("data/processed", recursive = TRUE, showWarnings = FALSE)

# -------------------------------
# Loading Data
# -------------------------------
df <- readr::read_csv("data/merged_pm25_weather.csv", show_col_types = FALSE)


# Standardising Date + Sort
df <- df %>%
  mutate(date = as.Date(date)) %>%
  arrange(date)


# -------------------------------
# Adding Calendar Features
# -------------------------------
df <- df %>%
  mutate(
    year       = year(date),
    month      = month(date),
    month_name = month(date, label = TRUE, abbr = TRUE),
    week       = isoweek(date),
    dow        = wday(date, label = TRUE, abbr = TRUE),

    # Meteorological Seasons
    season = case_when(
      month %in% c(12,  1,  2) ~ "Winter",
      month %in% c(3,  4,  5)  ~ "Spring",
      month %in% c(6,  7,  8)  ~ "Summer",
      month %in% c(9, 10, 11)  ~ "Autumn",
      TRUE ~ NA_character_
    ),
    season = factor(season, levels = c("Winter", "Spring", "Summer", "Autumn"))
  )

# -------------------------------
# PM2.5 Derived Variables
# -------------------------------

# WHO 2021 24-hour guideline for PM2.5: 15 µg/m³
WHO_PM25_24H <- 15

df <- df %>%
  mutate(
    pm25_above_who = if_else(!is.na(pm25_london_mean) & pm25_london_mean > WHO_PM25_24H, 1L, 0L)
  )

# Rolling metrics (30-day window)
# Computing on the City-Level PM2.5 Time Series Only.
if (has_zoo) {
  df <- df %>%
    mutate(
      pm25_roll30    = zoo::rollmean(pm25_london_mean, k = 30, fill = NA, align = "right"),
      pm25_roll30_sd = zoo::rollapply(pm25_london_mean, width = 30, FUN = sd, fill = NA, align = "right", na.rm = TRUE)
    )
} else if (has_slider) {
  df <- df %>%
    mutate(
      pm25_roll30    = slider::slide_dbl(pm25_london_mean, mean, .before = 29, .complete = TRUE, na.rm = TRUE),
      pm25_roll30_sd = slider::slide_dbl(pm25_london_mean, sd,   .before = 29, .complete = TRUE, na.rm = TRUE)
    )
} else {
  # Fallback if needed
  df <- df %>%
    mutate(
      pm25_roll30 = sapply(seq_along(pm25_london_mean), function(i) {
        if (i < 30) return(NA_real_)
        mean(pm25[(i - 29):i], na.rm = TRUE)
      }),
      pm25_roll30_sd = sapply(seq_along(pm25_london_mean), function(i) {
        if (i < 30) return(NA_real_)
        sd(pm25[(i - 29):i], na.rm = TRUE)
      })
    )
}

# Extreme Pollution Days (top 5% of available PM2.5 days)
pm25_p95 <- as.numeric(quantile(df$pm25_london_mean, probs = 0.95, na.rm = TRUE))

df <- df %>%
  mutate(
    pm25_extreme = if_else(!is.na(pm25_london_mean) & pm25_london_mean >= pm25_p95, 1L, 0L)
  )

# -------------------------------
# Weather-Derived Variables
# -------------------------------

# Rain flag
df <- df %>%
  mutate(
    rain_flag = case_when(
      is.na(prcp_sum_mm) ~ NA_character_,
      prcp_sum_mm > 0    ~ "Rainy",
      TRUE               ~ "Dry"
    ),
    rain_flag = factor(rain_flag, levels = c("Dry", "Rainy"))
  )


# Temperature Bins (Terciles)
temp_q <- quantile(df$temp_mean_c, probs = c(1/3, 2/3), na.rm = TRUE)

df <- df %>%
  mutate(
    temp_bin = case_when(
      is.na(temp_mean_c)           ~ NA_character_,
      temp_mean_c <= temp_q[1]     ~ "Cool",
      temp_mean_c <= temp_q[2]     ~ "Mild",
      TRUE                         ~ "Warm"
    ),
    temp_bin = factor(temp_bin, levels = c("Cool", "Mild", "Warm"))
  )


# Wind Bins (Median Split)
wind_med <- median(df$wind_mean_kmh, na.rm = TRUE)

df <- df %>%
  mutate(
    wind_bin = case_when(
      is.na(wind_mean_kmh)       ~ NA_character_,
      wind_mean_kmh <= wind_med  ~ "Calm",
      TRUE                      ~ "Windy"
    ),
    wind_bin = factor(wind_bin, levels = c("Calm", "Windy"))
  )


# Humidity Bins (Median Split)
hum_med <- median(df$humidity, na.rm = TRUE)

df <- df %>%
  mutate(
    humidity_bin = case_when(
      is.na(humidity)      ~ NA_character_,
      humidity <= hum_med  ~ "Low humidity",
      TRUE                 ~ "High humidity"
    ),
    humidity_bin = factor(humidity_bin, levels = c("Low humidity", "High humidity"))
  )

# -------------------------------
# Lightweight QA Summary
# -------------------------------
qa <- df %>%
  summarise(
    n_days_total = n(),
    date_min     = min(date, na.rm = TRUE),
    date_max     = max(date, na.rm = TRUE),

    n_pm25_nonNA = sum(!is.na(pm25_london_mean)),
    pm25_mean    = mean(pm25_london_mean, na.rm = TRUE),
    pm25_sd      = sd(pm25_london_mean, na.rm = TRUE),
    pm25_p95_used_for_extremes = pm25_p95,

    n_complete_core = sum(complete.cases(pm25_london_mean)),
    n_complete_all  = sum(complete.cases(across(any_of(c("pm25_london_mean","temp_mean_c","wind_mean_kmh","prcp_sum_mm","humidity"))))),

    median_active_sensors = if ("n_sensors" %in% names(df)) median(n_sensors, na.rm = TRUE) else NA_real_
  )

print(qa)

# Selecting Only NEcessary Columns
df <- df %>%
  select(-matches("^pm25_[0-9]+$"))

# -------------------------------
# Saving Analysis-Ready Dataset
# -------------------------------
readr::write_csv(df, "data/processed/pm25_weather_viz_ready.csv")
