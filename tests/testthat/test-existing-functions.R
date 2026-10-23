test_that("pg_create_indices follows PRIO-GRID numbering", {
  result <- pg_create_indices(3, 3)
  expect_identical(dim(result), c(3L, 3L))
  expect_equal(result[1, ], 7:9)
  expect_equal(result[3, ], 1:3)
})

test_that("pg_create_indices rejects invalid dimensions", {
  expect_error(pg_create_indices(0, 3), "positive integer")
  expect_error(pg_create_indices(3.5, 3), "positive integer")
})

test_that("interior cells have eight queen neighbors", {
  expect_setequal(
    pg_neighbors(5, nrow = 3, ncol = 3),
    c(7, 8, 9, 4, 6, 1, 2, 3)
  )
})

test_that("longitude wraps but latitude does not", {
  expect_setequal(
    pg_neighbors(1, nrow = 3, ncol = 3),
    c(6, 4, 5, 3, 2)
  )
  expect_length(pg_neighbors(1, nrow = 3, ncol = 3), 5L)
  expect_setequal(
    pg_neighbors(8, nrow = 3, ncol = 3),
    c(4, 5, 6, 7, 9)
  )
})

test_that("longitude wrapping can be disabled", {
  expect_setequal(
    pg_neighbors(1, nrow = 3, ncol = 3, wrap_longitude = FALSE),
    c(4, 5, 2)
  )
})

test_that("pg_theme has a usable default", {
  expect_s3_class(pg_theme(), "theme")
})

test_that("the public API consistently uses the pg_ prefix", {
  exports <- getNamespaceExports("priogridR")
  s3_methods <- c("print.pg_result", "as.data.frame.pg_result")

  expect_true(all(startsWith(setdiff(exports, s3_methods), "pg_")))
  expect_false(any(c(
    "create_pg_indices", "pgneighbors", "pgtheme", "write_pg_result"
  ) %in% exports))
})
