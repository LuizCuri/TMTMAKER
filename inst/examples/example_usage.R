library(TMTMAKER)

# --- Available letter sets ---
latin_letters  <- get_letter_set("latin",    N = 26)
arabic_letters <- get_letter_set("arabic",   N = 18)
greek_letters  <- get_letter_set("greek",    N = 24)
cyrillic_letters <- get_letter_set("cyrillic", N = 18)

# --- Generate a single TMT-B plot (Cyrillic) ---
p <- generate_tmt_plot(
  number_list  = as.character(1:18),
  letter_list  = get_letter_set("cyrillic", 18),
  min_distance = 0.5,
  element_size = 10,
  N            = 18,
  type         = "B",
  seed         = 123
)
print(p)

# --- Generate and save multiple copies ---
# Change output_dir to a directory on your machine
print_tmt_copies(
  n_copies     = 3,
  output_dir   = tempdir(),
  number_list  = as.character(1:13),
  letter_list  = get_letter_set("latin", 13),
  min_distance = 1.5,
  element_size = 6,
  N            = 13,
  type         = "B"
)
