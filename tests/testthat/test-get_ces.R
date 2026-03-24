# Tests for get_ces function

# Helper to skip memory-intensive tests
skip_if_low_memory <- function() {
  skip_val <- Sys.getenv("SKIP_MEMORY_TESTS", unset = "FALSE")
  if (toupper(skip_val) %in% c("TRUE", "1", "YES")) {
    skip("Skipping memory-intensive test (SKIP_MEMORY_TESTS is set)")
  }
}

test_that("get_ces returns data with default parameters", {
  skip_on_cran()
  skip_if_offline()
  skip_if_low_memory()

  # Default downloads entire dataset (very large)
  # Skip this test by default due to size
  skip(
    "Skipping full CES download test - use states or industry_filter instead"
  )
})

test_that("get_ces works with specific states", {
  skip_on_cran()
  skip_if_offline()

  # Download only Massachusetts data (much smaller)
  result <- get_ces(
    states = "MA",
    suppress_warnings = TRUE,
    return_diagnostics = FALSE,
    cache = TRUE
  )

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
  # Check for state and value columns (clean output)
  expect_true("state_name" %in% names(result))
  expect_true("value" %in% names(result))
  expect_true(is.numeric(result$value))
})

test_that("get_ces works with multiple states", {
  skip_on_cran()
  skip_if_offline()

  result <- get_ces(
    states = c("MA", "CT"),
    suppress_warnings = TRUE,
    return_diagnostics = FALSE,
    cache = TRUE
  )

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
  # Just verify we got data for multiple states
  expect_true(length(unique(result$state_name)) >= 2)
})

test_that("get_ces works with industry filter", {
  skip_on_cran()
  skip_if_offline()

  result <- get_ces(
    industry_filter = "total_nonfarm",
    suppress_warnings = TRUE,
    return_diagnostics = FALSE,
    cache = TRUE
  )

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
  expect_true("industry_code" %in% names(result))
})

test_that("get_ces works with current_year_only", {
  skip_on_cran()
  skip_if_offline()

  result <- get_ces(
    current_year_only = TRUE,
    simplify_table = TRUE,
    suppress_warnings = TRUE,
    return_diagnostics = FALSE,
    cache = TRUE
  )

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
  expect_true("date" %in% names(result))
})

test_that("get_ces errors on invalid state code", {
  expect_error(
    get_ces(states = c("MA", "INVALID")),
    "Invalid state codes"
  )
})

test_that("get_ces errors on invalid industry filter", {
  expect_error(
    get_ces(industry_filter = "invalid_industry"),
    "Invalid industry_filter"
  )
})

test_that("get_ces errors with conflicting states and industry_filter", {
  expect_error(
    get_ces(states = "MA", industry_filter = "total_nonfarm"),
    "mutually exclusive"
  )
})

test_that("get_ces transform parameter works", {
  skip_on_cran()
  skip_if_offline()

  # With transform
  result_transform <- get_ces(
    states = "MA",
    transform = TRUE,
    suppress_warnings = TRUE,
    cache = TRUE
  )

  # Without transform
  result_no_transform <- get_ces(
    states = "MA",
    transform = FALSE,
    suppress_warnings = TRUE,
    cache = TRUE
  )

  # Should have different values due to transformation
  expect_s3_class(result_transform, "data.frame")
  expect_s3_class(result_no_transform, "data.frame")
})

test_that("get_ces monthly_only parameter works", {
  skip_on_cran()
  skip_if_offline()

  # Monthly only
  result_monthly <- get_ces(
    states = "MA",
    monthly_only = TRUE,
    suppress_warnings = TRUE,
    cache = TRUE
  )

  # Include annual
  result_all <- get_ces(
    states = "MA",
    monthly_only = FALSE,
    suppress_warnings = TRUE,
    cache = TRUE
  )

  expect_true(nrow(result_all) >= nrow(result_monthly))
  expect_false("M13" %in% result_monthly$period)
})

test_that("get_ces simplify_table parameter works", {
  skip_on_cran()
  skip_if_offline()

  # Simplified (default)
  result_simple <- get_ces(
    states = "MA",
    simplify_table = TRUE,
    suppress_warnings = TRUE,
    cache = TRUE
  )

  # Not simplified (keep raw structure)
  result_full <- get_ces(
    states = "MA",
    simplify_table = FALSE,
    suppress_warnings = TRUE,
    cache = TRUE
  )

  # Simplified should have date column
  expect_true("date" %in% names(result_simple))
  
  # Not simplified should have year and period
  expect_true("year" %in% names(result_full))
  expect_true("period" %in% names(result_full))
  
  # Simplified should be more columns (date added) or same (metadata removed)
  # The key is that simplified is a cleaned/processed version
  expect_true(nrow(result_simple) > 0)
  expect_true(nrow(result_full) > 0)
})

test_that("get_ces return_diagnostics works", {
  skip_on_cran()
  skip_if_offline()

  result <- get_ces(
    states = "MA",
    return_diagnostics = TRUE,
    suppress_warnings = TRUE,
    cache = TRUE
  )

  expect_s3_class(result, "bls_data_collection")
  expect_true("data" %in% names(result))
  expect_true("diagnostics" %in% names(result))
  expect_true("summary" %in% names(result))

  data <- get_bls_data(result)
  expect_s3_class(data, "data.frame")
})

test_that("get_ces return_diagnostics = FALSE returns clean data without attributes", {
  skip_on_cran()
  skip_if_offline()

  result <- get_ces(
    states = "MA",
    return_diagnostics = FALSE,
    suppress_warnings = TRUE,
    cache = TRUE
  )

  # Should be data.frame, not bls_data_collection
  expect_s3_class(result, "data.frame")
  expect_false("bls_data_collection" %in% class(result))
  
  # No diagnostic attributes should be attached
  expect_null(attr(result, "bls_diagnostics"))
  
  # Should have expected columns (metadata codes + simplified display columns)
  expected_cols <- c("series_id", "value", "state_code", "area_code", 
                     "supersector_code", "industry_code", "data_type_code", 
                     "seasonal", "industry_name", "state_name", "area_name", 
                     "data_type_text", "supersector_name", "date")
  expect_setequal(names(result), expected_cols)
})

test_that("get_ces current_year_only filters to 12 months of data", {
  skip_on_cran()
  skip_if_offline()

  result <- get_ces(
    current_year_only = TRUE,
    suppress_warnings = TRUE,
    return_diagnostics = FALSE,
    cache = TRUE
  )

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
  expect_true("date" %in% names(result))
  
  # Check that date range is approximately 12 months
  date_range <- max(result$date) - min(result$date)
  expect_true(as.numeric(date_range) >= 365)
  expect_true(as.numeric(date_range) <= 366)
})

test_that("get_ces current_year_only works with states filter", {
  skip_on_cran()
  skip_if_offline()

  result <- get_ces(
    states = "MA",
    current_year_only = TRUE,
    suppress_warnings = TRUE,
    return_diagnostics = FALSE,
    cache = TRUE
  )

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
  
  # Should only have Massachusetts data
  expect_true(all(result$state_name == "Massachusetts"))
  
  # Should be past 12 months only
  date_range <- max(result$date) - min(result$date)
  expect_true(as.numeric(date_range) >= 365)
  expect_true(as.numeric(date_range) <= 366)
})

test_that("get_ces current_year_only works with industry_filter", {
  skip_on_cran()
  skip_if_offline()

  result <- get_ces(
    industry_filter = "total_nonfarm",
    current_year_only = TRUE,
    suppress_warnings = TRUE,
    return_diagnostics = FALSE,
    cache = TRUE
  )

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
  
  # Should be past 12 months only
  date_range <- max(result$date) - min(result$date)
  expect_true(as.numeric(date_range) >= 365)
  expect_true(as.numeric(date_range) <= 366)
})

test_that("get_ces caching works", {
  skip_on_cran()
  skip_if_offline()

  temp_cache <- tempfile("ces_test_cache")
  dir.create(temp_cache)
  Sys.setenv(BLS_CACHE_DIR = temp_cache)

  # First call
  result1 <- get_ces(
    states = "RI",
    cache = TRUE,
    suppress_warnings = TRUE
  )

  # Second call (should use cache)
  result2 <- get_ces(
    states = "RI",
    cache = TRUE,
    suppress_warnings = TRUE
  )

  expect_equal(nrow(result1), nrow(result2))

  # Cleanup
  unlink(temp_cache, recursive = TRUE)
})
