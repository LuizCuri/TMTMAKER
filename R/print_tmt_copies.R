#' Generate and save multiple randomized TMT plots to files
#'
#' Generates multiple randomized Trail Making Test (TMT) plots and saves them as PNG images.
#'
#' @param n_copies Number of copies to generate.
#' @param output_dir Directory path where images will be saved.
#' @param ... Additional arguments passed to `generate_tmt_plot()` (except `seed`, which is auto-handled).
#'
#' @return Saves PNG files to disk. Returns a vector of file paths.
#' @export
print_tmt_copies <- function(n_copies = 1, output_dir = ".", ...) {
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }

  paths <- character(n_copies)

  timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")

  for (i in seq_len(n_copies)) {
    seed <- as.integer(Sys.time()) %% 1e6 + i

    plot <- generate_tmt_plot(..., seed = seed)

    file_name <- paste0("tmt_plot_", timestamp, "_", i, ".png")
    file_path <- file.path(output_dir, file_name)

    ggplot2::ggsave(file_path, plot, width = 8, height = 6, dpi = 300, bg = "white")
    paths[i] <- file_path
  }

  return(paths)
}
