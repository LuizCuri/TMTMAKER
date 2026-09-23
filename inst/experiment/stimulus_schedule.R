# Stimulus schedule for the 5-week Arabic TMT training experiment.
#
# Structure: 5 weeks x 5 sessions x 3 trials = 75 test sheets total.
# Seed scheme: week * 1000 + session * 10 + trial
# This makes every seed unique, reproducible, and traceable.
#
# Usage (run from package root):
#   source("R/get_letter_set.R")
#   source("inst/experiment/stimulus_schedule.R")
#   head(stimulus_schedule)

# --- Stimulus sets -------------------------------------------------------

arabic_letters <- c(
  "ا", "ب", "ت", "ث", "ج",   # ا ب ت ث ج
  "ح", "خ", "د", "ذ", "ر",   # ح خ د ذ ر
  "ز", "س", "ش"                         # ز س ش
)  # 13 visually distinct isolated forms

# Week 3: Common 2-letter Arabic words/particles
# These appear on virtually every line of Arabic text — extremely high
# frequency, making them the ideal bigram bridge between letters and words.
arabic_bigrams <- c(
  "من",   # من  (from)
  "في",   # في  (in)
  "ما",   # ما  (what/not)
  "لا",   # لا  (no)
  "هو",   # هو  (he)
  "هي",   # هي  (she)
  "قد",   # قد  (may/already)
  "بل",   # بل  (but/rather)
  "أو",   # أو  (or)
  "إن",   # إن  (if)
  "كل",   # كل  (every)
  "ثم",   # ثم  (then)
  "هل"    # هل  (question particle)
)  # 13 bigrams

# Week 4: Common 2-3 letter Arabic words (roots visible, high frequency)
arabic_words <- c(
  "نور",   # نور  (light)
  "يوم",   # يوم  (day)
  "قمر",   # قمر  (moon)
  "شمس",   # شمس  (sun)
  "بحر",   # بحر  (sea)
  "نار",   # نار  (fire)
  "باب",   # باب  (door)
  "بيت",   # بيت  (house)
  "ريح",   # ريح  (wind)
  "ماء",   # ماء  (water)
  "قلم",   # قلم  (pen)
  "كتب",   # كتب  (he wrote / books)
  "أرض"    # أرض  (earth/land)
)  # 13 words

# --- Build schedule ------------------------------------------------------

phases <- list(
  list(week = 1, phase = "letters",  type = "A", stim = arabic_letters,
       description = "Isolated Arabic letters — basic visual recognition"),
  list(week = 2, phase = "letters",  type = "A", stim = arabic_letters,
       description = "Isolated Arabic letters — consolidation & automaticity"),
  list(week = 3, phase = "bigrams",  type = "A", stim = arabic_bigrams,
       description = "Common 2-letter Arabic words — sub-lexical chunking"),
  list(week = 4, phase = "words",    type = "A", stim = arabic_words,
       description = "Common 3-letter Arabic words — holistic word recognition"),
  list(week = 5, phase = "mixed",    type = "B", stim = arabic_letters,
       description = "Arabic letters + numbers interleaved — cognitive flexibility")
)

rows <- list()
for (ph in phases) {
  for (s in 1:5) {
    for (t in 1:3) {
      seed_val <- ph$week * 1000 + s * 10 + t
      rows[[length(rows) + 1]] <- data.frame(
        week        = ph$week,
        session     = s,
        trial       = t,
        phase       = ph$phase,
        tmt_type    = ph$type,
        seed        = seed_val,
        N           = 13L,
        description = ph$description,
        stringsAsFactors = FALSE
      )
    }
  }
}

stimulus_schedule <- do.call(rbind, rows)

# Attach stimulus lists as an attribute (not a column — vectors don't fit in df)
attr(stimulus_schedule, "stim_lists") <- setNames(
  lapply(phases, `[[`, "stim"),
  vapply(phases, function(p) as.character(p$week), character(1))
)

cat(sprintf("Stimulus schedule ready: %d sessions across 5 weeks.\n",
            nrow(stimulus_schedule)))
