# Exploring PM2.5 Air Quality Patterns in London
## IJC445 Data Visualisation Coursework (2025–2026)
### Overview

This project examines how temporal scale and environmental framing influence the interpretation of PM2.5 variability and WHO guideline exceedance in London between 2016 and 2025.

Rather than treating visualisation as a neutral display tool, the analysis approaches it as an analytical framing process. Different representations — smoothing, aggregation, thresholding, and environmental categorisation — shape how pollution risk is perceived and understood.

### Research Question

@ How does the choice of temporal scale and environmental framing (season and daily weather conditions) shape the interpretation of PM2.5 variability and WHO guideline exceedance in London (2016–2025)?

The project connects empirical air quality data with regulatory relevance, demonstrating how design decisions alter interpretive emphasis.

Composite Visualisation Structure

The analysis consists of four coordinated figures:

Figure 1 — Daily PM2.5 and 30-Day Rolling Mean

Highlights the contrast between short-term volatility and smoothed temporal trends.

Figure 2 — Annual WHO Guideline Exceedance Share

Uses a 100% stacked bar chart to emphasise regulatory compliance framing.

Figure 3 — PM2.5 Distributions by Weather Conditions

Compares concentration distributions across temperature, wind, precipitation, and humidity categories.

Figure 4 — Season × Year Heatmap of Mean PM2.5

Reveals recurring seasonal structure and contextualises exceedance patterns.

Together, these figures demonstrate that air quality risk is relational rather than singular — shaped by scale, aggregation, and environmental context.

Data Sources

Daily PM2.5 measurements (London monitoring stations)

Daily meteorological variables (temperature, wind speed, precipitation, humidity)

WHO 24-hour PM2.5 guideline (15 µg/m³)

Weather data were merged with PM2.5 records and categorised for comparative analysis.

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

Reproducibility

To reproduce the full analysis:

Run 00_setup_packages.R

Run 01_data_preparation.R

Run 02_visualisations.R

All figures used in the coursework report are generated directly from these scripts.

Key Contribution

This project demonstrates that:

Smoothing alters perceived stability

Threshold framing alters perceived compliance

Environmental categorisation alters perceived causality

Seasonal aggregation alters perceived risk clustering

Visualisation choices therefore act as analytical decisions that structure interpretation.

Possible Extensions

Sensitivity analysis of rolling window sizes

Integration of traffic or emissions data

Alternative smoothing techniques

Interactive visual exploration

Explicit uncertainty visualisation
