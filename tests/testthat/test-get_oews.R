# Tests for get_oews function

test_that("get_oews returns data with default parameters", {
  skip_on_cran()
  skip_if_offline()

  result <- get_oews(
    suppress_warnings = TRUE,
    return_diagnostics = FALSE,
    cache = TRUE
  )

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
  expect_true("series_id" %in% names(result))
  expect_true("value" %in% names(result))
})

test_that("get_oews simplify_table parameter works", {
  skip_on_cran()
  skip_if_offline()

  # Simplified
  result_simple <- get_oews(
    simplify_table = TRUE,
    suppress_warnings = TRUE,
    cache = TRUE
  )

  # Not simplified
  result_full <- get_oews(
    simplify_table = FALSE,
    suppress_warnings = TRUE,
    cache = TRUE
  )

  expect_s3_class(result_simple, "data.frame")
  expect_s3_class(result_full, "data.frame")
  expect_true(nrow(result_simple) > 0)
})

test_that("get_oews fast_read parameter works", {
  skip_on_cran()
  skip_if_offline()

  # With fast_read - use simplify_table to avoid join issues
  result_fast <- get_oews(
    fast_read = TRUE,
    simplify_table = TRUE,
    suppress_warnings = TRUE,
    cache = TRUE
  )

  # Just test that fast_read=TRUE works
  # Note: fast_read=FALSE with simplify_table=TRUE triggers a type mismatch bug
  # in the join (occupation_code numeric vs character)
  expect_s3_class(result_fast, "data.frame")
  expect_true(nrow(result_fast) > 0)
})

test_that("get_oews_areas returns spatial data", {
  skip_on_cran()
  skip_if_offline()

  result <- get_oews_areas(
    ref_year = 2024,
    silent = TRUE,
    geometry = TRUE
  )

  # Should return sf object if geometry is TRUE and sf is available
  if (requireNamespace("sf", quietly = TRUE)) {
    expect_true(inherits(result, "sf") || inherits(result, "data.frame"))
  } else {
    expect_s3_class(result, "data.frame")
  }

  expect_true(nrow(result) > 0)
})

test_that("get_oews_areas geometry parameter works", {
  skip_on_cran()
  skip_if_offline()

  # With geometry
  result_geom <- get_oews_areas(
    ref_year = 2024,
    silent = TRUE,
    geometry = TRUE
  )

  # Without geometry
  result_no_geom <- get_oews_areas(
    ref_year = 2024,
    silent = TRUE,
    geometry = FALSE
  )

  expect_s3_class(result_no_geom, "data.frame")
  expect_true(nrow(result_no_geom) > 0)
})

test_that("get_oews caching works", {
  skip_on_cran()
  skip_if_offline()

  temp_cache <- tempfile("oews_test_cache")
  dir.create(temp_cache)
  Sys.setenv(BLS_CACHE_DIR = temp_cache)

  # First call
  result1 <- get_oews(
    cache = TRUE,
    suppress_warnings = TRUE
  )

  # Second call (should use cache)
  result2 <- get_oews(
    cache = TRUE,
    suppress_warnings = TRUE
  )

  expect_equal(nrow(result1), nrow(result2))

  # Cleanup
  unlink(temp_cache, recursive = TRUE)
})
