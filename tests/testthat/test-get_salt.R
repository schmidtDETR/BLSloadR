# Tests for get_salt function

test_that("get_salt returns data with default parameters", {
  skip_on_cran()
  skip_if_offline()

  result <- get_salt(
    suppress_warnings = TRUE,
    return_diagnostics = FALSE
  )

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
  expect_true("state" %in% names(result))
})

test_that("get_salt only_states parameter works", {
  skip_on_cran()
  skip_if_offline()

  # Only states
  result_states <- get_salt(
    only_states = TRUE,
    suppress_warnings = TRUE
  )

  # Include sub-state areas
  result_all <- get_salt(
    only_states = FALSE,
    suppress_warnings = TRUE
  )

  expect_s3_class(result_states, "data.frame")
  expect_s3_class(result_all, "data.frame")
  expect_true(nrow(result_all) >= nrow(result_states))
})

test_that("get_salt return_diagnostics works", {
  skip_on_cran()
  skip_if_offline()

  result <- get_salt(
    return_diagnostics = TRUE,
    suppress_warnings = TRUE
  )

  expect_s3_class(result, "bls_data_collection")
  expect_true("data" %in% names(result))

  data <- get_bls_data(result)
  expect_s3_class(data, "data.frame")
})

test_that("get_salt geometry parameter works", {
  skip_on_cran()
  skip_if_offline()

  # Without geometry
  result_no_geom <- get_salt(
    geometry = FALSE,
    suppress_warnings = TRUE
  )

  expect_s3_class(result_no_geom, "data.frame")
  expect_true(nrow(result_no_geom) > 0)
})

test_that("get_salt includes expected columns", {
  skip_on_cran()
  skip_if_offline()

  result <- get_salt(
    suppress_warnings = TRUE
  )

  expect_true("state" %in% names(result))
  # SALT data is wide format with u1 through u6 columns (lowercase)
  expect_true("u1" %in% names(result))
  expect_true("u3" %in% names(result))
  expect_true("u6" %in% names(result))
})
