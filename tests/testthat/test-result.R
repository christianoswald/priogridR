test_that("pg_result converts to a data frame", {
  source <- data.frame(pgid = 1:2, value = 3:4)
  result <- priogridR:::new_pg_result(data = source)
  expect_s3_class(result, "pg_result")
  expect_equal(as.data.frame(result), source)
})

test_that("writers refuse accidental overwrite", {
  path <- tempfile(fileext = ".csv")
  write.csv(data.frame(x = 1), path, row.names = FALSE)
  expect_error(pg_write_result(data.frame(x = 2), path), "already exists")
})

