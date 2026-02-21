# Tests for get_cps_subset function

# Check for environment variable to skip memory-intensive tests
skip_if_low_memory <- function() {
  # Skip if SKIP_MEMORY_TESTS is set to TRUE, YES, or 1
  skip_val <- Sys.getenv("SKIP_MEMORY_TESTS", unset = "FALSE")
  if (toupper(skip_val) %in% c("TRUE", "1", "YES")) {
    skip("Skipping memory-intensive test (SKIP_MEMORY_TESTS is set)")
  }
}

test_that("get_cps_subset requires series_ids or characteristics", {
  expect_error(
    get_cps_subset(),
    "You must provide either.*series_ids.*characteristics"
  )
})

test_that("get_cps_subset returns bls_data_collection object with series_ids", {
  skip_on_cran()
  skip_if_offline()

  # Use a well-known unemployment rate series
  result <- get_cps_subset(
    series_ids = "LNS14000000", # Unemployment rate, 16 years and over
    simplify_table = TRUE,
    cache = FALSE,
    suppress_warnings = TRUE
  )

  expect_s3_class(result, "bls_data_collection")
  expect_s3_class(result, "list")
  expect_true("data" %in% names(result))
  expect_true("diagnostics" %in% names(result))

  data <- get_bls_data(result)
  expect_s3_class(data, "data.frame")
  expect_true(nrow(data) > 0)
  expect_true("series_id" %in% names(data))
  expect_true("value" %in% names(data))
})

test_that("get_cps_subset works with multiple series_ids", {
  skip_on_cran()
  skip_if_offline()

  result <- get_cps_subset(
    series_ids = c("LNS14000000", "LNS11000000"), # Unemployment rate & civilian labor force
    simplify_table = TRUE,
    cache = TRUE,
    suppress_warnings = TRUE
  )

  data <- get_bls_data(result)
  expect_true(nrow(data) > 0)
  expect_true(all(c("LNS14000000", "LNS11000000") %in% unique(data$series_id)))
})

test_that("get_cps_subset filters by characteristics", {
  skip_on_cran()
  skip_if_offline()
  skip_if_low_memory()

  # Use cache to avoid re-downloading large files
  result <- get_cps_subset(
    characteristics = list(sexs_code = "1", ages_code = "00"),
    simplify_table = TRUE,
    cache = TRUE,
    suppress_warnings = TRUE
  )

  expect_s3_class(result, "bls_data_collection")
  data <- get_bls_data(result)
  expect_true(nrow(data) > 0)
})

test_that("get_cps_subset combines series_ids and characteristics", {
  skip_on_cran()
  skip_if_offline()
  skip_if_low_memory()

  # Use cache to avoid re-downloading large files
  result <- get_cps_subset(
    series_ids = "LNS14000000",
    characteristics = list(sexs_code = "1"),
    simplify_table = TRUE,
    cache = TRUE,
    suppress_warnings = TRUE
  )

  data <- get_bls_data(result)
  expect_true(nrow(data) > 0)
  expect_true("LNS14000000" %in% unique(data$series_id))
})

test_that("get_cps_subset errors on invalid characteristic name", {
  skip_on_cran()
  skip_if_offline()
  skip_if_low_memory()

  expect_error(
    get_cps_subset(
      characteristics = list(invalid_char = "01"),
      cache = FALSE,
      suppress_warnings = TRUE
    ),
    "not found in ln.series"
  )
})

test_that("get_cps_subset errors when characteristics match no series", {
  skip_on_cran()
  skip_if_offline()
  skip_if_low_memory()

  expect_error(
    get_cps_subset(
      characteristics = list(sexs_code = "999"), # Invalid code
      cache = FALSE,
      suppress_warnings = TRUE
    ),
    "did not match any series"
  )
})

test_that("get_cps_subset simplify_table parameter works", {
  skip_on_cran()
  skip_if_offline()

  # With simplification
  result_simple <- get_cps_subset(
    series_ids = "LNS14000000",
    simplify_table = TRUE,
    cache = TRUE,
    suppress_warnings = TRUE
  )

  data_simple <- get_bls_data(result_simple)
  expect_true("date" %in% names(data_simple))
  expect_true("value" %in% names(data_simple))
  expect_true(is.numeric(data_simple$value))

  # Without simplification
  result_full <- get_cps_subset(
    series_ids = "LNS14000000",
    simplify_table = FALSE,
    cache = TRUE,
    suppress_warnings = TRUE
  )

  data_full <- get_bls_data(result_full)
  expect_true(ncol(data_full) >= ncol(data_simple))
})

test_that("get_cps_subset caching works", {
  skip_on_cran()
  skip_if_offline()

  temp_cache <- tempfile("cps_test_cache")
  dir.create(temp_cache)

  # First call - should download
  result1 <- get_cps_subset(
    series_ids = "LNS14000000",
    cache = TRUE,
    cache_dir = temp_cache,
    suppress_warnings = TRUE
  )

  # Second call - should use cache
  result2 <- get_cps_subset(
    series_ids = "LNS14000000",
    cache = TRUE,
    cache_dir = temp_cache,
    suppress_warnings = TRUE
  )

  data1 <- get_bls_data(result1)
  data2 <- get_bls_data(result2)

  expect_equal(nrow(data1), nrow(data2))
  expect_equal(ncol(data1), ncol(data2))

  # Cleanup
  unlink(temp_cache, recursive = TRUE)
})

test_that("get_cps_subset respects suppress_warnings parameter", {
  skip_on_cran()
  skip_if_offline()

  # Should not produce messages
  expect_silent(
    get_cps_subset(
      series_ids = "LNS14000000",
      cache = FALSE,
      suppress_warnings = TRUE
    )
  )
})

test_that("get_cps_subset returns valid processing steps", {
  skip_on_cran()
  skip_if_offline()

  result <- get_cps_subset(
    series_ids = "LNS14000000",
    simplify_table = TRUE,
    cache = TRUE,
    suppress_warnings = TRUE
  )

  diagnostics <- get_bls_diagnostics(result)
  expect_true("processing_steps" %in% names(diagnostics))
  expect_true(length(diagnostics$processing_steps) > 0)
})

test_that("get_cps_subset handles date column creation correctly", {
  skip_on_cran()
  skip_if_offline()

  result <- get_cps_subset(
    series_ids = "LNS14000000",
    simplify_table = TRUE,
    cache = TRUE,
    suppress_warnings = TRUE
  )

  data <- get_bls_data(result)
  expect_true("date" %in% names(data))
  expect_s3_class(data$date, "Date")
  expect_true(all(!is.na(data$date)))
})

test_that("get_cps_subset data_type is set correctly", {
  skip_on_cran()
  skip_if_offline()

  result <- get_cps_subset(
    series_ids = "LNS14000000",
    cache = TRUE,
    suppress_warnings = TRUE
  )

  diagnostics <- get_bls_diagnostics(result)
  expect_equal(diagnostics$data_type, "BLS-LN-SUBSET")
})
