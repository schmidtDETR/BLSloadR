# Tests for load_bls_dataset function

test_that("load_bls_dataset requires database_code", {
  expect_error(
    load_bls_dataset(),
    "argument \"database_code\" is missing"
  )
})

test_that("load_bls_dataset works with small dataset", {
  skip_on_cran()
  skip_if_offline()

  # Use 'current' to avoid user prompts
  result <- load_bls_dataset(
    database_code = "ap", # Average Price Data - smaller dataset
    which_data = "current",
    suppress_warnings = TRUE,
    cache = TRUE
  )

  expect_s3_class(result, "bls_data_collection")
  expect_true("data" %in% names(result))

  data <- get_bls_data(result)
  expect_s3_class(data, "data.frame")
  expect_true(nrow(data) > 0)
})

test_that("load_bls_dataset simplify_table parameter works", {
  skip_on_cran()
  skip_if_offline()

  # Simplified
  result_simple <- load_bls_dataset(
    database_code = "ap",
    which_data = "current",
    simplify_table = TRUE,
    suppress_warnings = TRUE,
    cache = TRUE
  )

  data_simple <- get_bls_data(result_simple)
  expect_true("date" %in% names(data_simple))
  expect_true(is.numeric(data_simple$value))

  # Not simplified
  result_full <- load_bls_dataset(
    database_code = "ap",
    which_data = "current",
    simplify_table = FALSE,
    suppress_warnings = TRUE,
    cache = TRUE
  )

  data_full <- get_bls_data(result_full)
  expect_true(ncol(data_full) >= ncol(data_simple))
})

test_that("load_bls_dataset return_full parameter works", {
  skip_on_cran()
  skip_if_offline()

  result <- load_bls_dataset(
    database_code = "ap",
    which_data = "current",
    return_full = TRUE,
    suppress_warnings = TRUE,
    cache = TRUE
  )

  expect_type(result, "list")
  expect_true("bls_collection" %in% names(result))
  expect_true("data" %in% names(result))
  expect_true("series" %in% names(result))
  expect_true("full_file" %in% names(result))
})

test_that("load_bls_dataset which_data='current' works", {
  skip_on_cran()
  skip_if_offline()

  # Try with a dataset that has a "Current" file
  result <- load_bls_dataset(
    database_code = "ce", # National CES has a current file
    which_data = "current",
    suppress_warnings = TRUE,
    cache = TRUE
  )

  expect_s3_class(result, "bls_data_collection")
  data <- get_bls_data(result)
  expect_true(nrow(data) > 0)
})

test_that("load_bls_dataset processes diagnostics correctly", {
  skip_on_cran()
  skip_if_offline()

  result <- load_bls_dataset(
    database_code = "ap",
    which_data = "current",
    suppress_warnings = TRUE,
    cache = TRUE
  )

  expect_s3_class(result, "bls_data_collection")

  diagnostics <- get_bls_diagnostics(result)
  expect_true(!is.null(diagnostics))
  expect_true("processing_steps" %in% names(diagnostics))
  expect_true(length(diagnostics$processing_steps) > 0)
})

test_that("load_bls_dataset joins mapping files", {
  skip_on_cran()
  skip_if_offline()

  result <- load_bls_dataset(
    database_code = "ap",
    which_data = "current",
    simplify_table = FALSE,
    suppress_warnings = TRUE,
    cache = TRUE
  )

  data <- get_bls_data(result)

  # Check that mapping columns are included
  # (exact columns depend on dataset structure)
  expect_true(ncol(data) > 5) # Should have more than just basic columns
})

test_that("load_bls_dataset caching works", {
  skip_on_cran()
  skip_if_offline()

  temp_cache <- tempfile("load_bls_test_cache")
  dir.create(temp_cache)
  Sys.setenv(BLS_CACHE_DIR = temp_cache)

  # First call
  result1 <- load_bls_dataset(
    database_code = "ap",
    which_data = "current",
    cache = TRUE,
    suppress_warnings = TRUE
  )

  # Second call (should use cache)
  result2 <- load_bls_dataset(
    database_code = "ap",
    which_data = "current",
    cache = TRUE,
    suppress_warnings = TRUE
  )

  data1 <- get_bls_data(result1)
  data2 <- get_bls_data(result2)

  expect_equal(nrow(data1), nrow(data2))

  # Cleanup
  unlink(temp_cache, recursive = TRUE)
})
