VTPEH 6270 — Environmental Epidemiology & Public Health
Naiya Patel | Cornell University | Spring 2026
This repository contains all coursework for VTPEH 6270, including checkpoint analyses and the final report. The project explores associations between environmental and cultivation characteristics in edible plant species using the TidyTuesday edible_plants dataset.

Repository Structure
VTPEH6270-Naiya/
│
├── Data/
│   └── edible_plants.csv          # Source dataset (TidyTuesday 2026-02-03)
│
├── Final_Report/
│   ├── FinalReport.Rmd            # Main analysis — START HERE
│   └── FinalReport.pdf            # Rendered output
│
├── Checkpoints/
│   ├── CP02/
│   │   ├── Checkpoint2.Rmd
│   │   └── Checkpoint2.pdf
│   ├── CP04/
│   │   ├── Checkpoint4.Rmd
│   │   └── Checkpoint4.pdf
│   ├── CP06/
│   │   ├── Checkpoint6.Rmd
│   │   └── Checkpoint6.pdf
│   └── CP07/
│       ├── Checkpoint7.Rmd
│       └── Checkpoint7.pdf
│
└── ShinyApp/
    └── app.R                      # Interactive data explorer

Project Description
This project investigates whether sunlight requirement is associated with water requirement in edible plant species. Using observational data on 140 plant species, the analysis applies a chi-square test of independence and Fisher's Exact Test to evaluate this ecological relationship.
Key finding: No statistically significant association was detected between sunlight and water requirements (chi-squared(4) = 4.35, p = 0.36; Fisher's p = 0.34), though the small sample size in shade-tolerant species limits interpretability.

Data Source

Dataset: edible_plants (TidyTuesday, 2026-02-03)
URL: https://github.com/rfordatascience/tidytuesday/blob/main/data/2026/2026-02-03/edible_plants.csv
Description: Observational records on 140 edible plant species including sunlight requirements, water requirements, and other cultivation characteristics.


How to Reproduce the Analysis
Requirements

R (>= 4.0)
RStudio (recommended for knitting)
R packages: tidyverse, knitr

Install packages if needed:
rinstall.packages(c("tidyverse", "knitr"))
Steps

Clone this repository:

   git clone https://github.com/ncp46-coder/VTPEH6270-Naiya.git

Open RStudio and set your working directory to the cloned folder.
Place edible_plants.csv in the Data/ folder (or update the setwd() path in the Rmd file to match your local path).
Open Final_Report/FinalReport.Rmd and click Knit to reproduce the PDF.


Note: The setwd() path in the Rmd files is set to the author's local machine. Update it to your own path before knitting.


Shiny App
An interactive data explorer for the edible_plants dataset is available in the ShinyApp/ folder.
To run locally:
rlibrary(shiny)
shiny::runApp("ShinyApp/app.R")

Checkpoint Overview
CheckpointTopicKey MethodCP02Data ExplorationSummary statistics, initial visualizationCP04Data Visualizationggplot2 figuresCP06Statistical AnalysesChi-square test, Fisher's Exact TestCP07(topic)(method)Final ReportSunlight vs. Water RequirementsChi-square + Fisher's Exact Test

AI Use Disclosure
Claude (Anthropic) was used to assist with:

Data cleaning: identifying variables with fewest missing values
Code formatting and debugging (chi-square table, Fisher's Exact Test)
README structure and documentation

All analytical decisions, statistical interpretations, and written conclusions are the author's own.

Contact
Naiya Patel | np000@cornell.edu | Cornell University
