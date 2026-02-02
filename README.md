# IJC445 – Data Visualisation Project

## Module Information

**Module:** IJC445 – Data Visualisation  
**Programme:** MSc Data Science  
**Institution:** University of Sheffield  

This repository contains the individual coursework project for the IJC445 module. The project examines how visualisation choices shape the interpretation of PM2.5 air quality data in London, with particular attention to temporal scale, environmental framing, and regulatory thresholds.

The analysis builds on the dataset used in the IJC437 coursework and focuses on visual knowledge construction rather than predictive performance. Visualisation is treated as an analytical framing process, where design decisions influence how variability, compliance, and risk are perceived.

---

## Research Question

**RQ:**  
How does the choice of temporal scale and environmental framing (season and daily weather conditions) shape the interpretation of PM2.5 variability and WHO guideline exceedance in London (2016–2025)?

---

## Composite Visualisation Overview

The analysis is structured around a composite visualisation consisting of four coordinated charts:



<img width="3000" height="1350" alt="Fig1_timeseries_raw_vs_roll30" src="https://github.com/user-attachments/assets/f787ba34-3be2-4303-9e11-68f7dc84d2bd" />

- **Figure 1:** Daily PM2.5 concentrations with a 30-day rolling mean, highlighting the contrast between short-term volatility and smoothed trends.



<img width="3000" height="1500" alt="Fig2_yearly_stacked_who_days" src="https://github.com/user-attachments/assets/65c6803a-5c2b-4623-a6ee-8ba24adfc71e" />

- **Figure 2:** Annual share of days exceeding the WHO 24-hour PM2.5 guideline, framing air quality through regulatory compliance.



<img width="3300" height="1350" alt="Fig3_boxplots_weather_conditions" src="https://github.com/user-attachments/assets/cd0250c1-6708-4705-a949-35cb0b6dd55a" />

- **Figure 3:** Distributional comparison of PM2.5 concentrations under different weather conditions (temperature, wind, precipitation, humidity).



<img width="3000" height="1680" alt="Fig4_season_year_heatmap_mean" src="https://github.com/user-attachments/assets/baafea0b-174c-41d5-8633-7a8018b5b27c" />

- **Figure 4:** Season × Year heatmap of mean PM2.5 concentrations, revealing recurring seasonal structure and contextualising exceedance patterns.

Together, these figures demonstrate that PM2.5 risk is not defined by a single metric but emerges from the interaction of temporal aggregation, environmental categorisation, and threshold-based framing.

---

## Data Sources

- **OpenAQ** – Daily PM2.5 air quality measurements from monitoring stations across London  
  https://openaq.org/

- **Open-Meteo** – Daily meteorological data (temperature, wind speed, precipitation, humidity)  
  https://open-meteo.com

- **World Health Organization (WHO)** – 24-hour PM2.5 guideline (15 µg/m³)

The same core dataset as IJC437 is used, with additional derived variables created specifically for visualisation purposes.

---

## Repository Structure

data/
primary_pm25_daily_london.csv
openmeteo_daily_london.csv
merged_pm25_weather.csv

scripts/
00_setup_packages.R
01_fetch_openmeteo_weather.R
02_data_preparation.R
03_visualisations.R

output/
figures/


The repository structure separates data, scripts, and outputs to support transparency and reproducibility. All figures in the written report are generated directly from the scripts in this repository.

---

## Visualisation Workflow

### Data Preparation

PM2.5 measurements are cleaned and merged with daily meteorological variables. Weather variables are categorised to support distributional comparison and environmental framing.

### Visual Analysis

Multiple visual representations are constructed to examine how different framing choices alter interpretation:

- Raw versus smoothed time series  
- Threshold exceedance versus magnitude  
- Environmental categorisation versus seasonal aggregation  

### Interpretation

The composite visualisation is analysed using the ASSERT framework and the Grammar of Graphics, with additional consideration of accessibility, ethical implications, and design trade-offs.

---

## How to Reproduce the Analysis

1. Clone this repository locally.  
2. Open RStudio and set the working directory to the repository root.  
3. Ensure R (version 4.2 or later) is installed.  
4. Run the scripts in the following order:

   - `00_setup_packages.R`  
   - `01_data_preparation.R`  
   - `02_visualisations.R`  

All figures will be automatically saved to the `output/figures/` directory.

---

## Notes on Reproducibility

- Scripts are designed to be run sequentially and include in-code documentation.  
- The analysis uses open-access data, enabling full replication.  
- Visual outputs correspond directly to figures discussed in the coursework report.

---

## Author

**Aliakbar Rzayev**  
MSc Data Science  
University of Sheffield  
