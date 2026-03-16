#' Get letters from different scripts
#'
#' @param script Character: "latin", "greek", "arabic", or "cyrillic"
#' @param N Number of letters to return
#' @return Character vector of letters
#' @export
get_letter_set <- function(script = "latin", N = 26) {
  arabic_letters <- c(
    "ا", "ب", "ت", "ث", "ج", "ح", "خ",
    "د", "ذ", "ر", "ز", "س", "ش", "ص",
    "ض", "ط", "ظ", "ع", "غ", "ف", "ق",
    "ك", "ل", "م", "ن", "ه", "و", "ي"
  )

  cyrillic_letters <- c(
    "А", "Б", "В", "Г", "Д", "Е", "Ё", "Ж",
    "З", "И", "Й", "К", "Л", "М", "Н", "О",
    "П", "Р", "С", "Т", "У", "Ф", "Х", "Ц",
    "Ч", "Ш", "Щ", "Ъ", "Ы", "Ь", "Э", "Ю", "Я"
  )

  letters_out <- switch(
    tolower(script),
    "latin" = LETTERS,
    "greek" = c(
      "Α", "Β", "Γ", "Δ", "Ε", "Ζ", "Η",
      "Θ", "Ι", "Κ", "Λ", "Μ", "Ν", "Ξ",
      "Ο", "Π", "Ρ", "Σ", "Τ", "Υ", "Φ",
      "Χ", "Ψ", "Ω"
    ),
    "arabic" = arabic_letters,
    "cyrillic" = cyrillic_letters,
    stop("Unsupported script. Choose 'latin', 'greek', 'arabic', or 'cyrillic'.")
  )

  if (N > length(letters_out)) stop("N exceeds number of letters available in this script.")

  return(letters_out[1:N])
}
