#' Generate a randomized TMT-A or TMT-B plot
#'
#' Produces a ggplot2 stimulus sheet for the Trail Making Test (TMT-A or
#' TMT-B) by placing numbered (and, for TMT-B, lettered) circles at random
#' non-overlapping positions on a 10 x 10 virtual canvas.
#'
#' @param number_list A character (or numeric, auto-coerced) vector of numbers
#'   to use as labels. Must have at least \code{N} elements.
#' @param letter_list A character (or numeric, auto-coerced) vector of letters
#'   to use as labels (used only for TMT-B). Must have at least \code{N}
#'   elements. See \code{\link{get_letter_set}} for pre-built sets.
#' @param min_distance Minimum Euclidean distance between element centres on
#'   the 10 x 10 canvas. Default \code{1.0}.
#' @param element_size Numeric size passed to \code{ggplot2::geom_point} and
#'   scaled for \code{ggplot2::geom_text}. Default \code{6}.
#' @param N Number of items per sequence. For TMT-B the total number of
#'   circles is \code{2 * N}. Default \code{13}.
#' @param type \code{"A"} or \code{"B"} (case-insensitive). Default
#'   \code{"B"}.
#' @param seed Optional integer seed for reproducibility. Default \code{NULL}.
#'
#' @details
#' \strong{Point placement algorithm:}
#' Placement uses a grid-jitter approach: the canvas is divided into a regular
#' grid of cells sized \code{min_distance}, one cell per point is chosen at
#' random, and a small uniform jitter (up to half a cell width) is added. This
#' guarantees successful placement as long as \code{N} (or \code{2N} for
#' TMT-B) does not exceed the number of grid cells. A rejection-sampling
#' fallback is used if the grid step fails for any reason.
#'
#' \strong{Rendering limitations:}
#' Scripts that require contextual shaping (Arabic, Hebrew, Devanagari, Thai)
#' may not render correctly with the default system font on all platforms.
#' On Windows, ensure that the required Unicode font (e.g., Arial Unicode MS,
#' Noto fonts) is installed and accessible to the R graphics device.
#'
#' @return A \code{ggplot} object.
#'
#' @seealso \code{\link{get_letter_set}}, \code{\link{print_tmt_copies}}
#'
#' @examples
#' p <- generate_tmt_plot(
#'   number_list  = as.character(1:13),
#'   letter_list  = get_letter_set("latin", 13),
#'   min_distance = 1.2,
#'   element_size = 6,
#'   N            = 13,
#'   type         = "B",
#'   seed         = 42
#' )
#' # print(p)
#'
#' @export
generate_tmt_plot <- function(number_list,
                              letter_list  = character(0),
                              min_distance = 1.0,
                              element_size = 6,
                              N            = 13,
                              type         = "B",
                              seed         = NULL) {

  # --- Validate / coerce ---
  params <- validate_tmt_params(
    number_list  = number_list,
    letter_list  = letter_list,
    min_distance = min_distance,
    element_size = element_size,
    N            = N,
    type         = type,
    seed         = seed
  )
  number_list  <- params$number_list
  letter_list  <- params$letter_list
  min_distance <- params$min_distance
  element_size <- params$element_size
  N            <- params$N
  type         <- params$type
  seed         <- params$seed

  if (!is.null(seed)) set.seed(seed)

  # --- Build label sequence ---
  numbers <- sample(number_list, N)

  sequence_labels <- if (type == "B") {
    letter_samp <- sample(letter_list, N)
    as.character(rbind(numbers, letter_samp))
  } else {
    as.character(numbers)
  }
  total_items <- length(sequence_labels)

  # --- Place points using grid-jitter ---
  coords <- .place_points_grid(total_items, min_distance)

  coords$label <- sequence_labels

  # --- Build ggplot ---
  ggplot2::ggplot(coords, ggplot2::aes(x = x, y = y)) +
    ggplot2::geom_point(
      size  = element_size,
      shape = 21,
      fill  = "white",
      color = "black"
    ) +
    ggplot2::geom_text(
      ggplot2::aes(label = label),
      size     = element_size * 0.5,
      fontface = "bold"
    ) +
    ggplot2::theme_void() +
    ggplot2::coord_fixed(xlim = c(-0.5, 10.5), ylim = c(-0.5, 10.5)) +
    ggplot2::theme(
      plot.background  = ggplot2::element_rect(fill = "white", color = NA),
      panel.background = ggplot2::element_rect(fill = "white", color = NA)
    )
}


# ---------------------------------------------------------------------------
# Internal helper: grid-jitter point placement
# ---------------------------------------------------------------------------

#' Place n points on a 10x10 canvas with minimum separation (internal)
#'
#' Primary strategy: grid-jitter (Poisson-disk-lite).
#' Fallback strategy: rejection sampling.
#'
#' @param n Number of points to place.
#' @param min_distance Minimum Euclidean distance between any two points.
#'
#' @return A data.frame with columns \code{x} and \code{y}.
#' @keywords internal
.place_points_grid <- function(n, min_distance) {

  # Build a grid of candidate cell centres
  step     <- min_distance
  xs       <- seq(min_distance / 2, 10 - min_distance / 2, by = step)
  ys       <- seq(min_distance / 2, 10 - min_distance / 2, by = step)
  grid_pts <- expand.grid(cx = xs, cy = ys)

  half_jitter <- step / 2

  if (nrow(grid_pts) >= n) {
    # Sample n cells at random, add uniform jitter within each cell
    chosen <- grid_pts[sample(nrow(grid_pts), n, replace = FALSE), ]
    x_pts  <- chosen$cx + runif(n, -half_jitter, half_jitter)
    y_pts  <- chosen$cy + runif(n, -half_jitter, half_jitter)
    # Clamp to canvas
    x_pts  <- pmax(0, pmin(10, x_pts))
    y_pts  <- pmax(0, pmin(10, y_pts))

    # Verify pairwise distances; if violated, fall back to rejection sampling
    ok <- .check_min_dist(x_pts, y_pts, min_distance)
    if (ok) {
      return(data.frame(x = x_pts, y = y_pts))
    }
  }

  # Fallback: rejection sampling
  .place_points_rejection(n, min_distance)
}


#' Verify that all pairwise distances are >= min_distance (internal)
#' @keywords internal
.check_min_dist <- function(x, y, min_distance) {
  n <- length(x)
  if (n <= 1L) return(TRUE)
  for (i in seq_len(n - 1L)) {
    dists <- sqrt((x[(i + 1L):n] - x[i])^2 + (y[(i + 1L):n] - y[i])^2)
    if (any(dists < min_distance)) return(FALSE)
  }
  TRUE
}


#' Rejection-sampling point placement fallback (internal)
#' @keywords internal
.place_points_rejection <- function(n, min_distance) {
  max_attempts <- 100000L
  coords       <- data.frame(x = numeric(0), y = numeric(0))
  attempts     <- 0L

  while (nrow(coords) < n) {
    attempts <- attempts + 1L
    if (attempts > max_attempts) {
      stop(sprintf(
        "Could not place %d points after %d attempts. Try reducing min_distance.",
        n, max_attempts
      ))
    }
    xc <- runif(1, 0, 10)
    yc <- runif(1, 0, 10)
    if (nrow(coords) == 0L ||
        all(sqrt((coords$x - xc)^2 + (coords$y - yc)^2) >= min_distance)) {
      coords <- rbind(coords, data.frame(x = xc, y = yc))
    }
  }

  coords
}
