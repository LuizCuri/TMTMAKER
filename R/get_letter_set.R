#' Get a character vector from a named writing script
#'
#' Returns the first \code{N} characters from the chosen writing script,
#' suitable for use as \code{letter_list} in \code{\link{generate_tmt_plot}}.
#'
#' @param script Character string naming the script. See the \strong{Supported
#'   scripts} section for valid values.
#' @param N Integer. Number of characters to return. Must not exceed the
#'   number of characters available for the chosen script.
#'
#' @return A character vector of length \code{N}.
#'
#' @section Supported scripts:
#' \describe{
#'   \item{\code{"latin"}}{Standard Latin uppercase letters A-Z (26 chars).}
#'   \item{\code{"latin_extended"}}{Extended Latin characters with diacritics (26 chars).}
#'   \item{\code{"greek"}}{Classical Greek uppercase letters (24 chars).}
#'   \item{\code{"cyrillic"}}{Russian/Cyrillic uppercase letters (33 chars).}
#'   \item{\code{"hebrew"}}{Hebrew alphabet letters (22 chars).
#'     \strong{Note:} Hebrew is a right-to-left (RTL) script. Individual
#'     isolated characters render correctly in most environments, but
#'     contextual shaping or BiDi reordering may not be applied when
#'     characters are placed as independent labels in a ggplot.}
#'   \item{\code{"arabic"}}{Arabic alphabet (isolated forms, 28 chars).
#'     \strong{Note:} Arabic is a right-to-left (RTL) script. The characters
#'     provided are isolated forms and will not undergo contextual shaping
#'     (joining/ligature) when rendered as ggplot labels. Full shaping
#'     requires a HarfBuzz-aware renderer not available in base R graphics.}
#'   \item{\code{"armenian"}}{Armenian uppercase letters (36 chars).}
#'   \item{\code{"georgian"}}{Georgian Mkhedruli letters (33 chars).}
#'   \item{\code{"hiragana"}}{Japanese Hiragana syllabary (25 chars).}
#'   \item{\code{"katakana"}}{Japanese Katakana syllabary (25 chars).}
#'   \item{\code{"ethiopic"}}{Ethiopic (Ge'ez) syllables (25 chars).}
#'   \item{\code{"devanagari"}}{Devanagari consonants used in Hindi/Sanskrit
#'     (25 chars). \strong{Note:} Devanagari requires a font with Devanagari
#'     support and a shaping engine for full rendering. On Windows, characters
#'     may appear as boxes without a suitable system font (e.g., Mangal).}
#'   \item{\code{"thai"}}{Thai consonants (24 chars). \strong{Note:} Thai
#'     requires a font with Thai support. Characters may appear as boxes on
#'     systems without a Thai-capable font.}
#'   \item{\code{"korean"}}{Korean Hangul Jamo consonants (14 chars).}
#' }
#'
#' @examples
#' get_letter_set("latin", N = 13)
#' get_letter_set("greek", N = 24)
#' get_letter_set("hiragana", N = 10)
#'
#' @export
get_letter_set <- function(script = "latin", N = 26) {

  # --- Script definitions ---
  scripts <- list(

    latin = LETTERS,  # A-Z, 26

    latin_extended = c(
      "\u0100", "\u0106", "\u010e", "\u011a", "\u011e",   # Ā Ć Ď Ě Ğ
      "\u0126", "\u012c", "\u0134", "\u0136", "\u013b",   # Ħ Ĭ Ĵ Ķ Ļ
      "\u0147", "\u0150", "\u0156", "\u0160", "\u0162",   # Ň Ő Ŗ Š Ţ
      "\u0168", "\u0174", "\u0178", "\u0179", "\u017d",   # Ũ Ŵ Ÿ Ź Ž
      "\u0102", "\u010a", "\u0118", "\u0122", "\u012a",   # Ă Ċ Ę Ģ Ī
      "\u014a"                                             # Ŋ
    ),  # 26

    greek = c(
      "\u0391", "\u0392", "\u0393", "\u0394", "\u0395",   # Α Β Γ Δ Ε
      "\u0396", "\u0397", "\u0398", "\u0399", "\u039a",   # Ζ Η Θ Ι Κ
      "\u039b", "\u039c", "\u039d", "\u039e", "\u039f",   # Λ Μ Ν Ξ Ο
      "\u03a0", "\u03a1", "\u03a3", "\u03a4", "\u03a5",   # Π Ρ Σ Τ Υ
      "\u03a6", "\u03a7", "\u03a8", "\u03a9"              # Φ Χ Ψ Ω
    ),  # 24

    cyrillic = c(
      "\u0410", "\u0411", "\u0412", "\u0413", "\u0414",   # А Б В Г Д
      "\u0415", "\u0401", "\u0416", "\u0417", "\u0418",   # Е Ё Ж З И
      "\u0419", "\u041a", "\u041b", "\u041c", "\u041d",   # Й К Л М Н
      "\u041e", "\u041f", "\u0420", "\u0421", "\u0422",   # О П Р С Т
      "\u0423", "\u0424", "\u0425", "\u0426", "\u0427",   # У Ф Х Ц Ч
      "\u0428", "\u0429", "\u042a", "\u042b", "\u042c",   # Ш Щ Ъ Ы Ь
      "\u042d", "\u042e", "\u042f"                         # Э Ю Я
    ),  # 33

    hebrew = c(
      "\u05d0", "\u05d1", "\u05d2", "\u05d3", "\u05d4",   # א ב ג ד ה
      "\u05d5", "\u05d6", "\u05d7", "\u05d8", "\u05d9",   # ו ז ח ט י
      "\u05db", "\u05dc", "\u05de", "\u05e0", "\u05e1",   # כ ל מ נ ס
      "\u05e2", "\u05e4", "\u05e6", "\u05e7", "\u05e8",   # ע פ צ ק ר
      "\u05e9", "\u05ea"                                   # ש ת
    ),  # 22

    arabic = c(
      "\u0627", "\u0628", "\u062a", "\u062b", "\u062c",   # ا ب ت ث ج
      "\u062d", "\u062e", "\u062f", "\u0630", "\u0631",   # ح خ د ذ ر
      "\u0632", "\u0633", "\u0634", "\u0635", "\u0636",   # ز س ش ص ض
      "\u0637", "\u0638", "\u0639", "\u063a", "\u0641",   # ط ظ ع غ ف
      "\u0642", "\u0643", "\u0644", "\u0645", "\u0646",   # ق ك ل م ن
      "\u0647", "\u0648", "\u064a"                         # ه و ي
    ),  # 28

    armenian = c(
      "\u0531", "\u0532", "\u0533", "\u0534", "\u0535",   # Ա Բ Գ Դ Ե
      "\u0536", "\u0537", "\u0538", "\u0539", "\u053a",   # Զ Է Ը Թ Ժ
      "\u053b", "\u053c", "\u053d", "\u053e", "\u053f",   # Ի Լ Խ Ծ Կ
      "\u0540", "\u0541", "\u0542", "\u0543", "\u0544",   # Հ Ձ Ղ Ճ Մ
      "\u0545", "\u0546", "\u0547", "\u0548", "\u0549",   # Յ Ն Շ Ո Չ
      "\u054a", "\u054b", "\u054c", "\u054d", "\u054e",   # Պ Ջ Ռ Ս Վ
      "\u054f", "\u0550", "\u0551", "\u0552", "\u0553",   # Տ Ր Ց Ւ Փ
      "\u0554"                                             # Ք
    ),  # 36

    georgian = c(
      "\u10d0", "\u10d1", "\u10d2", "\u10d3", "\u10d4",   # ა ბ გ დ ე
      "\u10d5", "\u10d6", "\u10d7", "\u10d8", "\u10d9",   # ვ ზ თ ი კ
      "\u10da", "\u10db", "\u10dc", "\u10dd", "\u10de",   # ლ მ ნ ო პ
      "\u10df", "\u10e0", "\u10e1", "\u10e2", "\u10e3",   # ჟ რ ს ტ უ
      "\u10e4", "\u10e5", "\u10e6", "\u10e7", "\u10e8",   # ფ ქ ღ ყ შ
      "\u10e9", "\u10ea", "\u10eb", "\u10ec", "\u10ed",   # ჩ ც ძ წ ჭ
      "\u10ee", "\u10ef", "\u10f0"                         # ხ ჯ ჰ
    ),  # 33

    hiragana = c(
      "\u3042", "\u3044", "\u3046", "\u3048", "\u304a",   # あ い う え お
      "\u304b", "\u304d", "\u304f", "\u3051", "\u3053",   # か き く け こ
      "\u3055", "\u3057", "\u3059", "\u305b", "\u305d",   # さ し す せ そ
      "\u305f", "\u3061", "\u3064", "\u3066", "\u3068",   # た ち つ て と
      "\u306a", "\u306b", "\u306c", "\u306d", "\u306e"    # な に ぬ ね の
    ),  # 25

    katakana = c(
      "\u30a2", "\u30a4", "\u30a6", "\u30a8", "\u30aa",   # ア イ ウ エ オ
      "\u30ab", "\u30ad", "\u30af", "\u30b1", "\u30b3",   # カ キ ク ケ コ
      "\u30b5", "\u30b7", "\u30b9", "\u30bb", "\u30bd",   # サ シ ス セ ソ
      "\u30bf", "\u30c1", "\u30c4", "\u30c6", "\u30c8",   # タ チ ツ テ ト
      "\u30ca", "\u30cb", "\u30cc", "\u30cd", "\u30ce"    # ナ ニ ヌ ネ ノ
    ),  # 25

    ethiopic = c(
      "\u1200", "\u1201", "\u1202", "\u1203", "\u1204",   # ሀ ሁ ሂ ሃ ሄ
      "\u1205", "\u1206", "\u1208", "\u1209", "\u120a",   # ህ ሆ ለ ሉ ሊ
      "\u120b", "\u120c", "\u120d", "\u120e", "\u120f",   # ላ ሌ ል ሎ ሏ
      "\u1210", "\u1211", "\u1212", "\u1213", "\u1214",   # ሐ ሑ ሒ ሓ ሔ
      "\u1215", "\u1216", "\u1217", "\u1218", "\u1219"    # ሕ ሖ ሗ መ ሙ
    ),  # 25

    devanagari = c(
      "\u0915", "\u0916", "\u0917", "\u0918", "\u0919",   # क ख ग घ ङ
      "\u091a", "\u091b", "\u091c", "\u091d", "\u091e",   # च छ ज झ ञ
      "\u091f", "\u0920", "\u0921", "\u0922", "\u0923",   # ट ठ ड ढ ण
      "\u0924", "\u0925", "\u0926", "\u0927", "\u0928",   # त थ द ध न
      "\u092a", "\u092b", "\u092c", "\u092d", "\u092e"    # प फ ब भ म
    ),  # 25

    thai = c(
      "\u0e01", "\u0e02", "\u0e04", "\u0e07", "\u0e08",   # ก ข ค ง จ
      "\u0e09", "\u0e0a", "\u0e0b", "\u0e0d", "\u0e0e",   # ฉ ช ซ ญ ฎ
      "\u0e0f", "\u0e10", "\u0e11", "\u0e12", "\u0e13",   # ฏ ฐ ฑ ฒ ณ
      "\u0e14", "\u0e15", "\u0e16", "\u0e17", "\u0e18",   # ด ต ถ ท ธ
      "\u0e19", "\u0e1a", "\u0e1b", "\u0e1c"              # น บ ป ผ
    ),  # 24

    korean = c(
      "\u3131", "\u3134", "\u3137", "\u3139", "\u3141",   # ㄱ ㄴ ㄷ ㄹ ㅁ
      "\u3142", "\u3145", "\u3147", "\u3148", "\u314a",   # ㅂ ㅅ ㅇ ㅈ ㅊ
      "\u314b", "\u314c", "\u314d", "\u314e"              # ㅋ ㅌ ㅍ ㅎ
    )   # 14
  )

  key <- tolower(script)
  if (!key %in% names(scripts)) {
    stop(sprintf(
      paste0(
        "Unsupported script '%s'. ",
        "Choose one of: %s."
      ),
      script,
      paste(names(scripts), collapse = ", ")
    ))
  }

  letters_out <- scripts[[key]]

  if (N > length(letters_out)) {
    stop(sprintf(
      "N = %d exceeds the number of characters available for script '%s' (%d).",
      N, script, length(letters_out)
    ))
  }

  letters_out[seq_len(N)]
}
