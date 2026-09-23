# Weekly analysis report for the Arabic TMT training experiment.
#
# Usage (run from package root after logging at least one week of sessions):
#   Rscript analysis/weekly_report.R
#   Rscript analysis/weekly_report.R --week 2   # report for a specific week
#
# Outputs:
#   analysis/output/learning_curve.png
#   analysis/output/weekly_boxplot.png
#   analysis/output/summary_table.csv
#   analysis/output/report_week{N}.txt  (plain-text summary for the paper)

suppressPackageStartupMessages({
  library(ggplot2)
})

# --- Config --------------------------------------------------------------

args <- commandArgs(trailingOnly = TRUE)
target_week <- NULL
for (i in seq_along(args)) {
  if (args[i] == "--week" && i < length(args))
    target_week <- as.integer(args[i + 1])
}

log_file <- "data/sessions.csv"
out_dir  <- "analysis/output"

if (!file.exists(log_file)) {
  stop("No session log found at '", log_file,
       "'. Run log_session() after each trial to build it.")
}

if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)

# --- Load data -----------------------------------------------------------

df <- read.csv(log_file, stringsAsFactors = FALSE)
df$timestamp <- as.POSIXct(df$timestamp, format = "%Y-%m-%d %H:%M:%S")
df$phase <- factor(df$phase,
                   levels = c("letters", "bigrams", "words", "mixed"))

# Global trial index (for learning curve across all weeks)
df <- df[order(df$week, df$session, df$trial), ]
df$trial_global <- seq_len(nrow(df))

cat(sprintf("Loaded %d sessions | %d weeks | date range: %s to %s\n",
            nrow(df),
            length(unique(df$week)),
            format(min(df$timestamp), "%Y-%m-%d"),
            format(max(df$timestamp), "%Y-%m-%d")))

# --- 1. Full learning curve (items/sec over all trials) ------------------

phase_colors <- c(
  letters = "#2166AC",
  bigrams = "#4DAC26",
  words   = "#D6604D",
  mixed   = "#762A83"
)

p_curve <- ggplot(df, aes(x = trial_global, y = items_per_sec,
                           color = phase, group = 1)) +
  geom_line(linewidth = 0.6, alpha = 0.5) +
  geom_point(size = 2.5, alpha = 0.8) +
  geom_smooth(method = "loess", span = 0.4, se = FALSE,
              color = "grey30", linewidth = 0.8, linetype = "dashed") +
  scale_color_manual(values = phase_colors, name = "Phase") +
  scale_x_continuous(
    breaks = seq(1, nrow(df), by = 5),
    minor_breaks = NULL
  ) +
  labs(
    title    = "Arabic TMT — Learning Curve",
    subtitle = "Items per second across all trials (loess trend in grey)",
    x        = "Trial (global sequence)",
    y        = "Items per second"
  ) +
  theme_minimal(base_size = 13) +
  theme(legend.position = "bottom")

ggsave(file.path(out_dir, "learning_curve.png"), p_curve,
       width = 10, height = 5, dpi = 150, bg = "white")
cat("Saved: learning_curve.png\n")

# --- 2. Per-phase boxplot ------------------------------------------------

p_box <- ggplot(df, aes(x = phase, y = items_per_sec, fill = phase)) +
  geom_boxplot(alpha = 0.7, outlier.shape = 16, outlier.size = 2) +
  geom_jitter(width = 0.15, size = 1.5, alpha = 0.6) +
  scale_fill_manual(values = phase_colors, guide = "none") +
  labs(
    title = "Speed Distribution by Training Phase",
    x     = "Phase",
    y     = "Items per second"
  ) +
  theme_minimal(base_size = 13)

ggsave(file.path(out_dir, "weekly_boxplot.png"), p_box,
       width = 7, height = 5, dpi = 150, bg = "white")
cat("Saved: weekly_boxplot.png\n")

# --- 3. Summary table (per week x phase) ---------------------------------

summarise_group <- function(x) {
  data.frame(
    n           = length(x),
    mean_ips    = round(mean(x), 4),
    sd_ips      = round(sd(x), 4),
    median_ips  = round(median(x), 4),
    min_ips     = round(min(x), 4),
    max_ips     = round(max(x), 4),
    improvement = round((x[length(x)] - x[1]) / x[1] * 100, 1)
  )
}

weeks <- sort(unique(df$week))
summary_rows <- list()
for (w in weeks) {
  sub <- df[df$week == w, ]
  ph  <- unique(sub$phase)
  r   <- summarise_group(sub$items_per_sec)
  r$week  <- w
  r$phase <- as.character(ph[1])
  summary_rows[[length(summary_rows) + 1]] <- r
}
summary_df <- do.call(rbind, summary_rows)
summary_df <- summary_df[, c("week", "phase", "n", "mean_ips", "sd_ips",
                              "median_ips", "min_ips", "max_ips", "improvement")]

write.csv(summary_df, file.path(out_dir, "summary_table.csv"), row.names = FALSE)
cat("Saved: summary_table.csv\n")

# --- 4. Plain-text report (copy into paper) ------------------------------

report_week <- if (!is.null(target_week)) target_week else max(weeks)
sub <- df[df$week == report_week, ]

report_lines <- c(
  sprintf("=== Arabic TMT Training — Week %d Report ===", report_week),
  sprintf("Generated: %s", format(Sys.time(), "%Y-%m-%d %H:%M")),
  "",
  sprintf("Phase      : %s", unique(sub$phase)),
  sprintf("Sessions   : %d  |  Trials: %d", length(unique(sub$session)), nrow(sub)),
  sprintf("Speed (mean): %.3f items/sec  (SD = %.3f)", mean(sub$items_per_sec), sd(sub$items_per_sec)),
  sprintf("Speed range : %.3f – %.3f items/sec", min(sub$items_per_sec), max(sub$items_per_sec)),
  sprintf("Improvement : %.1f%% (first to last trial)",
          (sub$items_per_sec[nrow(sub)] - sub$items_per_sec[1]) / sub$items_per_sec[1] * 100),
  sprintf("Errors total: %d  |  Backtracks: %d",
          sum(sub$errors, na.rm = TRUE), sum(sub$backtracks, na.rm = TRUE)),
  ""
)

if (report_week > 1) {
  prev <- df[df$week == report_week - 1, ]
  delta <- mean(sub$items_per_sec) - mean(prev$items_per_sec)
  pct   <- delta / mean(prev$items_per_sec) * 100
  report_lines <- c(report_lines,
    sprintf("vs. Week %d : %+.3f items/sec (%+.1f%%)", report_week - 1, delta, pct))
}

report_file <- file.path(out_dir, sprintf("report_week%d.txt", report_week))
writeLines(report_lines, report_file)
cat(sprintf("Saved: report_week%d.txt\n", report_week))

cat("\n--- Week", report_week, "Summary ---\n")
cat(paste(report_lines, collapse = "\n"), "\n")
