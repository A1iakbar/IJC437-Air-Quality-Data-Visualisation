# ============================================================
# IJC445 Data Visualisation (Coursework)
# Script: 00_setup_packages.R
# Purpose: Install (if missing) required R packages.
# ============================================================

required_packages <- c(
    "dplyr",
    "readr",
    "lubridate",
    "httr",
    "jsonlite",
    "tibble",
    "ggplot2",
    "zoo",
    "slider",
    "scales",
    "patchwork",
    "grid"

)

library(dplyr)
library(readr)
library(ggplot2)
library(lubridate)
library(tidyr)

# Install missing packages only
installed <- rownames(installed.packages())
to_install <- setdiff(required_packages, installed)

if (length(to_install) > 0) {
  install.packages(to_install, dependencies = TRUE)
}
