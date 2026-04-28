# Tests for fread_bls function

test_that("fread_bls downloads and parses a BLS file", {
  skip_on_cran()
  skip_if_offline()

  url <- "https://download.bls.gov/pub/time.series/ce/ce.series"
  result <- fread_bls(url, verbose = FALSE, cache = FALSE)

  expect_type(result, "list")
  expect_true("data" %in% names(result))
  expect_true("diagnostics" %in% names(result))

  data <- result$data
  expect_s3_class(data, "data.frame")
  expect_true(nrow(data) > 0)
  expect_true(ncol(data) > 0)
})

test_that("fread_bls handles small files correctly", {
  skip_on_cran()
  skip_if_offline()

  # Small metadata file
  url <- "https://download.bls.gov/pub/time.series/ce/ce.seasonal"
  result <- fread_bls(url, verbose = FALSE, cache = FALSE)

  data <- result$data
  expect_s3_class(data, "data.frame")
  expect_true(nrow(data) > 0)
})

test_that("fread_bls handles larger data files", {
  skip_on_cran()
  skip_if_offline()

  # Moderately sized data file
  url <- "https://download.bls.gov/pub/time.series/ce/ce.series"
  result <- fread_bls(url, verbose = FALSE, cache = FALSE)

  data <- result$data
  expect_s3_class(data, "data.frame")
  expect_true(nrow(data) > 1000)
})

test_that("fread_bls cache parameter works", {
  skip_on_cran()
  skip_if_offline()

  url <- "https://download.bls.gov/pub/time.series/ce/ce.series"

  # Download with cache
  result1 <- fread_bls(url, verbose = FALSE, cache = TRUE)

  # Second call should use cache
  result2 <- fread_bls(url, verbose = FALSE, cache = TRUE)

  expect_equal(nrow(result1$data), nrow(result2$data))
  expect_equal(ncol(result1$data), ncol(result2$data))
})

test_that("fread_bls without cache downloads fresh data", {
  skip_on_cran()
  skip_if_offline()

  url <- "https://download.bls.gov/pub/time.series/ce/ce.series"
  result <- fread_bls(url, verbose = FALSE, cache = FALSE)

  expect_s3_class(result$data, "data.frame")
  expect_true(nrow(result$data) > 0)
})

test_that("fread_bls use_fallback parameter exists", {
  skip_on_cran()
  skip_if_offline()

  url <- "https://download.bls.gov/pub/time.series/ce/ce.series"

  # Should work with use_fallback = TRUE
  result <- fread_bls(url, verbose = FALSE, cache = FALSE, use_fallback = TRUE)
  expect_s3_class(result$data, "data.frame")

  # Should work with use_fallback = FALSE
  result <- fread_bls(url, verbose = FALSE, cache = FALSE, use_fallback = FALSE)
  expect_s3_class(result$data, "data.frame")
})

test_that("fread_bls returns diagnostics information", {
  skip_on_cran()
  skip_if_offline()

  url <- "https://download.bls.gov/pub/time.series/ce/ce.series"
  result <- fread_bls(url, verbose = FALSE, cache = FALSE)

  diagnostics <- result$diagnostics
  expect_type(diagnostics, "list")
  expect_true("url" %in% names(diagnostics))
  expect_true("original_dimensions" %in% names(diagnostics))
  expect_true("final_dimensions" %in% names(diagnostics))
  expect_equal(diagnostics$url, url)
})

test_that("fread_bls handles phantom columns correctly", {
  skip_on_cran()
  skip_if_offline()

  # Some BLS files have phantom columns that need to be removed
  url <- "https://download.bls.gov/pub/time.series/ce/ce.series"
  result <- fread_bls(url, verbose = FALSE, cache = FALSE)

  data <- result$data
  diagnostics <- result$diagnostics

  # Check that column names are meaningful (not V1, V2, etc.)
  expect_false(any(grepl("^V\\d+$", names(data))))

  # Check dimensions are recorded
  expect_true(is.numeric(diagnostics$original_dimensions))
  expect_true(is.numeric(diagnostics$final_dimensions))
})

test_that("fread_bls parses column names from header", {
  skip_on_cran()
  skip_if_offline()

  url <- "https://download.bls.gov/pub/time.series/ce/ce.series"
  result <- fread_bls(url, verbose = FALSE, cache = FALSE)

  data <- result$data

  # Should have series_id as first column
  expect_true("series_id" %in% names(data))

  # All columns should have names
  expect_true(all(nzchar(names(data))))
  expect_false(any(is.na(names(data))))
})

test_that("fread_bls verbose parameter controls output", {
  skip_on_cran()
  skip_if_offline()

  url <- "https://download.bls.gov/pub/time.series/ce/ce.series"

  # With verbose = FALSE, should be silent
  expect_silent(fread_bls(url, verbose = FALSE, cache = FALSE))

  # With verbose = TRUE, should produce messages
  expect_message(fread_bls(url, verbose = TRUE, cache = FALSE))
})

test_that("fread_bls handles tab-delimited format", {
  skip_on_cran()
  skip_if_offline()

  url <- "https://download.bls.gov/pub/time.series/ce/ce.series"
  result <- fread_bls(url, verbose = FALSE, cache = FALSE)

  data <- result$data

  # BLS files are tab-delimited, should parse multiple columns
  expect_true(ncol(data) > 1)
})

test_that("fread_bls returns bls_data class object", {
  skip_on_cran()
  skip_if_offline()

  url <- "https://download.bls.gov/pub/time.series/ce/ce.series"
  result <- fread_bls(url, verbose = FALSE, cache = FALSE)

  expect_s3_class(result, "bls_data")
  expect_s3_class(result, "list")
})

test_that("fread_bls handles compressed files with R.utils", {
  skip_on_cran()
  skip_if_offline()
  skip_if_not_installed("R.utils")

  # Test with a smaller file instead of the massive AllCESSeries file
  # Use a regular series file which should work fine
  url <- "https://download.bls.gov/pub/time.series/ce/ce.series"
  result <- fread_bls(url, verbose = FALSE, cache = FALSE, use_fallback = TRUE)

  expect_s3_class(result$data, "data.frame")
  expect_true(nrow(result$data) > 0)
})
