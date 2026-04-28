# Tests for download_bls_files function

test_that("download_bls_files downloads multiple files", {
  skip_on_cran()
  skip_if_offline()

  urls <- c(
    "State" = "https://download.bls.gov/pub/time.series/ce/ce.series",
    "Seasonal" = "https://download.bls.gov/pub/time.series/ce/ce.seasonal"
  )

  result <- download_bls_files(urls, suppress_warnings = TRUE, cache = FALSE)

  expect_type(result, "list")
  expect_equal(length(result), 2)
  expect_true("State" %in% names(result))
  expect_true("Seasonal" %in% names(result))

  # Each should be a bls_data object
  expect_s3_class(result$State, "bls_data")
  expect_s3_class(result$Seasonal, "bls_data")
})

test_that("download_bls_files preserves URL names", {
  skip_on_cran()
  skip_if_offline()

  urls <- c(
    "My State File" = "https://download.bls.gov/pub/time.series/ce/ce.series",
    "My Seasonal File" = "https://download.bls.gov/pub/time.series/ce/ce.seasonal"
  )

  result <- download_bls_files(urls, suppress_warnings = TRUE, cache = FALSE)

  expect_equal(names(result), c("My State File", "My Seasonal File"))
})

test_that("download_bls_files handles unnamed URLs", {
  skip_on_cran()
  skip_if_offline()

  urls <- c(
    "https://download.bls.gov/pub/time.series/ce/ce.series",
    "https://download.bls.gov/pub/time.series/ce/ce.industry"
  )

  result <- download_bls_files(urls, suppress_warnings = TRUE, cache = FALSE)

  expect_type(result, "list")
  expect_equal(length(result), 2)

  # Should have auto-generated names
  expect_true(all(nzchar(names(result))))
})

test_that("download_bls_files cache parameter works", {
  skip_on_cran()
  skip_if_offline()

  urls <- c(
    "State" = "https://download.bls.gov/pub/time.series/ce/ce.series"
  )

  # Download with cache
  result1 <- download_bls_files(urls, suppress_warnings = TRUE, cache = TRUE)
  result2 <- download_bls_files(urls, suppress_warnings = TRUE, cache = TRUE)

  expect_equal(nrow(result1$State$data), nrow(result2$State$data))
})

test_that("download_bls_files suppress_warnings parameter works", {
  skip_on_cran()
  skip_if_offline()

  urls <- c(
    "State" = "https://download.bls.gov/pub/time.series/ce/ce.series"
  )

  # With suppress_warnings = TRUE, should be silent
  expect_silent(download_bls_files(
    urls,
    suppress_warnings = TRUE,
    cache = FALSE
  ))
})

test_that("download_bls_files handles single URL", {
  skip_on_cran()
  skip_if_offline()

  urls <- c("State" = "https://download.bls.gov/pub/time.series/ce/ce.series")

  result <- download_bls_files(urls, suppress_warnings = TRUE, cache = FALSE)

  expect_type(result, "list")
  expect_equal(length(result), 1)
  expect_s3_class(result$State, "bls_data")
})

test_that("download_bls_files returns all requested files", {
  skip_on_cran()
  skip_if_offline()

  urls <- c(
    "State" = "https://download.bls.gov/pub/time.series/ce/ce.series",
    "Seasonal" = "https://download.bls.gov/pub/time.series/ce/ce.seasonal",
    "Industry" = "https://download.bls.gov/pub/time.series/ce/ce.industry"
  )

  result <- download_bls_files(urls, suppress_warnings = TRUE, cache = FALSE)

  expect_equal(length(result), 3)

  # Each file should have data
  for (name in names(urls)) {
    expect_true(
      nrow(result[[name]]$data) > 0,
      info = paste("Failed for:", name)
    )
  }
})

test_that("download_bls_files calls fread_bls internally", {
  skip_on_cran()
  skip_if_offline()

  urls <- c("State" = "https://download.bls.gov/pub/time.series/ce/ce.series")

  result <- download_bls_files(urls, suppress_warnings = TRUE, cache = FALSE)

  # Result should have structure consistent with fread_bls output
  expect_true("data" %in% names(result$State))
  expect_true("diagnostics" %in% names(result$State))
})
