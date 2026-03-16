test_that("latin returns 26 characters", {
  x <- get_letter_set("latin", 26)
  expect_length(x, 26)
  expect_type(x, "character")
})

test_that("latin returns exactly N characters", {
  x <- get_letter_set("latin", 13)
  expect_length(x, 13)
})

test_that("greek returns correct count", {
  x <- get_letter_set("greek", 24)
  expect_length(x, 24)
})

test_that("cyrillic returns correct count", {
  x <- get_letter_set("cyrillic", 33)
  expect_length(x, 33)
})

test_that("hebrew returns 22 characters", {
  x <- get_letter_set("hebrew", 22)
  expect_length(x, 22)
})

test_that("arabic returns correct count", {
  x <- get_letter_set("arabic", 28)
  expect_length(x, 28)
})

test_that("armenian returns correct count", {
  x <- get_letter_set("armenian", 36)
  expect_length(x, 36)
})

test_that("georgian returns correct count", {
  x <- get_letter_set("georgian", 33)
  expect_length(x, 33)
})

test_that("hiragana returns correct count", {
  x <- get_letter_set("hiragana", 25)
  expect_length(x, 25)
})

test_that("katakana returns correct count", {
  x <- get_letter_set("katakana", 25)
  expect_length(x, 25)
})

test_that("ethiopic returns correct count", {
  x <- get_letter_set("ethiopic", 25)
  expect_length(x, 25)
})

test_that("devanagari returns correct count", {
  x <- get_letter_set("devanagari", 25)
  expect_length(x, 25)
})

test_that("thai returns correct count", {
  x <- get_letter_set("thai", 24)
  expect_length(x, 24)
})

test_that("korean returns 14 characters", {
  x <- get_letter_set("korean", 14)
  expect_length(x, 14)
})

test_that("latin_extended returns correct count", {
  x <- get_letter_set("latin_extended", 26)
  expect_length(x, 26)
})

test_that("N > available triggers error", {
  expect_error(get_letter_set("korean", 15), "exceeds")
})

test_that("N > latin available triggers error", {
  expect_error(get_letter_set("latin", 27), "exceeds")
})

test_that("unsupported script triggers error", {
  expect_error(get_letter_set("klingon", 5), "Unsupported")
})

test_that("script name is case-insensitive", {
  x1 <- get_letter_set("Latin", 5)
  x2 <- get_letter_set("LATIN", 5)
  x3 <- get_letter_set("latin", 5)
  expect_equal(x1, x2)
  expect_equal(x1, x3)
})

test_that("all returned elements are non-empty strings", {
  for (sc in c("latin", "greek", "cyrillic", "hiragana", "korean")) {
    x <- get_letter_set(sc, 5)
    expect_true(all(nchar(x) >= 1), info = sc)
  }
})
