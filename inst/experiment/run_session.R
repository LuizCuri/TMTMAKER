# Arabic TMT Training — Interactive Session Runner
#
# This script walks you through one complete session (3 trials).
# It auto-detects where you are in the schedule, times each trial,
# and logs everything to data/sessions.csv automatically.
#
# HOW TO RUN (from RStudio console):
#   source("inst/experiment/run_session.R")

# --- Setup ---------------------------------------------------------------

pkg_root <- normalizePath(".")
for (f in c("R/validate_params.R", "R/get_letter_set.R",
            "R/generate_tmt_plot.R", "R/print_tmt_copies.R",
            "R/log_session.R")) {
  source(file.path(pkg_root, f))
}
source(file.path(pkg_root, "inst/experiment/stimulus_schedule.R"))

log_file  <- file.path(pkg_root, "data/sessions.csv")
sheet_dir <- file.path(pkg_root, "inst/experiment/sheets")

# --- Helpers -------------------------------------------------------------

hr <- function() cat(strrep("-", 55), "\n")
hdr <- function(txt) { cat("\n"); hr(); cat(" ", txt, "\n"); hr() }
pause <- function(msg = "Press ENTER to continue...") {
  cat(msg); readline()
}

countdown <- function(seconds) {
  cat(sprintf("\n  Resting for %d seconds...\n", seconds))
  end <- Sys.time() + seconds
  while (Sys.time() < end) {
    remaining <- as.numeric(end - Sys.time(), units = "secs")
    cat(sprintf("\r  %2d sec remaining  ", ceiling(remaining)))
    Sys.sleep(0.5)
  }
  cat("\r  Rest complete. Ready!          \n")
}

ask_int <- function(prompt, min = 0, max = 99) {
  repeat {
    cat(prompt)
    val <- suppressWarnings(as.integer(readline()))
    if (!is.na(val) && val >= min && val <= max) return(val)
    cat(sprintf("  Please enter a whole number between %d and %d.\n", min, max))
  }
}

time_trial <- function() {
  pause("  >> Press ENTER to START timing ")
  t_start <- Sys.time()
  pause("  >> Press ENTER to STOP  timing ")
  t_end   <- Sys.time()
  round(as.numeric(t_end - t_start, units = "secs"), 1)
}

# --- Detect position in schedule -----------------------------------------

if (file.exists(log_file)) {
  done <- read.csv(log_file, stringsAsFactors = FALSE)
  last <- done[nrow(done), ]
  # Next trial after the last logged one
  next_week    <- last$week
  next_session <- last$session
  next_trial   <- last$trial + 1
  if (next_trial > 3) { next_trial <- 1; next_session <- next_session + 1 }
  if (next_session > 5) { next_session <- 1; next_week <- next_week + 1 }
} else {
  next_week <- 1; next_session <- 1; next_trial <- 1
}

if (next_week > 5) {
  cat("\n  All 5 weeks complete! Time to run the final analysis.\n")
  cat("  Run: Rscript analysis/weekly_report.R\n\n")
  stop("Experiment complete.", call. = FALSE)
}

# Trials in this session
session_rows <- stimulus_schedule[
  stimulus_schedule$week == next_week &
  stimulus_schedule$session == next_session, ]

# --- Pre-session screen --------------------------------------------------

hdr(sprintf("ARABIC TMT TRAINING  |  Week %d of 5  |  Session %d of 5",
            next_week, next_session))

phase_desc <- c(
  letters = "Isolated Arabic letters  (connect 1 → 2 → ... → 13)",
  bigrams = "2-letter Arabic words    (connect 1 → 2 → ... → 13)",
  words   = "3-letter Arabic words    (connect 1 → 2 → ... → 13)",
  mixed   = "Letters + numbers mixed  (connect 1 → ا → 2 → ب → ...)"
)
ph <- session_rows$phase[1]
cat(sprintf("\n  Phase : %s\n", ph))
cat(sprintf("  Task  : %s\n", phase_desc[ph]))
cat(sprintf("  Trials: 3   |   Rest between trials: 2 minutes\n\n"))

# Setup checklist
hdr("SETUP CHECKLIST  (answer y/n)")
checks <- c(
  "Seated comfortably with good posture?",
  "Screen distance 50-60 cm (or sheet on flat surface)?",
  "Room lighting normal (not too dim, no glare)?",
  "No interruptions expected for ~15 minutes?"
)
for (ch in checks) {
  repeat {
    cat(sprintf("  [ ] %s  (y/n): ", ch))
    ans <- tolower(trimws(readline()))
    if (ans == "y") { break }
    if (ans == "n") cat("      -> Fix this before continuing.\n")
  }
}

fatigue <- ask_int("\n  Fatigue right now (1=fresh, 5=exhausted): ", 1, 5)

# --- Run 3 trials --------------------------------------------------------

results <- list()

for (i in seq_len(nrow(session_rows))) {
  row <- session_rows[i, ]

  hdr(sprintf("TRIAL %d of 3  |  Seed %d", i, row$seed))

  sheet_name <- sprintf("w%d_s%d_t%d_%s_seed%d.png",
                        row$week, row$session, i, row$phase, row$seed)
  sheet_path <- file.path(sheet_dir, sheet_name)

  if (file.exists(sheet_path)) {
    cat(sprintf("\n  Sheet file: %s\n", sheet_name))
    cat("  Open / reveal this sheet now. Do NOT look at it yet.\n")
  } else {
    cat(sprintf("  WARNING: Sheet file not found: %s\n", sheet_path))
    cat("  Run generate_stimuli.R first to create the sheets.\n")
    pause("  Press ENTER to continue anyway (no sheet shown)... ")
  }

  pause("\n  When the sheet is in position and hidden, press ENTER... ")

  cat("\n  Ready?\n")
  cat("  On the next ENTER: REVEAL the sheet and start connecting.\n")
  elapsed <- time_trial()

  cat(sprintf("\n  Time: %.1f seconds  (%.3f items/sec)\n",
              elapsed, row$N / elapsed))

  errors     <- ask_int("  Wrong connections (errors): ", 0, 20)
  backtracks <- ask_int("  Backtracks (undo + redo):   ", 0, 20)
  cat("  Notes (press ENTER to skip): ")
  notes <- readline()

  log_session(
    time_sec   = elapsed,
    phase      = row$phase,
    week       = row$week,
    session    = row$session,
    trial      = i,
    seed       = row$seed,
    N          = row$N,
    errors     = errors,
    backtracks = backtracks,
    fatigue    = if (i == 1) fatigue else NA,
    notes      = notes,
    log_file   = log_file
  )

  results[[i]] <- list(time = elapsed, ips = row$N / elapsed,
                       errors = errors)

  if (i < nrow(session_rows)) countdown(120)
}

# --- Session summary -----------------------------------------------------

hdr("SESSION COMPLETE")
cat(sprintf("  Week %d | Session %d\n\n", next_week, next_session))
cat("  Trial |  Time (s)  | Items/sec | Errors\n")
cat("  ------|------------|-----------|-------\n")
for (i in seq_along(results)) {
  r <- results[[i]]
  cat(sprintf("    %d   |   %6.1f   |   %.3f   |   %d\n",
              i, r$time, r$ips, r$errors))
}

times <- vapply(results, `[[`, numeric(1), "time")
cat(sprintf("\n  Mean: %.1f sec  |  Best: %.1f sec  |  Worst: %.1f sec\n",
            mean(times), min(times), max(times)))

# Next session hint
if (next_session < 5) {
  cat(sprintf("\n  Next session: Week %d | Session %d  (come back tomorrow)\n",
              next_week, next_session + 1))
} else if (next_week < 5) {
  cat(sprintf("\n  Week %d complete! Run the weekly report:\n", next_week))
  cat(sprintf("  source(\"analysis/weekly_report.R\")\n"))
  cat(sprintf("  Then start Week %d tomorrow.\n", next_week + 1))
} else {
  cat("\n  All sessions done! Run the final analysis:\n")
  cat("  source(\"analysis/weekly_report.R\")\n")
}

hr()
cat("\n")
