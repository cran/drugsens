## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.width = 10,
  fig.height = 7,
  dpi = 150,
  out.width = "100%",
  message = FALSE,
  warning = FALSE
)

## ----quickstart-bind----------------------------------------------------------
library(drugsens)

example_dir <- system.file("extdata/to_merge/", package = "drugsens")
bind_data <- data_binding(
  path_to_the_projects_folder = example_dir,
  files_extension_to_look_for = "csv"
)

head(bind_data[, c("PID", "Tissue", "Treatment", "Concentration1", "ConcentrationUnits1", "Name")])

## ----quickstart-count---------------------------------------------------------
counts_df <- make_count_dataframe(bind_data)
long_df <- change_data_format_to_longer(counts_df)

head(long_df[, c("PID", "Tissue", "Treatment_complete", "marker_positivity", "marker_positivity_ratio")])

## ----quickstart-qc------------------------------------------------------------
get_QC_plots(
  long_df,
  isolate_a_specific_patient = "B39",
  x_plot_var = "Treatment",
  compare_to_control = TRUE,
  save_plots = FALSE
)

## ----quickstart-qc-cohort-----------------------------------------------------
qc_list <- get_QC_plots_parsed_merged_data(
  long_df,
  list_of_columns_to_plot = "marker_positivity_ratio",
  fill_color_variable = "Treatment_complete",
  isolate_specific_patient = "B38",
  save_plots = FALSE,
  verbose = FALSE
)

qc_list[["B38.marker_positivity_ratio"]]

## ----quickstart-norm----------------------------------------------------------
norm_df <- normalize_to_control(
  long_df,
  dead_markers = c("cCASP3", "E-Cadherin and cCASP3"),
  viable_markers = "E-Cadherin",
  control_treatment_name = "Control",
  consensus_only = TRUE
)

plot_treatment_summary(norm_df, compare_to_control = TRUE)

