Exploring PM2.5 Air Quality Patterns in London (2016–2025)

This project investigates how temporal scale and environmental framing influence the interpretation of PM2.5 variability and WHO guideline exceedance in London.

The analysis was developed for the IJC445 Data Visualisation module (2025–2026) and uses the same dataset as the IJC437 coursework, with additional derived variables created specifically for this visualisation study.

Research Question

How does the choice of temporal scale and environmental framing (season and daily weather conditions) shape the interpretation of PM2.5 variability and WHO guideline exceedance in London (2016–2025)?

The project treats visualisation not as a neutral display but as an analytical framing process. Different representations (daily values, rolling means, threshold exceedance, seasonal aggregation, and weather-based categorisation) highlight different aspects of pollution risk.

Composite Visualisation Overview

The composite consists of four coordinated charts:

Figure 1 – Daily PM2.5 with 30-day rolling mean
Compares raw volatility with smoothed trends to examine how temporal aggregation alters perceived stability.

Figure 2 – Annual share of WHO guideline exceedance
Uses a 100% stacked bar chart to emphasise regulatory compliance framing.

Figure 3 – PM2.5 distributions under different weather conditions
Compares distributions across temperature, wind, precipitation, and humidity categories to explore environmental effects.

Figure 4 – Season × Year heatmap of mean PM2.5
Reveals recurring seasonal structure and contextualises exceedance dynamics.

Together, the composite demonstrates that PM2.5 risk interpretation depends on scale, aggregation, and categorical framing choices.

Data Sources

Daily PM2.5 measurements (London monitoring stations)

Meteorological variables (temperature, wind speed, precipitation, humidity)

WHO 24-hour PM2.5 guideline (15 µg/m³)

Weather data were merged with PM2.5 records and categorised for distributional comparison.

Repository Structure
data/
  primary_pm25_daily_london.csv
  openmeteo_daily_london.csv
  merged_pm25_weather.csv

scripts/
  00_setup_packages.R
  01_data_preparation.R
  02_visualisations.R

output/
  figures/


00_setup_packages.R – installs and loads required libraries

01_data_preparation.R – cleaning, merging, and feature engineering

02_visualisations.R – generates the composite visualisation

Reproducibility

To reproduce the analysis:

Run 00_setup_packages.R

Run 01_data_preparation.R

Run 02_visualisations.R

All figures used in the coursework report are generated directly from these scripts.

Key Insight

The project shows that air quality interpretation changes depending on whether data are framed through:

Raw daily variability

Smoothed temporal trends

Regulatory threshold exceedance

Environmental categorisation

Seasonal aggregation

Visualisation choices therefore shape perceived stability, compliance, and risk.
