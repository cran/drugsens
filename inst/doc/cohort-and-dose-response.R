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

## ----load-cohort--------------------------------------------------------------
library(drugsens)
library(ggplot2)

example_dir <- system.file("extdata/to_merge/", package = "drugsens")
bind_data <- data_binding(
  path_to_the_projects_folder = example_dir,
  files_extension_to_look_for = "csv"
)

counts_df <- make_count_dataframe(bind_data)
long_df <- change_data_format_to_longer(counts_df)

# Inspect patients, treatments, and marker populations in the dataset
unique(long_df[, c("PID", "Tissue", "Treatment")])
unique(long_df$marker_positivity)

## ----normalize-step, fig.height = 5.5-----------------------------------------
norm_df <- normalize_to_control(
  long_df,
  dead_markers = c("cCASP3", "E-Cadherin and cCASP3"),
  viable_markers = "E-Cadherin",
  control_treatment_name = "Control",
  treatment_column_name = "Treatment",
  group_by_columns = "PID",
  consensus_only = TRUE
)

head(norm_df[, c("PID", "Treatment", "Concentration1", "dead_fraction", "viable_fraction", "pct_of_control")])

plot_normalization_before_after(norm_df)

## ----dr-loess-----------------------------------------------------------------
plot_dose_response(
  norm_df,
  selected_treatments = "Paclitaxel",
  method = "loess"
)

## ----dr-4pl-------------------------------------------------------------------
p_4pl <- plot_dose_response(
  norm_df,
  selected_treatments = "Paclitaxel",
  method = "4pl",
  show_ic50 = TRUE
)
p_4pl

# Inspect estimated IC50 and Hill parameters per patient
attr(p_4pl, "ic50")

## ----dr-multi-consensus, fig.height = 5.8-------------------------------------
p_multi <- plot_dose_response(
  long_df,
  viable_markers = "E-Cadherin",
  dead_markers = c("cCASP3", "E-Cadherin and cCASP3"),
  control_treatment_name = "Control",
  selected_treatments = "Paclitaxel",
  method = "4pl",
  show_ic50 = TRUE,
  consensus_dispersion = "cv",
  show_cv = TRUE
)
p_multi

# Consensus IC50 from the combined markers:
attr(p_multi, "consensus_ic50")[, c("PID", "ic50", "hill_slope", "bottom", "top")]

# Per-point CV and dispersion metrics on the Consensus curve:
head(attr(p_multi, "consensus_cv")[, c("PID", "Concentration1", "mean_pct_of_control", "sd", "cv", "rcvq", "rcv_mad")])

## ----dr-heatmap---------------------------------------------------------------
norm_panel <- norm_df[norm_df$Treatment %in% c("Control", "Paclitaxel", "NIRAPARIB"), ]
plot_dose_response_heatmap(norm_panel, show_values = TRUE)

## ----treatment-summary--------------------------------------------------------
p_sum <- plot_treatment_summary(
  norm_df,
  compare_to_control = TRUE,
  stat_method = "wilcox",
  p_adjust_method = "BH",
  pvalue_label = "p.adj.signif"
)
p_sum

# Inspect raw p_value and BH-adjusted p_adj per treatment
attr(p_sum, "stats")[, c("group", "p_value", "p_adj", "p_adjust_method", "label")]

## ----patient-heatmap----------------------------------------------------------
plot_patient_heatmap(
  norm_df,
  show_values = TRUE,
  compare_to_control = TRUE,
  stat_method = "wilcox",
  p_adjust_method = "BH",
  pvalue_label = "p.adj.signif"
)

## ----custom-theme, fig.height = 5---------------------------------------------
ic50_df <- attr(p_multi, "consensus_ic50")

ggplot(ic50_df, aes(x = PID, y = ic50, fill = PID, color = PID)) +
  geom_col(width = 0.42, alpha = 0.82, color = NA) +
  geom_point(size = 3.4, shape = 21, color = "#fcfcfb", stroke = 0.6) +
  geom_text(
    aes(label = sprintf("%.1f uM", ic50)),
    vjust = -0.8,
    fontface = "bold",
    size = 4.0,
    color = "#0b0b0b"
  ) +
  scale_fill_manual(values = unname(drugsens_palette)) +
  scale_color_manual(values = unname(drugsens_palette)) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.22))) +
  labs(
    title = "Consensus Paclitaxel IC50 by Patient",
    subtitle = "Calculated directly from the package dataset (E-Cadherin viable vs. cCASP3 + E-Cadherin/cCASP3 dead)",
    x = "Patient ID",
    y = "Consensus IC50 (uM)"
  ) +
  drugsens_theme() +
  theme(
    panel.grid.major.x = element_blank(),
    legend.position = "none"
  )

