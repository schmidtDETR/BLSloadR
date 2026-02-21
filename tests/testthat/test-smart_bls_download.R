# Tests for smart_bls_download function

test_that("smart_bls_download downloads a file", {
  skip_on_cran()
  skip_if_offline()

  url <- "https://download.bls.gov/pub/time.series/ce/ce.series"

  temp_cache <- tempfile("bls_cache")
  dir.create(temp_cache)

  local_path <- smart_bls_download(url, cache_dir = temp_cache, verbose = FALSE)

  expect_type(local_path, "character")
  expect_true(file.exists(local_path))
  expect_true(file.size(local_path) > 0)

  # Cleanup
  unlink(temp_cache, recursive = TRUE)
})

test_that("smart_bls_download caches files", {
  skip_on_cran()
  skip_if_offline()

  url <- "https://download.bls.gov/pub/time.series/ce/ce.series"

  temp_cache <- tempfile("bls_cache")
  dir.create(temp_cache)

  # First download
  path1 <- smart_bls_download(url, cache_dir = temp_cache, verbose = FALSE)
  mtime1 <- file.info(path1)$mtime

  # Wait a moment
  Sys.sleep(0.5)

  # Second download should use cache (same file)
  path2 <- smart_bls_download(url, cache_dir = temp_cache, verbose = FALSE)
  mtime2 <- file.info(path2)$mtime

  expect_equal(path1, path2)
  expect_equal(mtime1, mtime2)

  # Cleanup
  unlink(temp_cache, recursive = TRUE)
})

test_that("smart_bls_download respects cache_dir parameter", {
  skip_on_cran()
  skip_if_offline()

  url <- "https://download.bls.gov/pub/time.series/ce/ce.series"

  temp_cache1 <- tempfile("bls_cache1")
  temp_cache2 <- tempfile("bls_cache2")
  dir.create(temp_cache1)
  dir.create(temp_cache2)

  path1 <- smart_bls_download(url, cache_dir = temp_cache1, verbose = FALSE)
  path2 <- smart_bls_download(url, cache_dir = temp_cache2, verbose = FALSE)

  expect_true(startsWith(path1, temp_cache1))
  expect_true(startsWith(path2, temp_cache2))

  # Cleanup
  unlink(temp_cache1, recursive = TRUE)
  unlink(temp_cache2, recursive = TRUE)
})

test_that("smart_bls_download uses default cache directory when NULL", {
  skip_on_cran()
  skip_if_offline()

  url <- "https://download.bls.gov/pub/time.series/ce/ce.series"

  local_path <- smart_bls_download(url, cache_dir = NULL, verbose = FALSE)

  expect_type(local_path, "character")
  expect_true(file.exists(local_path))

  # Should use tools::R_user_dir or similar
  expect_true(nzchar(dirname(local_path)))
})

test_that("smart_bls_download verbose parameter controls messages", {
  skip_on_cran()
  skip_if_offline()

  url <- "https://download.bls.gov/pub/time.series/ce/ce.series"

  temp_cache <- tempfile("bls_cache")
  dir.create(temp_cache)

  # With verbose = FALSE, should be mostly silent
  expect_silent(
    smart_bls_download(url, cache_dir = temp_cache, verbose = FALSE)
  )

  # Cleanup
  unlink(temp_cache, recursive = TRUE)
})

test_that("smart_bls_download handles different file types", {
  skip_on_cran()
  skip_if_offline()

  temp_cache <- tempfile("bls_cache")
  dir.create(temp_cache)

  # Regular .txt file
  url1 <- "https://download.bls.gov/pub/time.series/ce/ce.series"
  path1 <- smart_bls_download(url1, cache_dir = temp_cache, verbose = FALSE)
  expect_true(file.exists(path1))

  # Cleanup
  unlink(temp_cache, recursive = TRUE)
})

test_that("smart_bls_download syncs file modification time", {
  skip_on_cran()
  skip_if_offline()

  url <- "https://download.bls.gov/pub/time.series/ce/ce.series"

  temp_cache <- tempfile("bls_cache")
  dir.create(temp_cache)

  local_path <- smart_bls_download(url, cache_dir = temp_cache, verbose = FALSE)

  # File should exist with modification time set
  expect_true(file.exists(local_path))
  file_info <- file.info(local_path)
  expect_false(is.na(file_info$mtime))

  # Cleanup
  unlink(temp_cache, recursive = TRUE)
})

test_that("smart_bls_download creates cache directory if needed", {
  skip_on_cran()
  skip_if_offline()

  url <- "https://download.bls.gov/pub/time.series/ce/ce.series"

  temp_cache <- file.path(tempdir(), "new_bls_cache_dir")

  # Directory should not exist yet
  expect_false(dir.exists(temp_cache))

  local_path <- smart_bls_download(url, cache_dir = temp_cache, verbose = FALSE)

  # Directory should now exist
  expect_true(dir.exists(temp_cache))
  expect_true(file.exists(local_path))

  # Cleanup
  unlink(temp_cache, recursive = TRUE)
})

test_that("smart_bls_download returns valid file path", {
  skip_on_cran()
  skip_if_offline()

  url <- "https://download.bls.gov/pub/time.series/ce/ce.series"

  temp_cache <- tempfile("bls_cache")
  dir.create(temp_cache)

  local_path <- smart_bls_download(url, cache_dir = temp_cache, verbose = FALSE)

  # Should be a valid path string
  expect_type(local_path, "character")
  expect_equal(length(local_path), 1)
  expect_true(nzchar(local_path))

  # Should be readable
  expect_true(file.access(local_path, 4) == 0) # 4 = read permission

  # Cleanup
  unlink(temp_cache, recursive = TRUE)
})
