#' Generate and save multiple randomized TMT plots as PNG files
#'
#' Generates \code{n_copies} unique randomized Trail Making Test (TMT) plots
#' and saves each as a PNG file in \code{output_dir}. Each copy uses a
#' different random seed derived from the copy index, so all copies differ.
#'
#' @param n_copies Positive integer. Number of PNG files to create. Default
#'   \code{1}.
#' @param output_dir Character string. Directory where images will be saved.
#'   Created recursively if it does not exist. Default \code{"."}.
#' @param width Numeric. Output image width in inches. Default \code{8}.
#' @param height Numeric. Output image height in inches. Default \code{8}.
#' @param dpi Numeric. Output resolution in dots per inch. Default \code{300}.
#' @param base_seed Integer or \code{NULL}. Base seed for reproducibility.
#'   Copy \emph{i} receives seed \code{base_seed + i}. When \code{NULL}
#'   (default), seeds are drawn from \code{.Random.seed} and results differ
#'   between runs.
#' @param ... Additional arguments passed to \code{\link{generate_tmt_plot}}
#'   (the \code{seed} argument is handled internally and must not be passed
#'   here).
#'
#' @return Invisibly returns a character vector of the saved file paths.
#'
#' @seealso \code{\link{generate_tmt_plot}}, \code{\link{get_letter_set}}
#'
#' @examples
#' \dontrun{
#' paths <- print_tmt_copies(
#'   n_copies     = 3,
#'   output_dir   = tempdir(),
#'   number_list  = as.character(1:13),
#'   letter_list  = get_letter_set("latin", 13),
#'   min_distance = 1.2,
#'   element_size = 6,
#'   N            = 13,
#'   type         = "B",
#'   base_seed    = 100
#' )
#' cat(paths, sep = "\n")
#' }
#'
#' @export
print_tmt_copies <- function(n_copies   = 1,
                             output_dir = ".",
                             width      = 8,
                             height     = 8,
                             dpi        = 300,
                             base_seed  = NULL,
                             ...) {

  # --- Basic argument checks ---
  if (!is.numeric(n_copies) || length(n_copies) != 1 ||
      n_copies != round(n_copies) || n_copies < 1) {
    stop("'n_copies' must be a single positive integer.")
  }
  n_copies <- as.integer(n_copies)

  if (!is.character(output_dir) || length(output_dir) != 1) {
    stop("'output_dir' must be a single character string.")
  }

  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }

  # Ensure 'seed' is not passed through '...' to avoid conflict
  dots <- list(...)
  if ("seed" %in% names(dots)) {
    stop(
      "'seed' must not be passed via '...'; use 'base_seed' to control ",
      "reproducibility in print_tmt_copies()."
    )
  }

  timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
  paths     <- character(n_copies)

  for (i in seq_len(n_copies)) {
    seed_i <- if (!is.null(base_seed)) as.integer(base_seed) + i else NULL

    plot_i <- do.call(
      generate_tmt_plot,
      c(dots, list(seed = seed_i))
    )

    file_name   <- paste0("tmt_plot_", timestamp, "_", i, ".png")
    file_path   <- file.path(output_dir, file_name)

    ggplot2::ggsave(
      filename = file_path,
      plot     = plot_i,
      width    = width,
      height   = height,
      dpi      = dpi,
      bg       = "white"
    )

    paths[i] <- file_path
    message(sprintf("Saved copy %d/%d: %s", i, n_copies, file_path))
  }

  invisible(paths)
}
