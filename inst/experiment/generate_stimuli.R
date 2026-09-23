# Generate all 75 test sheets for the Arabic TMT training experiment.
#
# Output: inst/experiment/sheets/{week}_{session}_{trial}_{phase}_seed{seed}.png
#
# Run from the package root:
#   Rscript inst/experiment/generate_stimuli.R
#
# Each PNG is a ready-to-print A4-proportioned test sheet (8x8 inches, 150 dpi
# for screen; change dpi to 300 for print-quality).

# --- Setup ---------------------------------------------------------------

pkg_root <- if (nzchar(Sys.getenv("TMTMAKER_ROOT"))) {
  Sys.getenv("TMTMAKER_ROOT")
} else {
  normalizePath(".")
}

for (f in c("R/validate_params.R", "R/get_letter_set.R",
            "R/generate_tmt_plot.R", "R/print_tmt_copies.R")) {
  source(file.path(pkg_root, f))
}
source(file.path(pkg_root, "inst/experiment/stimulus_schedule.R"))

out_dir <- file.path(pkg_root, "inst/experiment/sheets")
if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)

stim_lists <- attr(stimulus_schedule, "stim_lists")

# --- Generate ------------------------------------------------------------

results <- vector("list", nrow(stimulus_schedule))

for (i in seq_len(nrow(stimulus_schedule))) {
  row   <- stimulus_schedule[i, ]
  stims <- stim_lists[[as.character(row$week)]]
  nums  <- as.character(seq_len(row$N))

  fname <- sprintf("w%d_s%d_t%d_%s_seed%d.png",
                   row$week, row$session, row$trial, row$phase, row$seed)
  fpath <- file.path(out_dir, fname)

  result <- tryCatch({
    p <- generate_tmt_plot(
      number_list  = nums,
      letter_list  = stims,
      N            = row$N,
      type         = row$tmt_type,
      seed         = row$seed,
      min_distance = 1.0,
      element_size = 6
    )

    ggplot2::ggsave(
      filename = fpath,
      plot     = p,
      width    = 8,
      height   = 8,
      dpi      = 150,
      bg       = "white"
    )

    list(status = "OK", file = fpath)
  }, error = function(e) {
    list(status = paste("ERROR:", conditionMessage(e)), file = fpath)
  })

  results[[i]] <- c(as.list(row), result)
  cat(sprintf("[%2d/75] Week %d | Sess %d | Trial %d | %-8s | %s\n",
              i, row$week, row$session, row$trial, row$phase, result$status))
}

# --- Summary -------------------------------------------------------------

ok    <- sum(vapply(results, function(r) r$status == "OK", logical(1)))
fails <- 75 - ok
cat(sprintf("\nDone: %d/75 sheets generated", ok))
if (fails > 0) {
  cat(sprintf(" (%d failed)", fails))
  failed_rows <- Filter(function(r) r$status != "OK", results)
  for (r in failed_rows) cat(sprintf("  FAIL: %s — %s\n", r$file, r$status))
}
cat(sprintf("\nSheets saved to: %s\n", out_dir))
