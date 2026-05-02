# VTPEH6270-Naiya

> **Course:** VTPEH 6270 | **Author:** Naiya Patel | **Institution:** Cornell University

---

## Overview

This project is the culmination of what I learned in VTPEH 6270 (Environmental Epidemiology & Public Health) through the exploration of the TidyTuesday edible_plants dataset, which contains observational records on 140 edible plant species and their cultivation requirements.

The analysis investigates one central question:

> Is sunlight requirement associated with water requirement in edible plant species?

The results show that **no statistically significant association was detected between sunlight and water requirements** (χ²(4) = 4.35, p = 0.36; Fisher's p = 0.34), though limited sample size in shade-tolerant species reduces the power to detect a true effect.

---

## Research Question

- Is sunlight requirement associated with water requirement in edible plant species, such that full-sun plants have higher water demands?

---

## Repository Contents

| Folder | Contents |
|--------|----------|
| `Data/` | `edible_plants.csv` — source dataset |
| `Final_Report/` | `FinalReport.Rmd` and `FinalReport.pdf` — **start here** |
| `Checkpoints/CP02/` | Checkpoint 2 Rmd + PDF |
| `Checkpoints/CP04/` | Checkpoint 4 Rmd + PDF |
| `Checkpoints/CP06/` | Checkpoint 6 Rmd + PDF |
| `Checkpoints/CP07/` | Checkpoint 7 Rmd + PDF |
| `ShinyApp/` | `app.R` — interactive data explorer |

---

## Data Source

- **Dataset:** edible_plants (TidyTuesday, 2026-02-03)
- **URL:** https://github.com/rfordatascience/tidytuesday/blob/main/data/2026/2026-02-03/edible_plants.csv
- **Description:** Observational records on 140 edible plant species including sunlight requirements, water requirements, and other cultivation characteristics.

---

## How to Reproduce

1. Clone this repository
2. Install required packages:
   ```r
   install.packages(c("tidyverse", "knitr"))
   ```
3. Update the `setwd()` path in the Rmd file to your local machine
4. Open `Final_Report/FinalReport.Rmd` in RStudio and click **Knit**

---

## Shiny App

An interactive data explorer for the edible_plants dataset is available here:

**[Launch Shiny App](https://your-shinyapp-link.shinyapps.io/VTPEH6270-Naiya)**

To run locally:
```r
shiny::runApp("ShinyApp/app.R")
```

---

## AI Disclosure

Claude (Anthropic) assisted with data cleaning, code debugging, and formatting. All analytical decisions and interpretations are the author's own.
