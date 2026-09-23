#' Log a TMT training session to CSV
#'
#' Appends one row per trial to a persistent CSV log file. Creates the file
#' with headers on the first call. Use this after each trial during training
#' to build the dataset for your analysis.
#'
#' @param time_sec Numeric. Time in seconds from first touch to last element.
#' @param phase Character. One of \code{"letters"}, \code{"bigrams"},
#'   \code{"words"}, \code{"mixed"}. Describes the stimulus type used.
#' @param week Integer. Training week number (1--5).
#' @param session Integer. Session number within the week (1--5).
#' @param trial Integer. Trial number within the session (1--3).
#' @param seed Integer. The seed used to generate the test sheet.
#'   Record the seed printed on the sheet or from \code{stimulus_schedule}.
#' @param N Integer. Number of items in the sequence. Default \code{13}.
#' @param errors Integer. Number of wrong connections made. Default \code{0}.
#' @param backtracks Integer. Number of times you had to undo and redo a
#'   connection. Default \code{0}.
#' @param fatigue Integer 1--5. Self-rated fatigue \emph{before} the trial.
#'   1 = very fresh, 5 = very tired. Default \code{NA}.
#' @param notes Character. Free-text notes. Default \code{""}.
#' @param log_file Character. Path to the CSV log file. Created if it does not
#'   exist. Default \code{"data/sessions.csv"}.
#'
#' @return Invisibly returns the appended data frame row.
#'
#' @examples
#' \dontrun{
#' log_session(
#'   time_sec  = 47.3,
#'   phase     = "letters",
#'   week      = 1,
#'   session   = 1,
#'   trial     = 1,
#'   seed      = 1011,
#'   fatigue   = 2,
#'   notes     = "First ever session."
#' )
#' }
#'
#' @export
log_session <- function(time_sec,
                        phase,
                        week,
                        session,
                        trial,
                        seed,
                        N         = 13,
                        errors    = 0,
                        backtracks = 0,
                        fatigue   = NA,
                        notes     = "",
                        log_file  = "data/sessions.csv") {

  # --- Validate required args ---
  if (!is.numeric(time_sec) || length(time_sec) != 1 || time_sec <= 0)
    stop("'time_sec' must be a single positive number.")
  if (!phase %in% c("letters", "bigrams", "words", "mixed"))
    stop("'phase' must be one of: letters, bigrams, words, mixed.")
  for (arg in list(week = week, session = session, trial = trial,
                   seed = seed, N = N)) {
    nm <- names(arg)
    if (!is.numeric(arg[[1]]) || length(arg[[1]]) != 1)
      stop(sprintf("'%s' must be a single number.", nm))
  }

  entry <- data.frame(
    timestamp    = format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
    week         = as.integer(week),
    session      = as.integer(session),
    trial        = as.integer(trial),
    phase        = phase,
    N            = as.integer(N),
    seed         = as.integer(seed),
    time_sec     = round(as.numeric(time_sec), 2),
    items_per_sec = round(N / time_sec, 4),
    errors       = as.integer(errors),
    backtracks   = as.integer(backtracks),
    fatigue      = fatigue,
    notes        = as.character(notes),
    stringsAsFactors = FALSE
  )

  log_dir <- dirname(log_file)
  if (!dir.exists(log_dir)) dir.create(log_dir, recursive = TRUE)

  if (file.exists(log_file)) {
    write.table(entry, log_file, append = TRUE, sep = ",",
                col.names = FALSE, row.names = FALSE, quote = TRUE)
  } else {
    write.csv(entry, log_file, row.names = FALSE)
  }

  cat(sprintf(
    "✓ Logged  Week %d | Session %d | Trial %d | Phase: %-8s | %.1f sec | %.3f items/sec\n",
    week, session, trial, phase, time_sec, N / time_sec
  ))

  invisible(entry)
}
