# Tests for get_qcew function

test_that("get_qcew returns data with industry_code", {
  skip_on_cran()
  skip_if_offline()

  # Get Total, all industries for recent quarters
  result <- get_qcew(
    period_type = "quarter",
    industry_code = "10",
    year_start = 2023,
    year_end = 2023,
    silently = TRUE
  )

  expect_s3_class(result, "data.table")
  expect_true(nrow(result) > 0)
  expect_true("industry_code" %in% names(result))
  expect_true("area_fips" %in% names(result))
  expect_true("date" %in% names(result))
})

test_that("get_qcew returns data with area_code", {
  skip_on_cran()
  skip_if_offline()

  # Get data for US total
  result <- get_qcew(
    period_type = "quarter",
    area_code = "US000",
    year_start = 2023,
    year_end = 2023,
    silently = TRUE
  )

  expect_s3_class(result, "data.table")
  expect_true(nrow(result) > 0)
  expect_true("area_fips" %in% names(result))
})

test_that("get_qcew works with annual data", {
  skip_on_cran()
  skip_if_offline()

  result <- get_qcew(
    period_type = "year",
    industry_code = "10",
    year_start = 2023,
    year_end = 2023,
    silently = TRUE
  )

  expect_s3_class(result, "data.table")
  expect_true(nrow(result) > 0)
  expect_true("qtr" %in% names(result))
  expect_true(all(result$qtr == "A"))
})

test_that("get_qcew errors without industry_code or area_code", {
  expect_error(
    get_qcew(period_type = "quarter"),
    "You must provide either an industry_code or an area_code"
  )
})

test_that("get_qcew errors on invalid period_type", {
  expect_error(
    get_qcew(period_type = "invalid", industry_code = "10"),
    "period_type must be either 'quarter' or 'year'"
  )
})

test_that("get_qcew add_lookups parameter works", {
  skip_on_cran()
  skip_if_offline()

  # With lookups
  result_with <- get_qcew(
    period_type = "quarter",
    industry_code = "10",
    year_start = 2023,
    year_end = 2023,
    add_lookups = TRUE,
    silently = TRUE
  )

  # Without lookups
  result_without <- get_qcew(
    period_type = "quarter",
    industry_code = "10",
    year_start = 2023,
    year_end = 2023,
    add_lookups = FALSE,
    silently = TRUE
  )

  expect_true(ncol(result_with) > ncol(result_without))
  expect_true("industry_title" %in% names(result_with))
  expect_true("area_title" %in% names(result_with))
})

test_that("get_qcew handles multiple years", {
  skip_on_cran()
  skip_if_offline()

  result <- get_qcew(
    period_type = "quarter",
    industry_code = "10",
    year_start = 2022,
    year_end = 2023,
    silently = TRUE
  )

  expect_s3_class(result, "data.table")
  expect_true(nrow(result) > 0)
  expect_true(all(c(2022, 2023) %in% result$year))
})

test_that("get_qcew includes date column", {
  skip_on_cran()
  skip_if_offline()

  result <- get_qcew(
    period_type = "quarter",
    industry_code = "10",
    year_start = 2023,
    year_end = 2023,
    silently = TRUE
  )

  expect_true("date" %in% names(result))
  expect_s3_class(result$date, "Date")
})

test_that("get_qcew warns about pre-2014 data", {
  expect_warning(
    get_qcew(
      period_type = "quarter",
      industry_code = "10",
      year_start = 2013,
      year_end = 2013,
      silently = TRUE
    ),
    "prior to 2014"
  )
})
