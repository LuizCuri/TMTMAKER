# generate_all_scripts.R
#
# Generates one TMT-B stimulus image for every supported script and saves the
# results to inst/examples/output/.  Run from the package root:
#
#   Rscript inst/examples/generate_all_scripts.R
#

# Locate the package root relative to this script's location
script_dir  <- tryCatch(
  dirname(normalizePath(sys.frame(0)$ofile, winslash = "/")),
  error = function(e) "."
)
pkg_root    <- normalizePath(file.path(script_dir, "..", ".."), winslash = "/")
output_dir  <- file.path(pkg_root, "inst", "examples", "output")

if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)

# Load the package (works whether installed or sourced in-situ)
if (!requireNamespace("TMTMAKER", quietly = TRUE)) {
  devtools::load_all(pkg_root)
} else {
  library(TMTMAKER)
}

# All scripts with how many characters to use (capped to script max)
script_config <- list(
  latin          = 13,
  latin_extended = 13,
  greek          = 13,
  cyrillic       = 13,
  hebrew         = 13,
  arabic         = 13,
  armenian       = 13,
  georgian       = 13,
  hiragana       = 13,
  katakana       = 13,
  ethiopic       = 13,
  devanagari     = 13,
  thai           = 13,
  korean         = 13
)

numbers <- as.character(1:13)

results <- list()

for (sc in names(script_config)) {
  n_chars <- script_config[[sc]]
  out_file <- file.path(output_dir, paste0("tmt_B_", sc, ".png"))

  result <- tryCatch({
    letters_sc <- get_letter_set(sc, n_chars)

    p <- generate_tmt_plot(
      number_list  = numbers,
      letter_list  = letters_sc,
      min_distance = 1.2,
      element_size = 6,
      N            = n_chars,
      type         = "B",
      seed         = 42
    )

    ggplot2::ggsave(
      filename = out_file,
      plot     = p,
      width    = 8,
      height   = 8,
      dpi      = 150,
      bg       = "white"
    )

    list(status = "OK", file = out_file)
  }, error = function(e) {
    list(status = "ERROR", message = conditionMessage(e))
  })

  results[[sc]] <- result
  cat(sprintf("[%s] %-15s -> %s\n",
              result$status, sc,
              if (result$status == "OK") result$file else result$message))
}

# Summary
cat("\n--- Summary ---\n")
ok_scripts  <- names(results)[vapply(results, function(r) r$status == "OK",  logical(1))]
err_scripts <- names(results)[vapply(results, function(r) r$status == "ERROR", logical(1))]

cat(sprintf("Success (%d): %s\n", length(ok_scripts),  paste(ok_scripts,  collapse = ", ")))
cat(sprintf("Failed  (%d): %s\n", length(err_scripts), paste(err_scripts, collapse = ", ")))

# List generated files
if (length(ok_scripts) > 0) {
  cat("\nGenerated files:\n")
  for (sc in ok_scripts) {
    cat(sprintf("  %s\n", results[[sc]]$file))
  }
}
