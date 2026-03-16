#' Validate parameters for generate_tmt_plot (internal)
#'
#' Checks that all inputs to \code{generate_tmt_plot()} are valid and coerces
#' types where appropriate. Stops with an informative message on any violation.
#'
#' @param number_list A vector that will be coerced to character if numeric.
#' @param letter_list A vector that will be coerced to character if numeric.
#' @param min_distance Positive numeric scalar.
#' @param element_size Positive numeric scalar.
#' @param N Positive integer scalar.
#' @param type Character scalar, one of "A"/"a" or "B"/"b".
#' @param seed NULL or a single integer.
#'
#' @return A named list with (possibly coerced) validated values.
#' @keywords internal
validate_tmt_params <- function(number_list, letter_list,
                                min_distance, element_size,
                                N, type, seed) {

  # --- Coerce numeric vectors to character with a message ---
  if (is.numeric(number_list)) {
    message("number_list is numeric; coercing to character.")
    number_list <- as.character(number_list)
  }
  if (is.numeric(letter_list)) {
    message("letter_list is numeric; coercing to character.")
    letter_list <- as.character(letter_list)
  }

  # --- N ---
  if (!is.numeric(N) || length(N) != 1 || N != round(N) || N < 1) {
    stop("'N' must be a single positive integer.")
  }
  N <- as.integer(N)

  # --- type ---
  if (!is.character(type) || length(type) != 1) {
    stop("'type' must be a single character string: \"A\" or \"B\".")
  }
  type <- toupper(type)
  if (!type %in% c("A", "B")) {
    stop("'type' must be \"A\" or \"B\" (case-insensitive).")
  }

  # --- min_distance ---
  if (!is.numeric(min_distance) || length(min_distance) != 1 || min_distance <= 0) {
    stop("'min_distance' must be a single positive number.")
  }

  # --- element_size ---
  if (!is.numeric(element_size) || length(element_size) != 1 || element_size <= 0) {
    stop("'element_size' must be a single positive number.")
  }

  # --- seed ---
  if (!is.null(seed)) {
    if (!is.numeric(seed) || length(seed) != 1) {
      stop("'seed' must be NULL or a single integer.")
    }
    seed <- as.integer(seed)
  }

  # --- lengths vs N ---
  if (length(number_list) < N) {
    stop(sprintf(
      "Not enough numbers: length(number_list) = %d but N = %d.",
      length(number_list), N
    ))
  }
  if (length(letter_list) < N) {
    stop(sprintf(
      "Not enough letters: length(letter_list) = %d but N = %d.",
      length(letter_list), N
    ))
  }

  # --- capacity check ---
  total_needed <- if (type == "B") 2L * N else N
  grid_n   <- floor(10 / min_distance) + 1L
  max_pts  <- grid_n^2L
  if (total_needed > max_pts) {
    stop(sprintf(
      paste0(
        "Cannot place %d points with min_distance = %.3g in a 10x10 grid ",
        "(max capacity ~%d).\nReduce min_distance or use N <= %d."
      ),
      total_needed, min_distance, max_pts,
      if (type == "B") floor(max_pts / 2L) else max_pts
    ))
  }

  list(
    number_list  = number_list,
    letter_list  = letter_list,
    min_distance = min_distance,
    element_size = element_size,
    N            = N,
    type         = type,
    seed         = seed
  )
}
