# ==============================================================================
# FinalReport_analysis.R
# Sunlight and Water Requirements in Edible Plants: A Statistical Analysis
# Author: Naiya Patel
# Date: 2026-05-05
# ==============================================================================

# ------------------------------------------------------------------------------
# SECTION 1: Load packages and data
# ------------------------------------------------------------------------------
library(tidyverse)
library(knitr)

setwd("/Users/naiyapatel/Desktop/VTPEH6270-Naiya/Data")
edible_plants <- read_csv("edible_plants.csv")

cat("Dataset loaded:", nrow(edible_plants), "observations,",
    ncol(edible_plants), "variables\n")

# ------------------------------------------------------------------------------
# SECTION 2: Data cleaning and recoding
# ------------------------------------------------------------------------------
edible_plants_clean <- edible_plants %>%
  mutate(
    sunlight_clean = str_trim(str_to_lower(sunlight)),
    water_clean    = str_trim(str_to_lower(water)),

    # Recode sunlight into 3 ordered levels
    sunlight_recoded = case_when(
      sunlight_clean == "full sun"               ~ "Full Sun",
      sunlight_clean == "full sun/partial shade" ~ "Full Sun/Partial Shade",
      sunlight_clean %in% c(
        "partial shade",
        "full sun/partial shade/full shade",
        "full sun/partial shade/ full shade"
      )                                          ~ "Partial Shade or More"
    ),

    # Recode water into 3 ordered levels
    water_recoded = case_when(
      water_clean %in% c("very low", "low")   ~ "Low/Very Low",
      water_clean == "medium"                  ~ "Medium",
      water_clean %in% c("high", "very high") ~ "High/Very High"
    ),

    # Set factor order
    sunlight_recoded = factor(
      sunlight_recoded,
      levels = c("Full Sun", "Full Sun/Partial Shade", "Partial Shade or More")
    ),
    water_recoded = factor(
      water_recoded,
      levels = c("Low/Very Low", "Medium", "High/Very High")
    )
  )

# Verification
cat("\nMissing values after recoding:\n")
cat("  sunlight_recoded:", sum(is.na(edible_plants_clean$sunlight_recoded)), "\n")
cat("  water_recoded:   ", sum(is.na(edible_plants_clean$water_recoded)), "\n")

# ------------------------------------------------------------------------------
# SECTION 3: Contingency table
# ------------------------------------------------------------------------------
ct <- table(
  Sunlight = edible_plants_clean$sunlight_recoded,
  Water    = edible_plants_clean$water_recoded
)

cat("\nTable 1: Observed counts - Sunlight vs Water Requirement\n")
print(ct)

cat("\nRow totals:\n")
print(rowSums(ct))
cat("Grand total:", sum(ct), "\n")

# ------------------------------------------------------------------------------
# SECTION 4: Chi-square assumption check
# ------------------------------------------------------------------------------
chisq_test <- chisq.test(ct)

cat("\nTable 2: Expected cell counts\n")
print(round(chisq_test$expected, 2))

n_cells     <- length(chisq_test$expected)
n_below_5   <- sum(chisq_test$expected < 5)
pct_below_5 <- round(100 * n_below_5 / n_cells, 1)

cat(sprintf(
  "\n%d of %d expected cells (%.1f%%) are below 5.\n",
  n_below_5, n_cells, pct_below_5
))
cat(sprintf(
  "Threshold: >20%% triggers Fisher's Exact Test. Current: %.1f%% -> %s\n",
  pct_below_5,
  ifelse(pct_below_5 > 20, "Fisher's Exact Test REQUIRED", "Chi-square OK")
))

# ------------------------------------------------------------------------------
# SECTION 5: Statistical tests
# ------------------------------------------------------------------------------
cat("\n-- Pearson's Chi-Square Test --\n")
print(chisq_test)

cat("\n-- Fisher's Exact Test (primary) --\n")
fisher_test <- fisher.test(ct, simulate.p.value = TRUE)
print(fisher_test)

# Key values
chi_stat    <- round(chisq_test$statistic, 2)
chi_df      <- chisq_test$parameter
chi_p       <- round(chisq_test$p.value, 3)
fish_p      <- round(fisher_test$p.value, 3)

cat(sprintf(
  "\nResult: Chi-square(df=%d) = %.2f, p = %.3f | Fisher's p = %.3f\n",
  chi_df, chi_stat, chi_p, fish_p
))
cat(sprintf(
  "Interpretation: %s (alpha = 0.05)\n",
  ifelse(chi_p < 0.05 | fish_p < 0.05,
         "Significant association detected",
         "No significant association detected")
))

# ------------------------------------------------------------------------------
# SECTION 6: Figure - Stacked proportional bar chart (Nature formatting)
# ------------------------------------------------------------------------------
fig1 <- edible_plants_clean %>%
  count(sunlight_recoded, water_recoded) %>%
  group_by(sunlight_recoded) %>%
  mutate(prop = n / sum(n)) %>%
  ggplot(aes(x = sunlight_recoded, y = prop, fill = water_recoded)) +
  geom_col(position = "fill", width = 0.6, color = "white", linewidth = 0.2) +
  scale_y_continuous(labels = scales::percent_format(), expand = c(0, 0)) +
  scale_fill_brewer(palette = "Blues", name = "Water\nRequirement") +
  labs(
    title   = "Water Requirement by Sunlight Category",
    x       = "Sunlight requirement",
    y       = "Proportion of species",
    caption = "Fig. 1 | n = 140. Full Sun n = 87, Full Sun/Partial Shade n = 44, Partial Shade or More n = 9."
  ) +
  theme_classic(base_size = 7, base_family = "Helvetica") +
  theme(
    plot.title      = element_text(size = 7, face = "bold"),
    plot.caption    = element_text(size = 5, color = "grey50", hjust = 0),
    axis.title      = element_text(size = 7),
    axis.text       = element_text(size = 6),
    axis.text.x     = element_text(angle = 15, hjust = 1),
    legend.title    = element_text(size = 7, face = "bold"),
    legend.text     = element_text(size = 6),
    legend.key.size = unit(3, "mm"),
    panel.grid      = element_blank()
  )

print(fig1)

# Save as Nature-formatted PDF (89 mm single column width)
ggsave(
  filename = "Fig1_sunlight_vs_water.pdf",
  plot     = fig1,
  device   = "pdf",
  width    = 89 / 25.4,
  height   = 70 / 25.4,
  units    = "in",
  dpi      = 300
)

cat("\nFig1_sunlight_vs_water.pdf saved to:", getwd(), "\n")
