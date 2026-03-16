nums <- as.character(1:26)
lets <- get_letter_set("latin", 26)

# ---- Return type ----

test_that("returns a ggplot object (TMT-B)", {
  p <- generate_tmt_plot(nums, lets, N = 13, type = "B", seed = 1)
  expect_s3_class(p, "ggplot")
})

test_that("returns a ggplot object (TMT-A)", {
  p <- generate_tmt_plot(nums, lets, N = 13, type = "A", seed = 1)
  expect_s3_class(p, "ggplot")
})

# ---- Correct number of data rows ----

test_that("TMT-A produces N rows in plot data", {
  p <- generate_tmt_plot(nums, lets, N = 10, type = "A", seed = 2)
  expect_equal(nrow(p$data), 10L)
})

test_that("TMT-B produces 2N rows in plot data", {
  p <- generate_tmt_plot(nums, lets, N = 10, type = "B", seed = 2)
  expect_equal(nrow(p$data), 20L)
})

# ---- Reproducibility ----

test_that("same seed produces identical coordinates", {
  p1 <- generate_tmt_plot(nums, lets, N = 13, type = "B", seed = 99)
  p2 <- generate_tmt_plot(nums, lets, N = 13, type = "B", seed = 99)
  expect_equal(p1$data$x, p2$data$x)
  expect_equal(p1$data$y, p2$data$y)
  expect_equal(p1$data$label, p2$data$label)
})

test_that("different seeds produce different coordinates", {
  p1 <- generate_tmt_plot(nums, lets, N = 13, type = "B", seed = 1)
  p2 <- generate_tmt_plot(nums, lets, N = 13, type = "B", seed = 2)
  expect_false(identical(p1$data$x, p2$data$x))
})

# ---- type argument case-insensitivity ----

test_that("type = 'a' works the same as 'A'", {
  p1 <- generate_tmt_plot(nums, lets, N = 10, type = "a", seed = 5)
  p2 <- generate_tmt_plot(nums, lets, N = 10, type = "A", seed = 5)
  expect_equal(nrow(p1$data), nrow(p2$data))
})

test_that("type = 'b' works the same as 'B'", {
  p1 <- generate_tmt_plot(nums, lets, N = 10, type = "b", seed = 5)
  p2 <- generate_tmt_plot(nums, lets, N = 10, type = "B", seed = 5)
  expect_equal(nrow(p1$data), nrow(p2$data))
})

# ---- Input validation errors ----

test_that("invalid type triggers error", {
  expect_error(
    generate_tmt_plot(nums, lets, N = 5, type = "C"),
    "\"A\" or \"B\""
  )
})

test_that("N = 0 triggers error", {
  expect_error(
    generate_tmt_plot(nums, lets, N = 0),
    "positive integer"
  )
})

test_that("N too large for min_distance triggers error", {
  expect_error(
    generate_tmt_plot(nums, lets, N = 26, type = "B", min_distance = 5),
    regexp = "Cannot place|Reduce"
  )
})

test_that("too few numbers triggers error", {
  expect_error(
    generate_tmt_plot(nums[1:5], lets, N = 10),
    "Not enough numbers"
  )
})

test_that("too few letters triggers error", {
  expect_error(
    generate_tmt_plot(nums, lets[1:5], N = 10),
    "Not enough letters"
  )
})

# ---- Numeric coercion ----

test_that("numeric number_list is coerced with message", {
  expect_message(
    generate_tmt_plot(1:26, lets, N = 5, type = "A", seed = 1),
    "coercing"
  )
})

# ---- Multiple scripts ----

test_that("greek script works end-to-end", {
  greek <- get_letter_set("greek", 24)
  p <- generate_tmt_plot(nums, greek, N = 13, type = "B", seed = 10)
  expect_s3_class(p, "ggplot")
})

test_that("cyrillic script works end-to-end", {
  cyr <- get_letter_set("cyrillic", 26)
  p <- generate_tmt_plot(nums, cyr, N = 13, type = "B", seed = 10)
  expect_s3_class(p, "ggplot")
})

test_that("hebrew script works end-to-end", {
  heb <- get_letter_set("hebrew", 22)
  p <- generate_tmt_plot(nums, heb, N = 13, type = "B", seed = 10)
  expect_s3_class(p, "ggplot")
})

test_that("hiragana script works end-to-end", {
  hira <- get_letter_set("hiragana", 25)
  p <- generate_tmt_plot(nums, hira, N = 13, type = "B", seed = 10)
  expect_s3_class(p, "ggplot")
})

# ---- Coordinates are within canvas ----

test_that("all coordinates are within 0-10 range", {
  p <- generate_tmt_plot(nums, lets, N = 13, type = "B", seed = 7)
  expect_true(all(p$data$x >= 0 & p$data$x <= 10))
  expect_true(all(p$data$y >= 0 & p$data$y <= 10))
})
