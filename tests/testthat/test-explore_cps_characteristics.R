# Tests for explore_cps_characteristics function

test_that("explore_cps_characteristics returns all characteristics when no argument provided", {
  skip_on_cran()
  skip_if_offline()

  result <- explore_cps_characteristics(verbose = FALSE)

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
  expect_true(all(
    c("characteristic", "code_column", "description") %in% names(result)
  ))
  expect_true(all(grepl("_code$", result$code_column)))
})

test_that("explore_cps_characteristics returns codes for specific characteristic", {
  skip_on_cran()
  skip_if_offline()

  # Test with sexs characteristic
  result <- explore_cps_characteristics("sexs", verbose = FALSE)

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
  expect_true("sexs_code" %in% names(result))
})

test_that("explore_cps_characteristics works with or without _code suffix", {
  skip_on_cran()
  skip_if_offline()

  result1 <- explore_cps_characteristics("sexs", verbose = FALSE)
  result2 <- explore_cps_characteristics("sexs_code", verbose = FALSE)

  expect_identical(result1, result2)
})

test_that("explore_cps_characteristics errors on invalid characteristic", {
  skip_on_cran()
  skip_if_offline()

  expect_error(
    explore_cps_characteristics("invalid_characteristic", verbose = FALSE),
    "not found"
  )
})

test_that("explore_cps_characteristics respects cache_dir parameter", {
  skip_on_cran()
  skip_if_offline()

  temp_cache <- tempfile("cps_test_cache")
  dir.create(temp_cache)

  result <- explore_cps_characteristics(
    characteristic = "sexs",
    cache_dir = temp_cache,
    verbose = FALSE
  )

  expect_s3_class(result, "data.frame")

  # Cleanup
  unlink(temp_cache, recursive = TRUE)
})

test_that("explore_cps_characteristics handles common characteristics", {
  skip_on_cran()
  skip_if_offline()

  common_chars <- c("ages", "sexs", "race", "education")

  for (char in common_chars) {
    result <- explore_cps_characteristics(char, verbose = FALSE)
    expect_s3_class(result, "data.frame")
    expect_true(nrow(result) > 0)
  }
})
