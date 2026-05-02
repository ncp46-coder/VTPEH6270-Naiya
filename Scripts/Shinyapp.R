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
if (!require(bslib))      install.packages("bslib")
if (!require(DT))         install.packages("DT")

library(shiny)
library(tidyverse)
library(ggplot2)
library(bslib)
library(DT)

dataTableOutput <- DT::dataTableOutput
renderDataTable <- DT::renderDataTable

# --- 1. Load & Clean Data -----------------------------------------------------
edible_plants_raw <- read_csv(
  "/Users/naiyapatel/Desktop/VTPEH6270-Naiya/Checkpoint7ShinyApp/edible_plants copy.csv",
  show_col_types = FALSE
)

edible_plants_clean <- edible_plants_raw %>%
  mutate(
    sunlight_clean = str_trim(str_to_lower(sunlight)),
    water_clean    = str_trim(str_to_lower(water)),
    sunlight_recoded = case_when(
      sunlight_clean == "full sun"               ~ "Full Sun",
      sunlight_clean == "full sun/partial shade" ~ "Full Sun/Partial Shade",
      sunlight_clean %in% c("partial shade",
                             "full sun/partial shade/full shade",
                             "full sun/partial shade/ full shade") ~ "Partial Shade or More"
    ),
    water_recoded = case_when(
      water_clean %in% c("very low", "low")    ~ "Low / Very Low",
      water_clean == "medium"                   ~ "Medium",
      water_clean %in% c("high", "very high")  ~ "High / Very High"
    ),
    sunlight_recoded = factor(sunlight_recoded,
                              levels = c("Full Sun",
                                         "Full Sun/Partial Shade",
                                         "Partial Shade or More")),
    water_recoded = factor(water_recoded,
                           levels = c("Low / Very Low", "Medium", "High / Very High"))
  ) %>%
  filter(!is.na(sunlight_recoded), !is.na(water_recoded))


# ==============================================================================
# UI
# ==============================================================================
ui <- page_navbar(
  title = "Edible Plants Explorer",
  theme = bs_theme(bootswatch = "flatly", base_font = font_google("Source Sans Pro")),

  # -- Tab 1: About -------------------------------------------------------------
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
        soil moisture retention, reducing irrigation needs."),
      hr(),
      h5("Author"),
      p("Naiya Patel | Cornell University | VTPEH 6270 | Spring 2026"),
      hr(),
      h5("Data Source"),
      p(tags$a(
        href   = "https://github.com/rfordatascience/tidytuesday/blob/main/data/2026/2026-02-03/edible_plants.csv",
        "TidyTuesday edible_plants dataset (2026-02-03)",
        target = "_blank"
      )),
      hr(),
      h5("GitHub Repository"),
      p(tags$a(
        href   = "https://github.com/ncp46-coder/VTPEH6270-Naiya",
        "github.com/ncp46-coder/VTPEH6270-Naiya",
        target = "_blank"
      )),
      hr(),
      h5("AI Use Disclosure"),
      p("This app was produced with assistance from Claude (Anthropic) for:"),
      tags$ul(
        tags$li("Data cleaning: identifying variables with fewest missing values"),
        tags$li("Code debugging: contingency table and Fisher's Exact Test"),
        tags$li("Formatting: UI layout and Shiny app structure")
      ),
      p(em("All analytical decisions and interpretations are the author's own."))
    ) # <-- closes card()
  ), # <-- closes nav_panel() About

  # -- Tab 2: Explore -----------------------------------------------------------
  nav_panel(
    title = "Explore",
    icon  = icon("chart-bar"),
    layout_sidebar(
      sidebar = sidebar(
        title = "Plot Controls",
        radioButtons(
          inputId  = "plot_type",
          label    = "Plot type",
          choices  = c("Stacked proportion bar" = "fill",
                       "Grouped count bar"      = "dodge",
                       "Heatmap (counts)"       = "heatmap"),
          selected = "fill"
        ),
        hr(),
        checkboxGroupInput(
          inputId  = "sunlight_filter",
          label    = "Show sunlight categories",
          choices  = levels(edible_plants_clean$sunlight_recoded),
          selected = levels(edible_plants_clean$sunlight_recoded)
        ),
        hr(),
        helpText("Deselect categories to hide them from the plot.")
      ),
      card(
        card_header("Water Requirement by Sunlight Category"),
        plotOutput("main_plot", height = "420px"),
        hr(),
        card_body(
          h6("Interpretation", style = "color:#2c7a4b; font-weight:bold;"),
          p("While Partial Shade or More plants appear to have a slightly higher
            proportion of High/Very High water requirements, the distributions
            across sunlight categories are broadly similar, consistent with the
            non-significant test results.")
        )
      )
    )
  ), # <-- closes nav_panel() Explore

  # -- Tab 3: Analyze -----------------------------------------------------------
  nav_panel(
    title = "Analyze",
    icon  = icon("flask"),
    layout_sidebar(
      sidebar = sidebar(
        title = "Test Options",
        radioButtons(
          inputId  = "test_choice",
          label    = "Choose statistical test",
          choices  = c("Chi-square test"                   = "chisq",
                       "Fisher's Exact Test (simulated p)" = "fisher"),
          selected = "chisq"
        ),
        hr(),
        actionButton("run_test", "Run Test",
                     icon  = icon("play"),
                     class = "btn-success btn-lg w-100"),
        hr(),
        helpText("Fisher's Exact Test is recommended when expected cell counts < 5.")
      ),
      fluidRow(
        column(6,
          card(card_header("Observed Counts"), tableOutput("ct_observed")),
          card(card_header("Expected Counts"), tableOutput("ct_expected"))
        ),
        column(6,
          card(card_header("Test Results"),    verbatimTextOutput("test_output")),
          card(card_header("Interpretation"),  uiOutput("test_interp"))
        )
      )
    )
  ), # <-- closes nav_panel() Analyze

  # -- Tab 4: Data --------------------------------------------------------------
  nav_panel(
    title = "Data",
    icon  = icon("table"),
    card(
      card_header("Cleaned Dataset (sunlight & water columns shown)"),
      DTOutput("data_table")
    )
  ) # <-- closes nav_panel() Data

) # <-- closes page_navbar()


# ==============================================================================
# SERVER
# ==============================================================================
server <- function(input, output, session) {

  # Reactive filtered data
  filtered_data <- reactive({
    edible_plants_clean %>%
      filter(sunlight_recoded %in% input$sunlight_filter)
  })

  # Plot
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
      plot_data <- df %>%
        count(sunlight_recoded, water_recoded) %>%
        group_by(sunlight_recoded) %>%
        mutate(prop = n / sum(n))

      pos     <- if (input$plot_type == "fill") "fill" else "dodge"
      y_label <- if (input$plot_type == "fill") "Proportion of Plants" else "Count"

      if (input$plot_type == "fill") {
        p <- ggplot(plot_data, aes(x = sunlight_recoded, y = prop, fill = water_recoded))
      } else {
        p <- ggplot(plot_data, aes(x = sunlight_recoded, y = n, fill = water_recoded))
      }

      p <- p +
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

  # Contingency tables
  ct_reactive <- reactive({
    table(filtered_data()$sunlight_recoded,
          filtered_data()$water_recoded)
  })

  output$ct_observed <- renderTable({
    as.data.frame.matrix(ct_reactive())
  }, rownames = TRUE)

  output$ct_expected <- renderTable({
    round(as.data.frame.matrix(chisq.test(ct_reactive())$expected), 2)
  }, rownames = TRUE)

  # Statistical test
  test_result <- eventReactive(input$run_test, {
    ct <- ct_reactive()
    if (input$test_choice == "chisq") chisq.test(ct) else fisher.test(ct, simulate.p.value = TRUE)
  })

  output$test_output <- renderPrint({
    req(test_result())
    test_result()
  })

  output$test_interp <- renderUI({
    req(test_result())
    res       <- test_result()
    p_val     <- res$p.value
    test_name <- if (input$test_choice == "chisq") "Chi-square" else "Fisher's Exact"
    tagList(
      p(strong(paste(test_name, "Test"))),
      p(sprintf("p-value = %.3f", p_val)),
      p(if (p_val < 0.05) {
        "The result is statistically significant (p < 0.05)."
      } else {
        "No statistically significant association was detected (p >= 0.05).
         Sunlight category alone is not a reliable predictor of water needs in this dataset."
      })
    )
  })

  # Data table
  output$data_table <- renderDT({
    edible_plants_clean %>%
      select(any_of(c("plant_name", "name", "species", "common_name")),
             sunlight, sunlight_recoded,
             water, water_recoded) %>%
      datatable(filter   = "top",
                options  = list(pageLength = 15, scrollX = TRUE),
                rownames = FALSE)
  })
}


# ==============================================================================
# RUN
# ==============================================================================
shinyApp(ui = ui, server = server)
