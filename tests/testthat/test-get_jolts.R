# Tests for get_jolts function

test_that("get_jolts returns data with default parameters", {
  skip_on_cran()
  skip_if_offline()

  result <- get_jolts(
    suppress_warnings = TRUE,
    return_diagnostics = FALSE,
    cache = TRUE
  )

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
  expect_true("series_id" %in% names(result))
  expect_true("value" %in% names(result))
})

test_that("get_jolts monthly_only parameter works", {
  skip_on_cran()
  skip_if_offline()

  # Monthly only
  result_monthly <- get_jolts(
    monthly_only = TRUE,
    suppress_warnings = TRUE,
    cache = TRUE
  )

  # Include annual
  result_all <- get_jolts(
    monthly_only = FALSE,
    suppress_warnings = TRUE,
    cache = TRUE
  )

  expect_true("date" %in% names(result_monthly))
  expect_true(nrow(result_all) >= nrow(result_monthly))
})

test_that("get_jolts return_diagnostics works", {
  skip_on_cran()
  skip_if_offline()

  result <- get_jolts(
    return_diagnostics = TRUE,
    suppress_warnings = TRUE,
    cache = TRUE
  )

  expect_s3_class(result, "bls_data_collection")
  expect_true("data" %in% names(result))
  expect_true("diagnostics" %in% names(result))

  data <- get_bls_data(result)
  expect_s3_class(data, "data.frame")
})

test_that("get_jolts caching works", {
  skip_on_cran()
  skip_if_offline()

  temp_cache <- tempfile("jolts_test_cache")
  dir.create(temp_cache)
  Sys.setenv(BLS_CACHE_DIR = temp_cache)

  # First call
  result1 <- get_jolts(
    cache = TRUE,
    suppress_warnings = TRUE
  )

  # Second call (should use cache)
  result2 <- get_jolts(
    cache = TRUE,
    suppress_warnings = TRUE
  )

  expect_equal(nrow(result1), nrow(result2))

  # Cleanup
  unlink(temp_cache, recursive = TRUE)
})

test_that("get_jolts includes expected columns", {
  skip_on_cran()
  skip_if_offline()

  result <- get_jolts(
    monthly_only = TRUE,
    suppress_warnings = TRUE,
    cache = TRUE
  )

  expect_true("value" %in% names(result))
  expect_true("date" %in% names(result))
  expect_true(is.numeric(result$value))
})
