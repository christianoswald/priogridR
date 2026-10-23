test_that("point counts preserve the number of in-grid points", {
  points <- data.frame(
    longitude = c(10, 10.1, 20),
    latitude = c(50, 50.1, 60)
  )
  result <- pg_from_points(
    x = points,
    variable = "events",
    longitude = "longitude",
    latitude = "latitude",
    aggregation = "count",
    keep_empty = FALSE,
    config = test_config()
  )
  expect_true(all(result$events >= 0))
  expect_equal(sum(result$events), nrow(points))
})

test_that("value aggregation requires a value column", {
  points <- data.frame(longitude = 10, latitude = 50)
  expect_error(
    pg_from_points(
      points,
      "total",
      "longitude",
      "latitude",
      aggregation = "sum",
      config = test_config()
    ),
    "`value` is required"
  )
})

