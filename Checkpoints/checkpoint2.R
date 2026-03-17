---
  title: "VTPEH6270-Checkpoint 2 Naiya Patel"
author: "Naiya Patel"
date: "2026-02-20"
output:
  pdf_document:
  toc: true
number_sections: true
html_document:
  toc: true
toc_depth: 1
number_sections: true
---
  
  ```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE, warning = FALSE,
                      message = FALSE)
```

# Introduction

We will use [edible_plants Data](https://github.com/rfordatascience/tidytuesday/blob/main/data/2026/2026-02-03/edible_plants.csv) for this R markdown file. The dataset contains information on edible plant species, including taxonomy, cultivation characteristics, environmental requirements, and basic nutritional properties. Variables describe sunlight and water needs, soil preferences, temperature tolerance, germination time, harvest time, and energy content. This analysis prepares the data in a tidy and interpretable format to explore relationships between cultivation conditions and plant growth outcomes. 
The dataset supports investigation of biologically plausible associations between environmental requirements and measurable indicators such as germination duration, harvest time, and food energy value.

```{r import_csv}
setwd("/Users/naiyapatel/Desktop/Biostats")
data_edible_plants = read.csv("edible_plants (1).csv")
```

# Cleaning

```{r tidy}
library(janitor)
library(tidyverse)

data_edible_plants <- clean_names(data_edible_plants)
names(data_edible_plants)
```

# Selection of variables

```{r subset_variables}
plants_subset <- data_edible_plants %>%
  select(cultivation, sunlight, water, soil, temperature_class,
         preferred_ph_lower, preferred_ph_upper,
         days_germination, days_harvest, energy)
```

```{r convert-types}

plants_subset <- plants_subset %>%
  mutate(
    across(c(cultivation, sunlight, water, soil, temperature_class), as.factor),
    across(c(preferred_ph_lower, preferred_ph_upper,
             days_germination, days_harvest, energy), as.numeric)
  )

# Verify structure
str(plants_subset)

```

Plants subset has 140 observations and 10 variables.

# Variable overview 

```{r variable-overview-table}

var_table <- tibble(
  Variable = names(plants_subset),
  Type = c("Categorical","Categorical","Categorical","Categorical","Categorical",
           "Continuous","Continuous","Discrete","Discrete","Continuous"),
  Class = sapply(plants_subset, class)
)

knitr::kable(var_table, 
             caption = "<span style='color:blue'>Overview of selected variables, their type, and data class in the edible plants dataset</span>")

```
# Missing values 

```{r }
# Count missing values in each variable
colSums(is.na(plants_subset))

```
# Data Visualization 

## Histogram of Energy Content

```{r histogram_energy}
library(ggplot2)

# Compute mean and median
energy_mean <- mean(plants_subset$energy, na.rm = TRUE)
energy_median <- median(plants_subset$energy, na.rm = TRUE)

# Create histogram
ggplot(plants_subset, aes(x = energy)) +
  geom_histogram(binwidth = 20, fill = "lightgreen", color = "black") +  # adjust binwidth to suit data
  geom_vline(aes(xintercept = energy_mean, color = "Mean"), linetype = "dashed", size = 1) +
  geom_vline(aes(xintercept = energy_median, color = "Median"), linetype = "solid", size = 1) +
  scale_color_manual(name = "Statistics", values = c("Mean" = "blue", "Median" = "red")) +
  labs(
    x = "Energy (Kcal)", 
    y = "Number of Plants",
    title = "Distribution of Energy Content in Edible Plants",
    caption = "Histogram of energy content (Kcal) with mean (blue dashed) and median (red solid) lines"
  ) +
  theme_minimal()  # Using a non-default theme

```
The histogram shows that most edible plants have energy content clustered around 25–50 Kcal, with fewer plants having very high or very low energy.  
The mean energy (blue dashed line) is slightly higher than the median (red solid line), suggesting a right-skewed distribution.

## Scatterplot of Preferred pH versus Energy

```{r scatter_ph_energy}

ggplot(plants_subset, aes(x = preferred_ph_lower, y = energy)) +
  geom_point(color = "darkgreen", size = 2, alpha = 0.7) +
  labs(
    x = "Preferred Lower pH",
    y = "Energy (Kcal)",
    title = "Scatterplot of Preferred Lower pH vs Energy",
    caption = "Scatter plot showing relationship between preferred lower pH and energy content in edible plants"
  ) +
  scale_x_continuous(breaks = seq(4, 8, 0.5)) +   # adjust x-axis for pH range
  scale_y_continuous(breaks = seq(0, 100, 10)) +  # adjust y-axis for energy Kcal
  theme_light()  # non-default theme

```
The scatterplot indicates that there is no strong linear relationship between preferred lower pH and energy content.  
Most plants cluster around a preferred pH of 6–7, and energy content is broadly distributed across this pH range.

# AI Use Disclosure Statement

*As part of this assignment, please indicate whether you used any AI-based tools (e.g., ChatGPT, Claude, Copilot, Gemini, etc.). Indicate:*
  
  * *Did you use AI? Yes / No*
  
  * *If yes: Write a short disclosure statement (2–3 sentences) describing:*
  
  * *Which tool(s) you used.*
  
  * *How you used it (e.g., to help decide on an analysis approach, to generate a first draft of code, to improve or debug code you had written yourself, etc.).*
  
  *Example: “This document was generated using Claude to generate original code, which was then reviewed and adjusted” or "This document was generated using ChatGPT to assist with debugging of code generated by the author".*
  
  *Please keep your statement brief and honest. The goal is transparency, not detail: we do not need exact prompts or transcripts, just a clear sense of how AI supported this work.*
  
  This document was generated using help of ChatGPT in order to figure out variable table formation and correct visual elemnts for coding the histogram and scatter plots.
