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

## ----qc-step1-----------------------------------------------------------------
library(drugsens)

example_dir <- system.file("extdata/to_merge/", package = "drugsens")
bind_data <- data_binding(
  path_to_the_projects_folder = example_dir,
  files_extension_to_look_for = "csv"
)

counts_df <- make_count_dataframe(bind_data)
summary(counts_df[, c("sum_cells", "cCASP3_ratio_of_total_cells",
                      "E-Cadherin_ratio_of_total_cells", "onlyDAPIPositve_ratio_of_total_cells")])

## ----qc-step2-----------------------------------------------------------------
long_df <- change_data_format_to_longer(counts_df)
head(long_df[, c("PID", "Tissue", "Treatment_complete", "Image_number",
                 "marker_positivity", "marker_positivity_ratio")])

## ----qc-patient-b39-----------------------------------------------------------
get_QC_plots(
  long_df,
  isolate_a_specific_patient = "B39",
  save_plots = FALSE
)

## ----qc-patient-stats---------------------------------------------------------
get_QC_plots(
  long_df,
  isolate_a_specific_patient = "B39",
  x_plot_var = "Treatment",
  compare_to_control = TRUE,
  control_treatment_name = "Control",
  stat_method = "wilcox",
  p_adjust_method = "BH",
  pvalue_label = "p.adj.signif",
  save_plots = FALSE
)

## ----qc-violin-tissue---------------------------------------------------------
plots_by_tissue <- get_QC_plots_parsed_merged_data(
  long_df,
  list_of_columns_to_plot = "marker_positivity_ratio",
  fill_color_variable = "Tissue",
  isolate_specific_patient = "A8759",
  save_plots = FALSE,
  verbose = FALSE
)

plots_by_tissue[["A8759.marker_positivity_ratio"]]

## ----qc-violin-dose-----------------------------------------------------------
plots_by_dose <- get_QC_plots_parsed_merged_data(
  long_df,
  list_of_columns_to_plot = "marker_positivity_ratio",
  fill_color_variable = "Treatment_complete",
  isolate_specific_patient = "B38",
  save_plots = FALSE,
  verbose = FALSE
)

plots_by_dose[["B38.marker_positivity_ratio"]]

