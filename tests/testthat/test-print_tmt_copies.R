nums <- as.character(1:26)
lets <- get_letter_set("latin", 26)

common_args <- list(
  number_list  = nums,
  letter_list  = lets,
  N            = 13,
  type         = "B",
  min_distance = 1.2,
  element_size = 5
)

# ---- Single copy ----

test_that("n_copies = 1 creates one file", {
  out_dir <- file.path(tempdir(), paste0("tmt_test_", as.integer(Sys.time())))
  on.exit(unlink(out_dir, recursive = TRUE), add = TRUE)

  paths <- do.call(
    print_tmt_copies,
    c(list(n_copies = 1, output_dir = out_dir, base_seed = 1), common_args)
  )

  expect_length(paths, 1L)
  expect_true(file.exists(paths[1]))
})

# ---- Three copies ----

test_that("n_copies = 3 creates three files", {
  out_dir <- file.path(tempdir(), paste0("tmt_test3_", as.integer(Sys.time())))
  on.exit(unlink(out_dir, recursive = TRUE), add = TRUE)

  paths <- do.call(
    print_tmt_copies,
    c(list(n_copies = 3, output_dir = out_dir, base_seed = 10), common_args)
  )

  expect_length(paths, 3L)
  expect_true(all(file.exists(paths)))
})

# ---- Output directory creation ----

test_that("output_dir is created if it does not exist", {
  new_dir <- file.path(tempdir(), "tmt_nonexistent_dir_test",
                       paste0("sub_", as.integer(Sys.time())))
  on.exit(unlink(dirname(new_dir), recursive = TRUE), add = TRUE)

  expect_false(dir.exists(new_dir))

  do.call(
    print_tmt_copies,
    c(list(n_copies = 1, output_dir = new_dir, base_seed = 5), common_args)
  )

  expect_true(dir.exists(new_dir))
})

# ---- Files are PNG and non-empty ----

test_that("saved files are non-empty PNG files", {
  out_dir <- file.path(tempdir(), paste0("tmt_png_", as.integer(Sys.time())))
  on.exit(unlink(out_dir, recursive = TRUE), add = TRUE)

  paths <- do.call(
    print_tmt_copies,
    c(list(n_copies = 2, output_dir = out_dir, base_seed = 20), common_args)
  )

  for (p in paths) {
    expect_true(grepl("\\.png$", p, ignore.case = TRUE))
    expect_gt(file.size(p), 0L)
  }
})

# ---- Reproducibility via base_seed ----

test_that("base_seed produces files of same size on identical runs", {
  out1 <- file.path(tempdir(), paste0("tmt_rep1_", as.integer(Sys.time())))
  out2 <- file.path(tempdir(), paste0("tmt_rep2_", as.integer(Sys.time()) + 1L))
  on.exit({
    unlink(out1, recursive = TRUE)
    unlink(out2, recursive = TRUE)
  }, add = TRUE)

  p1 <- do.call(
    print_tmt_copies,
    c(list(n_copies = 1, output_dir = out1, base_seed = 77), common_args)
  )
  p2 <- do.call(
    print_tmt_copies,
    c(list(n_copies = 1, output_dir = out2, base_seed = 77), common_args)
  )

  expect_equal(file.size(p1[1]), file.size(p2[1]))
})

# ---- Input validation ----

test_that("n_copies = 0 triggers error", {
  expect_error(
    print_tmt_copies(n_copies = 0, output_dir = tempdir()),
    "positive integer"
  )
})

test_that("passing seed via ... triggers error", {
  expect_error(
    do.call(
      print_tmt_copies,
      c(list(n_copies = 1, output_dir = tempdir(), seed = 1), common_args)
    ),
    "seed"
  )
})
