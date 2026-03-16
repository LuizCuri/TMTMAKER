# TMTMAKER

Generate randomized Trail Making Test (TMT-A and TMT-B) stimulus sheets as
PNG images, with support for 14 writing scripts.

---

## Installation

### From GitHub (once published)

```r
# install.packages("devtools")
devtools::install_github("luizg-curi/TMTMAKER")
```

### Local install

```r
devtools::install("path/to/TMTMAKER")
```

Or source the files directly for development:

```r
devtools::load_all("path/to/TMTMAKER")
```

---

## Quick start

```r
library(TMTMAKER)

# TMT-B with Latin letters, 13 items, reproducible seed
p <- generate_tmt_plot(
  number_list  = as.character(1:13),
  letter_list  = get_letter_set("latin", 13),
  min_distance = 1.2,
  element_size = 6,
  N            = 13,
  type         = "B",
  seed         = 42
)
print(p)

# Save 3 unique copies to a directory
paths <- print_tmt_copies(
  n_copies     = 3,
  output_dir   = tempdir(),
  number_list  = as.character(1:13),
  letter_list  = get_letter_set("greek", 13),
  N            = 13,
  type         = "B",
  base_seed    = 100
)
```

---

## Supported scripts

| Key              | Script            | Characters available | Notes                                        |
|------------------|-------------------|----------------------|----------------------------------------------|
| `latin`          | Latin uppercase   | 26                   |                                              |
| `latin_extended` | Extended Latin    | 26                   | Diacritics: Ā Ć Đ Ě Ğ …                     |
| `greek`          | Greek uppercase   | 24                   | Α Β Γ Δ … Ω                                  |
| `cyrillic`       | Cyrillic          | 33                   | А Б В … Я                                    |
| `hebrew`         | Hebrew            | 22                   | RTL script; isolated rendering only          |
| `arabic`         | Arabic            | 28                   | RTL; isolated forms, no contextual shaping   |
| `armenian`       | Armenian          | 36                   | Ա Բ Գ … Ք                                    |
| `georgian`       | Georgian          | 33                   | ა ბ გ … ჰ                                    |
| `hiragana`       | Japanese Hiragana | 25                   | あ い う … の                                  |
| `katakana`       | Japanese Katakana | 25                   | ア イ ウ … ノ                                  |
| `ethiopic`       | Ethiopic (Ge'ez)  | 25                   | ሀ ሁ … ሙ                                      |
| `devanagari`     | Devanagari        | 25                   | Requires Devanagari font (e.g., Mangal)      |
| `thai`           | Thai              | 24                   | Requires Thai-capable font                   |
| `korean`         | Korean Jamo       | 14                   | Hangul consonants ㄱ ㄴ … ㅎ                  |

---

## Parameters reference

### `generate_tmt_plot()`

| Parameter      | Type      | Default | Description                                                    |
|----------------|-----------|---------|----------------------------------------------------------------|
| `number_list`  | character | —       | Numbers vector (length >= N). Numeric vectors are coerced.    |
| `letter_list`  | character | —       | Letters vector (length >= N). See `get_letter_set()`.         |
| `min_distance` | numeric   | `1.0`   | Minimum distance between circle centres on the 0–10 canvas.   |
| `element_size` | numeric   | `6`     | Circle and text size (ggplot2 units).                          |
| `N`            | integer   | `13`    | Items per sequence. TMT-B places 2N circles total.            |
| `type`         | character | `"B"`   | `"A"` (numbers only) or `"B"` (numbers + letters, interleaved)|
| `seed`         | integer   | `NULL`  | Random seed for reproducibility.                              |

### `get_letter_set()`

| Parameter | Type      | Default    | Description                        |
|-----------|-----------|------------|------------------------------------|
| `script`  | character | `"latin"`  | Script key (see table above).      |
| `N`       | integer   | `26`       | Number of characters to return.    |

### `print_tmt_copies()`

| Parameter    | Type      | Default | Description                                               |
|--------------|-----------|---------|-----------------------------------------------------------|
| `n_copies`   | integer   | `1`     | Number of PNG files to generate.                         |
| `output_dir` | character | `"."`   | Output directory (created if it does not exist).         |
| `width`      | numeric   | `8`     | Image width in inches.                                    |
| `height`     | numeric   | `8`     | Image height in inches.                                   |
| `dpi`        | numeric   | `300`   | Output resolution.                                        |
| `base_seed`  | integer   | `NULL`  | Base seed; copy i uses `base_seed + i`.                  |
| `...`        | —         | —       | Further arguments forwarded to `generate_tmt_plot()`.    |

---

## Known limitations

- **Arabic and Hebrew**: Characters are rendered as isolated code points.
  Right-to-left reordering and contextual joining/ligature shaping are not
  applied by base R graphics or ggplot2. Individual characters will appear
  correctly but will not be visually shaped as they would in continuous text.

- **Devanagari and Thai**: Correct rendering requires a system font that
  includes these Unicode blocks (e.g., Mangal for Devanagari, Leelawadee for
  Thai on Windows). Without a suitable font, glyphs appear as empty boxes.

- **Korean Jamo**: Only 14 Hangul consonant jamo are available, limiting
  TMT-B to N <= 7 when this script is used.

- **Canvas capacity**: The maximum N for a given `min_distance` is
  approximately `floor(10 / min_distance)^2 / 2` for TMT-B. If N exceeds
  this, an informative error is raised.

- **Font rendering on Windows**: R uses the Windows GDI font engine. For
  the broadest Unicode coverage, install a Noto font family and reference
  it via `windowsFonts()` before calling `generate_tmt_plot()`.

---

## License

MIT — see [LICENSE](LICENSE).
