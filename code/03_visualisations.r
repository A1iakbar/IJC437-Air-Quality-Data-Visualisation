# ============================================================
# IJC445 Data Visualisation (Coursework)
# Script: 03_visualisations.R
#
# Purpose:
# - Load the analysis-ready dataset produced by 02_data_preparation.R
# - Generate the 4 core figures for the composite visualisation
# - Save each figure as a high-resolution PNG
# - Save a single composite layout (4 charts on one page)
#
# Input:
# - data/processed/pm25_weather_viz_ready.csv
#
# Output:
# - Fig1_timeseries_raw_vs_roll30.png
# - Fig2_yearly_stacked_who_days.png
# - Fig3_boxplots_weather_conditions.png
# - Fig4_season_year_heatmap_mean.png
# - Composite_4charts.png
#
# ============================================================

# -------------------------------
# Libraries
# -------------------------------
library(dplyr)
library(readr)
library(ggplot2)
library(lubridate)
library(tidyr)
library(patchwork)
library(grid)

# Creating Output Directory for Figures
FIG_DIR <- "output/figures"
dir.create(FIG_DIR, recursive = TRUE, showWarnings = FALSE)

# -------------------------------
# Loading Data
# -------------------------------
df <- readr::read_csv("data/processed/pm25_weather_viz_ready.csv", show_col_types = FALSE) %>%
  mutate(date = as.Date(date)) %>%
  arrange(date)

# -------------------------------
# Defining Global Theme
# -------------------------------
base_theme <- theme_minimal(base_size = 12) +
  theme(
    panel.border = element_rect(colour = "black", fill = NA, linewidth = 0.8),
    plot.title.position = "plot",
    plot.title = element_text(face = "bold"),
    axis.title = element_text(face = "bold"),
    panel.grid.minor = element_blank(),
    legend.position = "bottom",
    legend.title = element_text(face = "bold"),
  )


# ============================================================
# FIGURE 1: Time series (raw PM2.5 vs 30-day rolling mean)
# ============================================================

# Plotting the Graph
fig1 <- ggplot(df, aes(x = date)) +
  geom_line(
    aes(y = pm25_london_mean, colour = "Daily mean"),
    linewidth = 0.35, alpha = 0.55
  ) +
  geom_line(
    aes(y = pm25_roll30, colour = "30-day rolling mean"),
    linewidth = 1.0
  ) +
  scale_colour_manual(
    values = c(
      "Daily mean" = "black",
      "30-day rolling mean" = "#d97706"
    ),
    name = NULL
  ) +
  labs(
    title = "Daily PM2.5 in London (raw vs 30-day rolling mean)",
    x = "Date",
    y = expression("PM2.5 ("*mu*"g/m"^3*")")
  ) +
  guides(colour = guide_legend(override.aes = list(alpha = 1, linewidth = c(0.8, 1.2)))) +
  base_theme

# Saving the Figure
ggsave(
  filename = file.path(FIG_DIR, "Fig1_timeseries_raw_vs_roll30.png"),
  plot = fig1,
  width = 10, height = 4.5, dpi = 300
)


# ============================================================
# FIGURE 2: Distribution + WHO Guideline
# ============================================================

# Computing Yearly Share of Days Above vs Below the WHO 24-hour PM2.5 Guideline
df_yearly <- df %>%
  filter(!is.na(year), !is.na(pm25_above_who)) %>%
  mutate(
    who_flag = if_else(pm25_above_who == 1, "Above WHO", "Below WHO")
  ) %>%
  count(year, who_flag, name = "n_days") %>%
  group_by(year) %>%
  mutate(
    pct = 100 * n_days / sum(n_days)
  ) %>%
  ungroup() %>%
  mutate(
    who_flag = factor(who_flag, levels = c("Below WHO", "Above WHO"))
  )

# Plotting the Graph
fig2 <- ggplot(df_yearly, aes(x = factor(year), y = pct, fill = who_flag)) +
  geom_col(width = 0.85, colour = "black", linewidth = 0.2) +
  geom_text(
    aes(label = paste0(round(pct), "%")),
    position = position_stack(vjust = 0.5),
    size = 3.2,
    colour = "#000000",
    fontface = "bold"
  ) +
  scale_fill_manual(
    values = c(
      "Below WHO" = "#D9D9D9",
      "Above WHO" = "#E67C02"
    ),
    name = "WHO status:"
  ) +
  scale_y_continuous(
    labels = function(x) paste0(x, "%"),
    limits = c(0, 100),
    expand = expansion(mult = c(0, 0.02))
  ) +
  labs(
    title = "Share of days exceeding WHO PM2.5 guideline by year",
    subtitle = "Stacked bars show the percentage of observed days above vs below the WHO 24-hour guideline (15 µg/m³).",
    x = "Year",
    y = "Share of days (%)"
  ) +
  base_theme

# Saving the Figure
ggsave(
  filename = file.path(FIG_DIR, "Fig2_yearly_stacked_who_days.png"),
  plot = fig2,
  width = 10, height = 5, dpi = 300
)

# =================================================================
# FIGURE 3: Boxplots Related to the Weather Conditions Categories
# =================================================================

# Computing Thresholds
temp_q   <- if ("temp_mean_c" %in% names(df)) quantile(df$temp_mean_c, probs = c(1/3, 2/3), na.rm = TRUE) else c(NA_real_, NA_real_)
wind_med <- if ("wind_mean_kmh" %in% names(df)) median(df$wind_mean_kmh, na.rm = TRUE) else NA_real_
hum_med  <- if ("humidity" %in% names(df)) median(df$humidity, na.rm = TRUE) else NA_real_


# Reshaping PM2.5 Data to Long Format for Comparison Across Weather Condition Categories
box_df <- df %>%
  transmute(
    pm25 = .data[["pm25_london_mean"]],
    Temperature   = if ("temp_bin" %in% names(df)) temp_bin else NA_character_,
    Wind          = if ("wind_bin" %in% names(df)) wind_bin else NA_character_,
    Precipitation = if ("rain_flag" %in% names(df)) rain_flag else NA_character_,
    Humidity      = if ("humidity_bin" %in% names(df)) humidity_bin else NA_character_
  ) %>%
  pivot_longer(
    cols = c(Temperature, Wind, Precipitation, Humidity),
    names_to = "weather_factor",
    values_to = "category"
  ) %>%
  filter(!is.na(pm25), !is.na(category)) %>%
  mutate(
    weather_factor = factor(weather_factor,
                            levels = c("Temperature", "Wind", "Precipitation", "Humidity")),
    category = factor(category)
  )

# Facet Annotation (top-right labels as legend)
ann_df <- tibble(
  weather_factor = factor(
    c("Temperature", "Wind", "Precipitation", "Humidity"),
    levels = c("Temperature", "Wind", "Precipitation", "Humidity")
  ),
  label = c(
    if (all(!is.na(temp_q)))
      paste0("Cool ≤ ", round(temp_q[1], 1), "°C\n", round(temp_q[1], 1), "°C ≤ ", "Mild ≤ ", round(temp_q[2], 1), "°C\nWarm > ", round(temp_q[2], 1), "°C")
    else
      "Temp bins",

    if (!is.na(wind_med))
      paste0("Calm ≤ ", round(wind_med, 1), " km/h\nWindy > ", round(wind_med, 1), " km/h")
    else
      "Wind bins",

    "Dry = 0 mm\nRainy > 0 mm",

    if (!is.na(hum_med))
      paste0("Low ≤ ", round(hum_med, 0), "%\nHigh > ", round(hum_med, 0), "%")
    else
      "Humidity bins"
  )
)

# Plotting the Graph
fig3 <- ggplot(box_df, aes(x = category, y = pm25)) +
  geom_boxplot(
    fill = "#e26313", alpha = 0.70,
    colour = "black", linewidth = 0.45,
    outlier.alpha = 0.25, outlier.size = 1.2
  ) +
  facet_wrap(~ weather_factor, scales = "free_x", nrow = 1) +
  geom_label(
    data = ann_df,
    aes(x = Inf, y = Inf, label = label),
    inherit.aes = FALSE,
    hjust = 1.02, vjust = 1.05,
    size = 3.0,
    label.size = 0.25,
    fill = "white",
    colour = "black",
    alpha = 0.95
  ) +
  labs(
    title = "PM2.5 Distributions Under Different Weather Conditions",
    x = NULL,
    y = expression("PM2.5 ("*mu*"g/m"^3*")")
  ) +
  base_theme


# Saving the Figure
ggsave(
  filename = file.path(FIG_DIR, "Fig3_boxplots_weather_conditions.png"),
  plot = fig3,
  width = 11, height = 4.5, dpi = 300
)





# ============================================================
# FIGURE 4: Extreme Pollution Days by Season
# ============================================================

# Computing Seasonal Mean PM2.5 by Year, Keeping Seasons with at Least 60 Observed Days
df_season_year <- df %>%
  filter(!is.na(date), !is.na(pm25_london_mean)) %>%
  mutate(
    year = lubridate::year(date),
    month_num = lubridate::month(date),
    season = dplyr::case_when(
      month_num %in% c(12, 1, 2)  ~ "Winter",
      month_num %in% c(3, 4, 5)   ~ "Spring",
      month_num %in% c(6, 7, 8)   ~ "Summer",
      month_num %in% c(9, 10, 11) ~ "Autumn",
      TRUE ~ NA_character_
    ),
    season = factor(season, levels = c("Winter", "Spring", "Summer", "Autumn"))
  ) %>%
  group_by(year, season) %>%
  summarise(
    pm25_season_mean = mean(pm25_london_mean, na.rm = TRUE),
    n_days = n(),
    .groups = "drop"
  ) %>%
  filter(n_days >= 60)

# Plotting the Graph
fig4 <- ggplot(df_season_year, aes(x = season, y = factor(year), fill = pm25_season_mean)) +
  geom_tile(color = "black", linewidth = 0.25) +
  scale_fill_gradient(
    low = "white",
    high = "#d25107",
    name = "Seasonal mean\nPM2.5 (µg/m³)"
  ) +
  labs(
    title = "Seasonal mean PM2.5 in London (Season × Year heatmap)",
    subtitle = "Each cell summarises average PM2.5 for a season within a given year.",
    x = "Season",
    y = "Year"
  ) +
  base_theme +
  theme(
    legend.position = "right"
  ) +
  geom_text(
    aes(label = round(pm25_season_mean, 1)),
    colour = "black",
    size = 3
  )

# Saving the Figure
ggsave(
  filename = file.path(FIG_DIR, "Fig4_season_year_heatmap_mean.png"),
  plot = fig4,
  width = 10, height = 5.6, dpi = 300
)



# ============================================================
# COMPOSITE All Visualisations in One Page
# ============================================================
# Tagging figures
f1 <- fig1
f2 <- fig2
f3 <- fig3
f4 <- fig4

# Tag Style + Spacing
tag_theme <- theme(
  plot.tag = element_text(face = "bold", size = 14),
  plot.tag.position = c(0, 1),
  plot.margin = margin(10, 14, 10, 10)
)

f1 <- f1 + tag_theme
f2 <- f2 + tag_theme
f3 <- f3 + tag_theme
f4 <- f4 + tag_theme

# Plotting Composite layout: 2x2
composite <- (f1 | f2) / (f3 | f4) +
  plot_layout(guides = "keep") +
  plot_annotation(
    title = "Composite visualisation: London PM2.5 and contextual weather conditions",
    theme = theme(
      plot.title = element_text(face = "bold", size = 16),
      plot.margin = margin(12, 12, 12, 12)
    )
  )

# Saving the Figure
ggsave(
  filename = file.path(FIG_DIR, "Composite_4figures.png"),
  plot = composite,
  width = 16, height = 9.5, dpi = 300
)
