---
  title: "Sunlight and Water Requirements in Edible Plants: A Statistical Analysis"
author: "Naiya Patel"
date: "2026-05-05"
output:
  pdf_document:
  toc: true
toc_depth: 2
number_sections: true
fig_caption: true
latex_engine: xelatex
header-includes:
  - \usepackage{booktabs}
- \usepackage{float}
---
  
  ```{r setup, include=FALSE}
knitr::opts_chunk$set(
  echo    = FALSE,
  warning = FALSE,
  message = FALSE,
  fig.align = "center",
  fig.pos   = "H",
  out.width = "80%"
)

library(tidyverse)
library(knitr)

setwd("/Users/naiyapatel/Desktop/VTPEH6270-Naiya/Data")
edible_plants <- read_csv("edible_plants.csv")

edible_plants_clean <- edible_plants %>%
  mutate(
    sunlight_clean = str_trim(str_to_lower(sunlight)),
    water_clean    = str_trim(str_to_lower(water)),
    sunlight_recoded = case_when(
      sunlight_clean == "full sun"               ~ "Full Sun",
      sunlight_clean == "full sun/partial shade" ~ "Full Sun/Partial Shade",
      sunlight_clean %in% c(
        "partial shade",
        "full sun/partial shade/full shade",
        "full sun/partial shade/ full shade"
      )                                          ~ "Partial Shade or More"
    ),
    water_recoded = case_when(
      water_clean %in% c("very low", "low")    ~ "Low/Very Low",
      water_clean == "medium"                   ~ "Medium",
      water_clean %in% c("high", "very high")  ~ "High/Very High"
    ),
    sunlight_recoded = factor(
      sunlight_recoded,
      levels = c("Full Sun", "Full Sun/Partial Shade", "Partial Shade or More")
    ),
    water_recoded = factor(
      water_recoded,
      levels = c("Low/Very Low", "Medium", "High/Very High")
    )
  )

ct          <- table(Sunlight = edible_plants_clean$sunlight_recoded,
                     Water    = edible_plants_clean$water_recoded)
chisq_test  <- chisq.test(ct)
fisher_test <- fisher.test(ct, simulate.p.value = TRUE)

chi_stat    <- round(chisq_test$statistic, 2)
chi_df      <- chisq_test$parameter
chi_p       <- round(chisq_test$p.value, 3)
fish_p      <- round(fisher_test$p.value, 3)
n_below_5   <- sum(chisq_test$expected < 5)
pct_below_5 <- round(100 * n_below_5 / length(chisq_test$expected), 1)
```

\newpage

# Introduction

This report investigates whether sunlight requirement is associated with water requirement in edible plant species. Specifically, we hypothesize that **plants requiring full sun will tend to have higher water requirements**, given that greater light exposure drives evapotranspiration and increases plant water demand. Conversely, shade-tolerant species are expected to have lower water needs, as they typically grow in environments with higher soil moisture retention.

- **Code and data repository:** <https://github.com/ncp46-coder/VTPEH6270-Naiya.git>
  - **Interactive Shiny app:** <https://ncp46.shinyapps.io/Checkpoint7ShinyApp/>
  
  ## Research Question
  
  > **Do edible plant species that require more sunlight tend to have higher water requirements compared to those that tolerate partial shade or full shade?**
  
  ## Scientific Context
  
  Plants adapted to high-sunlight environments typically experience greater evapotranspiration rates, which increases their water demand (Jones, 1992). Conversely, shade-tolerant species often grow in environments with higher soil moisture retention, reducing their irrigation needs (Larcher, 2003). If these traits co-occur in predictable ways, it would have practical implications for companion planting and sustainable garden design, allowing gardeners to group plants with similar resource needs more efficiently.

---
  
  # Material & Methods
  
  ## Data
  
  The analysis uses the **edible_plants** dataset from the TidyTuesday project (2026-02-03), which contains observational records on edible plant species including cultivation characteristics and environmental requirements (Mock, 2026). The dataset is publicly available at:
  
  <https://github.com/rfordatascience/tidytuesday/blob/main/data/2026/2026-02-03/edible_plants.csv>
  
  The dataset contains `r nrow(edible_plants)` observational records. The two variables of interest -- `sunlight` and `water` -- were both fully complete (`r sum(is.na(edible_plants$sunlight))` missing values each) and required minor standardization prior to analysis.

Both variables had fine-grained original levels that produced very sparse cells when cross-tabulated. To satisfy the assumptions of the chi-square test (expected cell counts >= 5), categories were collapsed into three ordered levels each:
  
  - **Sunlight:** Full Sun | Full Sun/Partial Shade | Partial Shade or More
- **Water:** Low/Very Low | Medium | High/Very High

## Statistical Analysis

A **Pearson's Chi-square test of independence** was used to test for an association between sunlight and water requirement. Before interpreting the chi-square result, expected cell counts were inspected. If more than 20% of cells had expected counts below 5, **Fisher's Exact Test** (with simulated *p*-value based on 2,000 replicates) was used as the primary test, with the chi-square result reported for reference (Fisher, 1922). A significance level of $\alpha$ = 0.05 was applied.

---
  
  # Results
  
  ## Contingency Table
  
  ```{r contingency-table}
knitr::kable(
  ct,
  caption = "Observed counts of edible plant species by sunlight and water requirement (n = 140).",
  booktabs = TRUE
)
```

As shown in Table 1, medium water demand is the most common category across all three sunlight groups. Full Sun plants form the largest group (n = `r sum(ct["Full Sun", ])`), while Partial Shade or More is the smallest (n = `r sum(ct["Partial Shade or More", ])`).

## Assumption Check

```{r expected-counts}
knitr::kable(
  round(chisq_test$expected, 2),
  caption = "Expected cell counts under the null hypothesis of independence. Cells below 5 indicate a potential chi-square assumption violation.",
  booktabs = TRUE
)
```

Table 2 shows that `r n_below_5` of 9 expected cells (`r pct_below_5`%) fell below 5, exceeding the 20% threshold. Fisher's Exact Test was therefore used as the primary test.

## Statistical Tests

Both tests found no statistically significant association between sunlight and water requirements:

- **Pearson's Chi-square:** $\chi^2$(`r chi_df`) = `r chi_stat`, *p* = `r chi_p`
                                                      - **Fisher's Exact Test (primary):** *p* = `r fish_p`

Neither result reaches the significance threshold of $\alpha$ = 0.05. The distribution of water requirements was broadly similar across all three sunlight categories, with medium water demand being the most common regardless of sunlight level.

## Visualization

```{r figure-stacked-bar, fig.cap="Proportion of edible plant species in each water requirement category, grouped by sunlight requirement. Proportions are shown (rather than counts) to account for unequal group sizes. Full Sun n = 87, Full Sun/Partial Shade n = 44, Partial Shade or More n = 9."}

fig1 <- edible_plants_clean %>%
  count(sunlight_recoded, water_recoded) %>%
  group_by(sunlight_recoded) %>%
  mutate(prop = n / sum(n)) %>%
  ggplot(aes(x = sunlight_recoded, y = prop, fill = water_recoded)) +
  geom_col(position = "fill", width = 0.6, color = "white", linewidth = 0.2) +
  scale_y_continuous(labels = scales::percent_format(), expand = c(0, 0)) +
  scale_fill_brewer(palette = "Blues", name = "Water\nRequirement") +
  labs(
    title = "Water Requirement by Sunlight Category",
    x     = "Sunlight requirement",
    y     = "Proportion of species"
  ) +
  theme_classic(base_size = 7, base_family = "Helvetica") +
  theme(
    plot.title      = element_text(size = 7, face = "bold"),
    axis.title      = element_text(size = 7),
    axis.text       = element_text(size = 6),
    axis.text.x     = element_text(angle = 15, hjust = 1),
    legend.title    = element_text(size = 7, face = "bold"),
    legend.text     = element_text(size = 6),
    legend.key.size = unit(3, "mm"),
    panel.grid      = element_blank()
  )

print(fig1)

ggsave(
  filename = "Fig1_sunlight_vs_water.pdf",
  plot     = fig1,
  device   = "pdf",
  width    = 89 / 25.4,
  height   = 70 / 25.4,
  units    = "in",
  dpi      = 300
)
```

Figure 1 visually supports the statistical findings. While plants in the Partial Shade or More group appear to have a slightly higher proportion of High/Very High water requirements, the overall distributions across sunlight categories are broadly similar -- consistent with the non-significant test results and contrary to our initial hypothesis.

---

# Conclusions

The results do not support the hypothesis that plants requiring more sunlight tend to have higher water requirements. Despite the biological plausibility of this relationship, no significant association was detected ($\chi^2$(`r chi_df`) = `r chi_stat`, *p* = `r chi_p`; Fisher's *p* = `r fish_p`).

This null result should be interpreted cautiously. The Partial Shade or More group was notably small (n = `r sum(ct["Partial Shade or More", ])`), which reduces statistical power and limits the ability to detect a true association if one exists. Additionally, collapsing the original fine-grained categories may have obscured patterns present at finer levels of resolution. Future studies with larger, more balanced samples and more granular measurements would be better positioned to detect or rule out such an association.

---
  
  # References
  
  Fisher, R. A. (1922). On the interpretation of chi-square from contingency tables, and the calculation of P. *Journal of the Royal Statistical Society*, 85(1), 87-94.

Jones, H. G. (1992). *Plants and microclimate: A quantitative approach to environmental plant physiology* (2nd ed.). Cambridge University Press.

Larcher, W. (2003). *Physiological plant ecology: Ecophysiology and stress physiology of functional groups* (4th ed.). Springer.

Mock, T. (2026). *TidyTuesday: A weekly social data project in R* [Data set]. GitHub. <https://github.com/rfordatascience/tidytuesday/blob/main/data/2026/2026-02-03/edible_plants.csv>
  
  ---
  
  # AI Use Disclosure Statement
  
  This report was produced with assistance from Claude (Anthropic) for the following tasks:
  
  - Data cleaning: identifying variables with the fewest missing values
- Formatting: chi-square output table formatting in RMarkdown
- Code debugging: contingency table construction and Fisher's Exact Test calls

All analytical decisions, statistical interpretations, and written conclusions are the author's own.
