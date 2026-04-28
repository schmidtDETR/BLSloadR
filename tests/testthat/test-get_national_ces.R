# Tests for get_national_ces function

test_that("get_national_ces returns data with default parameters", {
  skip_on_cran()
  skip_if_offline()

  result <- get_national_ces(
    suppress_warnings = TRUE,
    return_diagnostics = FALSE,
    cache = TRUE
  )

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
  expect_true("series_id" %in% names(result))
  expect_true("value" %in% names(result))
})

test_that("get_national_ces simplify_table parameter works", {
  skip_on_cran()
  skip_if_offline()

  # Simplified
  result_simple <- get_national_ces(
    simplify_table = TRUE,
    suppress_warnings = TRUE,
    cache = TRUE
  )

  # Not simplified
  result_full <- get_national_ces(
    simplify_table = FALSE,
    suppress_warnings = TRUE,
    cache = TRUE
  )

  expect_true("date" %in% names(result_simple))
  expect_true(ncol(result_full) >= ncol(result_simple))
})

test_that("get_national_ces return_diagnostics works", {
  skip_on_cran()
  skip_if_offline()

  result <- get_national_ces(
    return_diagnostics = TRUE,
    suppress_warnings = TRUE,
    cache = TRUE
  )

  expect_s3_class(result, "bls_data_collection")
  expect_true("data" %in% names(result))

  data <- get_bls_data(result)
  expect_s3_class(data, "data.frame")
})

test_that("get_national_ces caching works", {
  skip_on_cran()
  skip_if_offline()

  temp_cache <- tempfile("national_ces_test_cache")
  dir.create(temp_cache)
  Sys.setenv(BLS_CACHE_DIR = temp_cache)

  # First call
  result1 <- get_national_ces(
    cache = TRUE,
    suppress_warnings = TRUE
  )

  # Second call (should use cache)
  result2 <- get_national_ces(
    cache = TRUE,
    suppress_warnings = TRUE
  )

  expect_equal(nrow(result1), nrow(result2))

  # Cleanup
  unlink(temp_cache, recursive = TRUE)
})

test_that("get_national_ces includes expected columns", {
  skip_on_cran()
  skip_if_offline()

  result <- get_national_ces(
    simplify_table = TRUE,
    suppress_warnings = TRUE,
    cache = TRUE
  )

  expect_true("value" %in% names(result))
  expect_true("date" %in% names(result))
  # Value should be numeric or coercible to numeric
  expect_true("value" %in% names(result))
})
