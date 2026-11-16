## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  message = FALSE,
  warning = FALSE
)

## ----generate-script----------------------------------------------------------
library(drugsens)

out_dir <- tempdir()
generate_qupath_script(output_dir = out_dir)

script_lines <- readLines(file.path(out_dir, "script_for_qupath.txt"))
cat( paste(head(script_lines, 25), collapse = "\n") )

## ----single-drug--------------------------------------------------------------
single_df <- data.frame(
  Image = "B39_Ascites_2024-03-15_DOC2024-03-01_Niraparib_1000_nM_Rep_EpCAM_Ecad_cCasp3_(series 01).tif"
)

parsed_single <- string_parsing(single_df)
parsed_single[, c("PID", "Tissue", "Date1", "DOC", "Treatment",
                  "Concentration1", "ConcentrationUnits1", "Treatment_complete")]

## ----combo-drug---------------------------------------------------------------
combo_df <- data.frame(
  Image = "B38_Ascites_2024-03-15_DOC2024-03-01_CarboplatinPaclitaxel_100_uM_10_nM_Rep_EpCAM_cCasp3_(series 02).tif"
)

parsed_combo <- string_parsing(combo_df)
parsed_combo[, c("PID", "Treatment", "Concentration1", "ConcentrationUnits1",
                 "Concentration2", "ConcentrationUnits2", "Treatment_complete")]

## ----control-drug-------------------------------------------------------------
ctrl_df <- data.frame(
  Image = "B516_Ascites_2023-11-25_DOC2020-12-14_Control_rep_Ecad_cCasp3_(series 01).tif"
)

parsed_ctrl <- string_parsing(ctrl_df)
parsed_ctrl[, c("PID", "Tissue", "Treatment", "ReplicaOrNot", "Treatment_complete")]

## ----config-example-----------------------------------------------------------
cfg_dir <- tempdir()
make_run_config(overwrite_config = TRUE, forcePath = cfg_dir)

cat(readLines(file.path(cfg_dir, "config_drugsens.txt")), sep = "\n")

## ----custom-config-binding----------------------------------------------------
# 1. Create a dedicated config directory and write a custom config_drugsens.txt
custom_cfg_dir <- file.path(tempdir(), "custom_project_config")
dir.create(custom_cfg_dir, showWarnings = FALSE, recursive = TRUE)

writeLines(
  c(
    "# Custom marker relabeling map",
    "list_of_relabeling = list(",
    '  "PathCellObject" = "Stromal_DAPI_only",',
    '  "EpCAM_E-Cadherin: cCASP3" = "Early_Apoptotic_Tumor",',
    '  "EpCAM_E-Cadherin" = "Viable_Tumor",',
    '  "cCASP3" = "Late_Apoptotic"',
    ")"
  ),
  con = file.path(custom_cfg_dir, "config_drugsens.txt")
)

# 2. Pass forcePath to data_binding() so your custom config is loaded automatically
example_dir <- system.file("extdata/to_merge/", package = "drugsens")
custom_bound <- data_binding(
  path_to_the_projects_folder = example_dir,
  files_extension_to_look_for = "csv",
  forcePath = custom_cfg_dir
)

# 3. Verify that the custom marker names are now in the Name column
table(custom_bound$Name)

# Restore default config for subsequent sessions
make_run_config(overwrite_config = TRUE)

