# ==============================================================================
# VTPEH 6270 - Checkpoint 07: Shiny App
# Author: Naiya Patel
# Research Question: Is sunlight requirement associated with water requirement
#                    in edible plant species?
# Data: edible_plants (TidyTuesday 2026-02-03)
# ==============================================================================

# --- 0. Install & Load Packages -----------------------------------------------
if (!require(shiny))      install.packages("shiny")
if (!require(tidyverse))  install.packages("tidyverse")
if (!require(ggplot2))    install.packages("ggplot2")
if (!require(bslib))      install.packages("bslib")   # clean Bootstrap theme
if (!require(DT))         install.packages("DT")       # interactive tables

library(shiny)
library(tidyverse)
library(ggplot2)
library(bslib)
library(DT)


# --- 1. Load & Clean Data -----------------------------------------------------
# UPDATE this path to wherever your CSV lives, or use fileInput() below
edible_plants_raw <- read_csv("edible_plants.csv")

edible_plants_clean <- edible_plants_raw %>%
  mutate(
    sunlight_clean = str_trim(str_to_lower(sunlight)),
    water_clean    = str_trim(str_to_lower(water)),
    
    sunlight_recoded = case_when(
      sunlight_clean == "full sun"                              ~ "Full Sun",
      sunlight_clean == "full sun/partial shade"               ~ "Full Sun/Partial Shade",
      sunlight_clean %in% c("partial shade",
                            "full sun/partial shade/full shade",
                            "full sun/partial shade/ full shade") ~ "Partial Shade or More"
    ),
    
    water_recoded = case_when(
      water_clean %in% c("very low", "low") ~ "Low / Very Low",
      water_clean == "medium"               ~ "Medium",
      water_clean %in% c("high", "very high") ~ "High / Very High"
    ),
    
    sunlight_recoded = factor(sunlight_recoded,
                              levels = c("Full Sun",
                                         "Full Sun/Partial Shade",
                                         "Partial Shade or More")),
    water_recoded = factor(water_recoded,
                           levels = c("Low / Very Low", "Medium", "High / Very High"))
  ) %>%
  filter(!is.na(sunlight_recoded), !is.na(water_recoded))   # drop uncoded rows


# ==============================================================================
# UI
# ==============================================================================
ui <- page_navbar(
  title = "Edible Plants Explorer",
  theme = bs_theme(bootswatch = "flatly", base_font = font_google("Source Sans Pro")),
  
  # ── Tab 1: About ──────────────────────────────────────────────────────────
  nav_panel(
    title = "About",
    icon  = icon("seedling"),
    
    card(
      card_header("App Overview"),
      p("This app explores the relationship between ",
        strong("sunlight requirement"), " and ", strong("water requirement"),
        " in edible plant species using the TidyTuesday 2026-02-03 dataset."),
      p("Use the tabs above to:"),
      tags$ul(
        tags$li(strong("Explore:"), " visualize the distribution of water needs across sunlight categories."),
        tags$li(strong("Analyze:"), " run a statistical test of independence and view results interactively."),
        tags$li(strong("Data:"),    " browse the cleaned dataset.")
      ),
      hr(),
      h5("Research Question"),
      p(em("Is sunlight requirement associated with water requirement in edible plant species?")),
      hr(),
      h5("Scientific Context"),
      p("Plants adapted to high-sunlight environments typically experience greater evapotranspiration,
         increasing their water demand. Shade-tolerant species often grow in environments with higher
         soil moisture retention, reducing irrigation needs. Understanding whether these traits co-occur
         has practical implications for companion planting and sustainable garden design.")
    )
  ),
  
  # ── Tab 2: Explore ────────────────────────────────────────────────────────
  nav_panel(
    title = "Explore",
    icon  = icon("chart-bar"),
    
    layout_sidebar(
      sidebar = sidebar(
        title = "Plot Controls",
        
        # Plot type selector
        radioButtons(
          inputId  = "plot_type",
          label    = "Plot type",
          choices  = c("Stacked proportion bar" = "fill",
                       "Grouped count bar"      = "dodge",
                       "Heatmap (counts)"       = "heatmap"),
          selected = "fill"
        ),
        
        hr(),
        
        # Filter by sunlight
        checkboxGroupInput(
          inputId  = "sunlight_filter",
          label    = "Show sunlight categories",
          choices  = levels(edible_plants_clean$sunlight_recoded),
          selected = levels(edible_plants_clean$sunlight_recoded)
        ),
        
        hr(),
        helpText("Deselect categories to hide them from the plot.")
      ),
      
      # Main plot panel
      card(
        card_header("Water Requirement by Sunlight Category"),
        plotOutput("main_plot", height = "420px"),
        hr(),
        # ── INTERPRETATION PLACEHOLDER ──────────────────────────────────────
        card_body(
          h6("Interpretation", style = "color:#2c7a4b; font-weight:bold;"),
          p(id = "plot_interp",
            em("[PLACEHOLDER] Replace this text once you have your data.
                Describe what the chart shows: e.g., whether one sunlight group
                skews toward higher or lower water needs, or whether the
                distributions look similar across groups.]"))
        )
      )
    )
  ),
  
  # ── Tab 3: Analyze ────────────────────────────────────────────────────────
  nav_panel(
    title = "Analyze",
    icon  = icon("flask"),
    
    layout_sidebar(
      sidebar = sidebar(
        title = "Test Options",
        
        radioButtons(
          inputId  = "test_choice",
          label    = "Choose statistical test",
          choices  = c("Chi-square test"   = "chisq",
                       "Fisher's Exact Test (simulated p)" = "fisher"),
          selected = "chisq"
        ),
        
        hr(),
        actionButton("run_test", "Run Test",
                     icon = icon("play"),
                     class = "btn-success btn-lg w-100"),
        hr(),
        helpText("Fisher's Exact Test is recommended when expected cell counts < 5.")
      ),
      
      fluidRow(
        # Contingency table
        column(6,
               card(
                 card_header("Observed Counts"),
                 tableOutput("ct_observed")
               ),
               card(
                 card_header("Expected Counts"),
                 tableOutput("ct_expected")
               )
        ),
        # Test output
        column(6,
               card(
                 card_header("Test Results"),
                 verbatimTextOutput("test_output")
               ),
               card(
                 card_header("Interpretation"),
                 # ── INTERPRETATION PLACEHOLDER ─────────────────────────────────
                 uiOutput("test_interp")
               )
        )
      )
    )
  ),
  
  # ── Tab 4: Data ───────────────────────────────────────────────────────────
  nav_panel(
    title = "Data",
    icon  = icon("table"),
    
    card(
      card_header("Cleaned Dataset (sunlight & water columns shown)"),
      DTOutput("data_table")
    )
  )
)


# ==============================================================================
# SERVER
# ==============================================================================
server <- function(input, output, session) {
  
  # -- Reactive: filtered data ------------------------------------------------
  filtered_data <- reactive({
    edible_plants_clean %>%
      filter(sunlight_recoded %in% input$sunlight_filter)
  })
  
  # -- Plot -------------------------------------------------------------------
  output$main_plot <- renderPlot({
    df <- filtered_data()
    req(nrow(df) > 0)
    
    if (input$plot_type == "heatmap") {
      df %>%
        count(sunlight_recoded, water_recoded) %>%
        ggplot(aes(x = sunlight_recoded, y = water_recoded, fill = n)) +
        geom_tile(color = "white", linewidth = 0.8) +
        geom_text(aes(label = n), color = "white", size = 5, fontface = "bold") +
        scale_fill_gradient(low = "#a8d5ba", high = "#1a6b3c", name = "Count") +
        labs(title = "Heatmap: Count of Plants by Sunlight & Water",
             x = "Sunlight Requirement", y = "Water Requirement") +
        theme_minimal(base_size = 14) +
        theme(axis.text.x = element_text(angle = 15, hjust = 1))
      
    } else {
      pos <- if (input$plot_type == "fill") "fill" else "dodge"
      y_label <- if (input$plot_type == "fill") "Proportion of Plants" else "Count"
      
      p <- df %>%
        count(sunlight_recoded, water_recoded) %>%
        group_by(sunlight_recoded) %>%
        mutate(prop = n / sum(n)) %>%
        ggplot(aes(x = sunlight_recoded,
                   y = if (input$plot_type == "fill") prop else n,
                   fill = water_recoded)) +
        geom_col(position = pos, width = 0.7) +
        scale_fill_brewer(palette = "Blues", name = "Water Requirement") +
        labs(title = "Water Requirement by Sunlight Category",
             x = "Sunlight Requirement", y = y_label) +
        theme_minimal(base_size = 14) +
        theme(axis.text.x = element_text(angle = 15, hjust = 1))
      
      if (input$plot_type == "fill") {
        p <- p + scale_y_continuous(labels = scales::percent)
      }
      p
    }
  })
  
  # -- Contingency & expected tables ------------------------------------------
  ct_reactive <- reactive({
    table(filtered_data()$sunlight_recoded,
          filtered_data()$water_recoded)
  })
  
  output$ct_observed <- renderTable({
    as.data.frame.matrix(ct_reactive())
  }, rownames = TRUE)
  
  output$ct_expected <- renderTable({
    exp <- chisq.test(ct_reactive())$expected
    round(as.data.frame.matrix(exp), 2)
  }, rownames = TRUE)
  
  # -- Statistical test (triggered by button) ---------------------------------
  test_result <- eventReactive(input$run_test, {
    ct <- ct_reactive()
    if (input$test_choice == "chisq") {
      chisq.test(ct)
    } else {
      fisher.test(ct, simulate.p.value = TRUE)
    }
  })
  
  output$test_output <- renderPrint({
    req(test_result())
    test_result()
  })
  
  # -- Dynamic interpretation placeholder ------------------------------------
  output$test_interp <- renderUI({
    req(test_result())
    res <- test_result()
    p_val <- res$p.value
    test_name <- if (input$test_choice == "chisq") "Chi-square" else "Fisher's Exact"
    
    # Auto-fill significance language — replace narrative once data is confirmed
    sig_text <- if (p_val < 0.05) {
      "statistically significant (p < 0.05), suggesting an association between
       sunlight and water requirements."
    } else {
      "not statistically significant (p ≥ 0.05), suggesting no strong evidence
       of an association between sunlight and water requirements in this dataset."
    }
    
    tagList(
      p(strong(test_name, "Test")),
      p(sprintf("p-value = %.3f", p_val)),
      p(em(paste("[PLACEHOLDER] The result was", sig_text,
                 "Update this paragraph with your full written interpretation,
                  including effect size or practical significance if applicable.]")))
    )
  })
  
  # -- Data table -------------------------------------------------------------
  output$data_table <- renderDT({
    edible_plants_clean %>%
      select(plant_name = any_of(c("plant_name", "name", "species", "common_name")),
             sunlight, sunlight_recoded,
             water, water_recoded) %>%
      datatable(filter = "top",
                options = list(pageLength = 15, scrollX = TRUE),
                rownames = FALSE)
  })
}


# ==============================================================================
# RUN
# ==============================================================================
shinyApp(ui = ui, server = server)