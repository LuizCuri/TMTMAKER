#' Generate a randomized TMT-A or TMT-B plot
#'
#' @param number_list A vector of numbers
#' @param letter_list A vector of letters
#' @param min_distance Minimum distance between elements
#' @param element_size Size of circles and text
#' @param N Number of elements (e.g. 13)
#' @param type "A" or "B" for TMT version
#' @param seed Optional seed for reproducibility
#'
#' @return A ggplot2 plot
#' @export
generate_tmt_plot <- function(number_list, letter_list,
                              min_distance = 1.0,
                              element_size = 6,
                              N = 13,
                              type = "B",
                              seed = NULL) {
  if (!is.null(seed)) set.seed(seed)

  if (length(number_list) < N) stop("Not enough numbers (length(number_list) < N).")
  if (length(letter_list) < N) stop("Not enough letters (length(letter_list) < N).")

  # Estimate how many points fit in a 10x10 grid at the given spacing
  grid_n  <- floor(10 / min_distance) + 1
  max_pts <- grid_n^2
  max_N   <- floor(max_pts / 2)  # TMT-B needs 2*N points
  if (toupper(type) == "B" && N > max_N) {
    stop(sprintf(
      "Cannot place 2x%d = %d points with min_distance = %.3g in a 0-10 x 0-10 grid.\nSuggestion: reduce min_distance or use N <= %d.",
      N, 2 * N, min_distance, max_N
    ))
  }

  numbers      <- sample(number_list, N)
  letter_samp  <- sample(letter_list, N)

  sequence_labels <- if (toupper(type) == "B") {
    as.character(rbind(numbers, letter_samp))
  } else {
    as.character(numbers)
  }
  total_items <- length(sequence_labels)

  coords <- data.frame(x = numeric(0), y = numeric(0))

  attempts     <- 0
  max_attempts <- 50000
  while (nrow(coords) < total_items) {
    attempts <- attempts + 1
    if (attempts > max_attempts) {
      stop(
        "Could not place all points after ", max_attempts,
        " attempts. Try reducing min_distance."
      )
    }
    x_candidate <- runif(1, 0, 10)
    y_candidate <- runif(1, 0, 10)
    if (nrow(coords) == 0 ||
        all(
          sqrt((coords$x - x_candidate)^2 +
               (coords$y - y_candidate)^2) >= min_distance
        )
    ) {
      coords <- rbind(coords, data.frame(x = x_candidate, y = y_candidate))
    }
  }

  coords$label <- sequence_labels

  ggplot2::ggplot(coords, ggplot2::aes(x = x, y = y)) +
    ggplot2::geom_point(size = element_size, shape = 21,
                        fill = "white", color = "black") +
    ggplot2::geom_text(
      ggplot2::aes(label = label),
      size = element_size * 0.85,
      fontface = "bold"
    ) +
    ggplot2::theme_void() +
    ggplot2::coord_fixed() +
    ggplot2::theme(
      plot.background  = ggplot2::element_rect(fill = "white", color = NA),
      panel.background = ggplot2::element_rect(fill = "white", color = NA)
    )
}
