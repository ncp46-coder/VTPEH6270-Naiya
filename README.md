VTPEH6270-Naiya

Course: VTPEH 6270 | Author: Naiya Patel | Institution: Cornell University


Overview
This project is the culmination of what I learned in VTPEH 6270 (Environmental Epidemiology & Public Health) through the exploration of the TidyTuesday edible_plants dataset, which contains observational records on 140 edible plant species and their cultivation requirements.
The analysis investigates one central question:

Do edible plant species that require more sunlight tend to have higher water requirements compared to those that tolerate partial shade or full shade?

The results show that no statistically significant association was detected between sunlight and water requirements (χ²(4) = 4.35, p = 0.36; Fisher's p = 0.34), contrary to the hypothesis that full-sun plants would have higher water demands. Limited sample size in shade-tolerant species (n = 9) reduces the power to detect a true effect.

Research Question

Do edible plant species that require more sunlight tend to have higher water requirements compared to those that tolerate partial shade or full shade?

We hypothesize that plants requiring full sun will have higher water requirements, given that greater light exposure drives evapotranspiration and increases plant water demand (Jones, 1992). Shade-tolerant species are expected to have lower water needs as they typically grow in environments with higher soil moisture retention (Larcher, 2003).

Repository Contents
FolderContentsData/edible_plants.csv — source datasetCheckpoints/Checkpoint reports (CP02, CP04, CP06, CP07)Output/Figures/Fig1_sunlight_vs_water.pdf — Nature-formatted figureOutput/Reports/FINAL_REPORT_NAIYA.pdf — final report PDFScripts/FINAL_REPORT_NAIYA.R and Shinyapp.RCheckpoint7ShinyApp/app.R and data for Shiny deployment

Data Source

Dataset: edible_plants (TidyTuesday, 2026-02-03)
URL: https://github.com/rfordatascience/tidytuesday/blob/main/data/2026/2026-02-03/edible_plants.csv
Description: Observational records on 140 edible plant species including sunlight requirements, water requirements, and other cultivation characteristics.


Shiny App
An interactive data explorer for the edible_plants dataset is available here:
Launch Shiny App
To run locally:
rshiny::runApp("Checkpoint7ShinyApp/app.R")

References
Fisher, R. A. (1922). On the interpretation of chi-square from contingency tables, and the calculation of P. Journal of the Royal Statistical Society, 85(1), 87-94.
Jones, H. G. (1992). Plants and microclimate: A quantitative approach to environmental plant physiology (2nd ed.). Cambridge University Press.
Larcher, W. (2003). Physiological plant ecology: Ecophysiology and stress physiology of functional groups (4th ed.). Springer.
Mock, T. (2026). TidyTuesday: A weekly social data project in R [Data set]. GitHub. https://github.com/rfordatascience/tidytuesday/blob/main/data/2026/2026-02-03/edible_plants.csv

AI Disclosure
Claude (Anthropic) assisted with data cleaning, code debugging, and formatting. All analytical decisions and interpretations are the author's own.
