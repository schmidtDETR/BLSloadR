# Tests for get_laus function

test_that("get_laus returns data with default geography", {
  skip_on_cran()
  skip_if_offline()

  # Default is state_adjusted
  result <- get_laus(
    geography = "state_adjusted",
    suppress_warnings = TRUE,
    return_diagnostics = FALSE,
    cache = TRUE
  )

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
  expect_true("series_id" %in% names(result))
  expect_true("value" %in% names(result))
  expect_true("area_text" %in% names(result))
})

test_that("get_laus works with state_unadjusted", {
  skip_on_cran()
  skip_if_offline()

  result <- get_laus(
    geography = "state_unadjusted",
    suppress_warnings = TRUE,
    cache = TRUE
  )

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
})

test_that("get_laus works with specific state code", {
  skip_on_cran()
  skip_if_offline()

  result <- get_laus(
    geography = "MA",
    suppress_warnings = TRUE,
    cache = TRUE
  )

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
})

test_that("get_laus works with metro geography", {
  skip_on_cran()
  skip_if_offline()

  result <- get_laus(
    geography = "metro",
    suppress_warnings = TRUE,
    cache = TRUE
  )

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
})

test_that("get_laus errors on invalid geography", {
  expect_error(
    get_laus(geography = "invalid_geography"),
    "Invalid geography"
  )
})

test_that("get_laus monthly_only parameter works", {
  skip_on_cran()
  skip_if_offline()

  # Monthly only
  result_monthly <- get_laus(
    geography = "state_adjusted",
    monthly_only = TRUE,
    suppress_warnings = TRUE,
    cache = TRUE
  )

  expect_true("date" %in% names(result_monthly))
  expect_s3_class(result_monthly$date, "Date")
  expect_false("M13" %in% result_monthly$period)
})

test_that("get_laus transform parameter works", {
  skip_on_cran()
  skip_if_offline()

  # With transform (rates as proportions)
  result_transform <- get_laus(
    geography = "state_adjusted",
    transform = TRUE,
    suppress_warnings = TRUE,
    cache = TRUE
  )

  # Without transform (rates as percentages)
  result_no_transform <- get_laus(
    geography = "state_adjusted",
    transform = FALSE,
    suppress_warnings = TRUE,
    cache = TRUE
  )

  expect_s3_class(result_transform, "data.frame")
  expect_s3_class(result_no_transform, "data.frame")
  expect_true(nrow(result_transform) > 0)
})

test_that("get_laus return_diagnostics works", {
  skip_on_cran()
  skip_if_offline()

  result <- get_laus(
    geography = "state_adjusted",
    return_diagnostics = TRUE,
    suppress_warnings = TRUE,
    cache = TRUE
  )

  expect_s3_class(result, "bls_data_collection")
  expect_true("data" %in% names(result))

  data <- get_bls_data(result)
  expect_s3_class(data, "data.frame")
})

test_that("get_laus handles large files gracefully", {
  skip_on_cran()
  skip_if_offline()

  # County data is large (>300MB)
  # Should show message about large file
  result <- get_laus(
    geography = "county",
    suppress_warnings = FALSE,
    cache = TRUE
  )

  # Just verify we got data despite large file size
  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
})

test_that("get_laus caching works", {
  skip_on_cran()
  skip_if_offline()

  temp_cache <- tempfile("laus_test_cache")
  dir.create(temp_cache)
  Sys.setenv(BLS_CACHE_DIR = temp_cache)

  # First call
  result1 <- get_laus(
    geography = "state_adjusted",
    cache = TRUE,
    suppress_warnings = TRUE
  )

  # Second call (should use cache)
  result2 <- get_laus(
    geography = "state_adjusted",
    cache = TRUE,
    suppress_warnings = TRUE
  )

  expect_equal(nrow(result1), nrow(result2))

  # Cleanup
  unlink(temp_cache, recursive = TRUE)
})
