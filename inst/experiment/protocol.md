# Arabic TMT Training — Session Protocol

**Study title:** Trail Making Test as a probe for Arabic script acquisition speed  
**Participant:** Luiz Guilherme Curi (self-experiment)  
**Design:** Ebbinghaus-style single-subject, 5 phases × 5 sessions × 3 trials

---

## Overview

| Week | Phase | Stimuli | TMT type | Goal |
|------|-------|---------|----------|------|
| 1 | Letters | 13 isolated Arabic letters | A | Baseline visual recognition |
| 2 | Letters | Same 13 letters, new seeds | A | Consolidation & automaticity |
| 3 | Bigrams | 13 common 2-letter words | A | Sub-lexical chunking |
| 4 | Words | 13 common 3-letter words | A | Holistic word recognition |
| 5 | Mixed | Letters + numbers interleaved | B | Cognitive flexibility |

**5 sessions per week · 3 trials per session · 2-minute rest between trials**

---

## Before You Start (each week)

1. Generate the week's sheets (already done — find them in `inst/experiment/sheets/`)
2. Print all 15 sheets for the week **OR** display on a tablet/monitor at consistent zoom
3. Decide on format (print or screen) and **never switch mid-experiment**
4. Note your setup: screen size / print paper size / distance from eyes

---

## Session Protocol (repeat for each of 5 sessions per week)

### Before the session
- [ ] Wait at least 1 hour after waking
- [ ] Do not drink coffee/tea within 30 minutes
- [ ] Rate your current fatigue: **1** (very fresh) → **5** (very tired)
- [ ] Note the time

### Each trial (× 3 per session)

1. Place / display the sheet face-down / hidden
2. On "Go": flip/reveal the sheet and start your phone stopwatch simultaneously
3. Connect the elements in the correct sequence (1→2→3… for TMT-A; 1→א→2→ב… for TMT-B)
4. Stop the stopwatch when your pen/finger reaches the last element
5. Record time to the nearest **0.1 second**
6. Count any wrong connections (errors) and backtracks before setting the sheet aside
7. Rest **2 minutes** before the next trial

### After the session
Log all 3 trials immediately:

```r
# Example — replace values with your actual measurements
library(TMTMAKER)

log_session(time_sec=52.3, phase="letters", week=1, session=1, trial=1,
            seed=1011, fatigue=2, errors=0, notes="Slow on ث and خ")
log_session(time_sec=48.7, phase="letters", week=1, session=1, trial=2,
            seed=1012, fatigue=2)
log_session(time_sec=45.1, phase="letters", week=1, session=1, trial=3,
            seed=1013, fatigue=3)
```

---

## Seed Reference (what sheet to use each day)

| Week | Session | Trial | Seed | Phase |
|------|---------|-------|------|-------|
| 1 | 1 | 1 | 1011 | letters |
| 1 | 1 | 2 | 1012 | letters |
| 1 | 1 | 3 | 1013 | letters |
| 1 | 2 | 1 | 1021 | letters |
| 1 | 2 | 2 | 1022 | letters |
| 1 | 2 | 3 | 1023 | letters |
| 1 | 3 | 1 | 1031 | letters |
| ... | ... | ... | ... | ... |
| 5 | 5 | 3 | 5053 | mixed |

Full table: run `source("inst/experiment/stimulus_schedule.R")` and inspect `stimulus_schedule`.

---

## End-of-Week Analysis

After completing all 5 sessions of a week, run:

```r
# From the package root
Rscript analysis/weekly_report.R --week 1
```

This generates:
- `analysis/output/learning_curve.png` — full speed trajectory
- `analysis/output/weekly_boxplot.png` — per-phase distribution
- `analysis/output/summary_table.csv` — numeric summary
- `analysis/output/report_week1.txt` — text ready to paste into the paper

---

## Confound Controls

| Variable | Protocol |
|----------|----------|
| Time of day | Always test within the same ±1 h window |
| Fatigue | Log 1–5 rating before each trial; will be used as covariate |
| Format | Choose print OR screen — do not mix |
| Prior knowledge | Log any Arabic study done outside experiment in `notes` |
| Order effects | Each session uses 3 different seeds (different layouts) |

---

## Stimuli Reference

### Weeks 1 & 2 — Isolated Arabic Letters
ا ب ت ث ج ح خ د ذ ر ز س ش

### Week 3 — Common Bigrams (2-letter words)
من  في  ما  لا  هو  هي  قد  بل  أو  إن  كل  ثم  هل

### Week 4 — Common Short Words (3 letters)
نور  يوم  قمر  شمس  بحر  نار  باب  بيت  ريح  ماء  قلم  كتب  أرض

### Week 5 — Mixed (TMT-B)
Arabic letters (above) interleaved with numbers 1–13
