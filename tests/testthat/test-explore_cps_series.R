# Tests for explore_cps_series function

test_that("explore_cps_series returns results with search term", {
  skip_on_cran()
  skip_if_offline()

  result <- explore_cps_series(search = "unemployment", verbose = FALSE)

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
  expect_true("series_id" %in% names(result))
  expect_true("series_title" %in% names(result))
  expect_true(all(grepl(
    "unemployment",
    result$series_title,
    ignore.case = TRUE
  )))
})

test_that("explore_cps_series filters by characteristics", {
  skip_on_cran()
  skip_if_offline()

  result <- explore_cps_series(
    characteristics = list(sexs_code = "1"),
    verbose = FALSE
  )

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
  expect_true("sexs_code" %in% names(result))
  expect_true(all(result$sexs_code == "1"))
})

test_that("explore_cps_series filters by seasonal adjustment", {
  skip_on_cran()
  skip_if_offline()

  result <- explore_cps_series(
    seasonal = "S",
    max_results = 10,
    verbose = FALSE
  )

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
  expect_true("seasonal" %in% names(result))
  expect_true(all(result$seasonal == "S"))
})

test_that("explore_cps_series combines multiple filters", {
  skip_on_cran()
  skip_if_offline()

  result <- explore_cps_series(
    search = "unemployment",
    characteristics = list(sexs_code = "1"),
    seasonal = "S",
    max_results = 5,
    verbose = FALSE
  )

  expect_s3_class(result, "data.frame")
  if (nrow(result) > 0) {
    expect_true(all(grepl(
      "unemployment",
      result$series_title,
      ignore.case = TRUE
    )))
    expect_true(all(result$sexs_code == "1"))
    expect_true(all(result$seasonal == "S"))
  }
})

test_that("explore_cps_series respects max_results parameter", {
  skip_on_cran()
  skip_if_offline()

  result <- explore_cps_series(
    search = "labor",
    max_results = 3,
    verbose = FALSE
  )

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) <= 3)
})

test_that("explore_cps_series returns empty dataframe when no matches", {
  skip_on_cran()
  skip_if_offline()

  result <- explore_cps_series(
    search = "xyzabcnonexistent12345",
    verbose = FALSE
  )

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 0)
})

test_that("explore_cps_series errors on invalid seasonal parameter", {
  skip_on_cran()
  skip_if_offline()

  expect_error(
    explore_cps_series(seasonal = "X", verbose = FALSE),
    "must be 'S'.*or 'U'"
  )
})

test_that("explore_cps_series errors on invalid characteristic", {
  skip_on_cran()
  skip_if_offline()

  expect_error(
    explore_cps_series(
      characteristics = list(invalid_char = "01"),
      verbose = FALSE
    ),
    "not found"
  )
})

test_that("explore_cps_series supports multiple search terms", {
  skip_on_cran()
  skip_if_offline()

  result <- explore_cps_series(
    search = c("unemployment", "labor force"),
    max_results = 10,
    verbose = FALSE
  )

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
})

test_that("explore_cps_series respects cache_dir parameter", {
  skip_on_cran()
  skip_if_offline()

  temp_cache <- tempfile("cps_test_cache")
  dir.create(temp_cache)

  result <- explore_cps_series(
    search = "unemployment",
    cache_dir = temp_cache,
    max_results = 5,
    verbose = FALSE
  )

  expect_s3_class(result, "data.frame")

  # Cleanup
  unlink(temp_cache, recursive = TRUE)
})
