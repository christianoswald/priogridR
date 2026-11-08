test_that("neighbor tables support queen and rook contiguity", {
  config <- test_config()
  queen <- pg_neighbor_table(20, method = "queen", config = config)
  rook <- pg_neighbor_table(20, method = "rook", config = config)
  expect_equal(nrow(queen), 5L)
  expect_equal(nrow(rook), 3L)
  expect_true(all(c("pgid", "neighbor_pgid") %in% names(queen)))
  expect_true(all(rook$pgid == 20L))
})

test_that("neighbor tables respect candidates and self inclusion", {
  config <- test_config()
  restricted <- pg_neighbor_table(
    1, candidates = 1:3, include_self = TRUE, config = config
  )
  expect_true(1L %in% restricted$neighbor_pgid)
  expect_true(all(restricted$neighbor_pgid %in% 1:3))

  no_wrap <- pg_neighbor_table(
    1, candidates = 1:36, wrap_longitude = FALSE, config = config
  )
  expect_false(36L %in% no_wrap$neighbor_pgid)
})

test_that("distance and nearest-neighbor tables are deterministic", {
  config <- test_config()
  distance <- pg_neighbor_table(
    1:2, candidates = 1:3, method = "distance", distance = 0,
    include_self = TRUE, config = config
  )
  expect_equal(distance$neighbor_pgid, 1:2)
  expect_equal(distance$distance_km, c(0, 0), tolerance = 1e-8)

  nearest <- pg_nearest(1, candidates = 1:4, n = 2, config = config)
  expect_equal(nrow(nearest), 2L)
  expect_equal(nearest$rank, 1:2)
  expect_false(1L %in% nearest$nearest_pgid)
  expect_true(all(diff(nearest$distance_km) >= 0))
})

test_that("spatial weights are constructed and standardized", {
  neighbors <- data.frame(
    pgid = c(1L, 1L, 2L),
    neighbor_pgid = c(2L, 3L, 1L),
    distance_km = c(10, 20, 10)
  )
  binary <- pg_weights(neighbors)
  expect_equal(sum(binary$weight[binary$pgid == 1L]), 1)
  expect_equal(binary$weight[binary$pgid == 1L], c(0.5, 0.5))

  inverse <- pg_weights(neighbors, type = "inverse_distance")
  expect_gt(inverse$weight[1], inverse$weight[2])
  expect_equal(sum(inverse$weight[inverse$pgid == 1L]), 1)
})

test_that("cell distances support pairwise and all-combination output", {
  config <- test_config()
  pairwise <- pg_distance(1:2, 1:2, config = config)
  expect_equal(pairwise$distance_km, c(0, 0), tolerance = 1e-8)

  combinations <- pg_distance(1:2, 1:3, pairwise = FALSE, config = config)
  expect_equal(nrow(combinations), 6L)
  expect_equal(combinations$from_pgid, rep(1:2, each = 3))
  expect_equal(combinations$to_pgid, rep(1:3, times = 2))
})

test_that("spatial lags do not cross temporal groups", {
  config <- test_config()
  input <- data.frame(
    pgid = rep(1:3, 2),
    year = rep(2020:2021, each = 3),
    value = c(1, 2, 3, 10, 20, 30)
  )
  result <- pg_spatial_lag(input, "value", time = "year", config = config)
  expect_equal(result$value_spatial_lag[1], 2)
  expect_equal(result$value_spatial_lag[4], 20)
  expect_equal(result$value_spatial_lag[2], 2)
  expect_equal(result$value_spatial_lag[5], 20)
})

test_that("spatial lags honor supplied weights and missing-value policy", {
  config <- test_config()
  input <- data.frame(pgid = 1:3, value = c(1, NA, 3))
  weights <- data.frame(
    pgid = c(1L, 1L), neighbor_pgid = c(2L, 3L), weight = c(0.5, 0.5)
  )
  strict <- pg_spatial_lag(input, "value", weights = weights, config = config)
  omitted <- pg_spatial_lag(
    input, "value", weights = weights, na_rm = TRUE, config = config
  )
  expect_true(is.na(strict$value_spatial_lag[1]))
  expect_equal(omitted$value_spatial_lag[1], 1.5)
})

test_that("buffer summaries respect self inclusion and periods", {
  config <- test_config()
  input <- data.frame(
    pgid = rep(1:2, 2),
    year = rep(2020:2021, each = 2),
    value = c(1, 2, 10, 20)
  )
  result <- pg_buffer_summary(
    input, "value", radius = 0, time = "year", config = config
  )
  expect_equal(result$value_buffer_sum, input$value)

  excluded <- pg_buffer_summary(
    input, "value", radius = 0, time = "year", include_self = FALSE,
    statistic = "count", config = config
  )
  expect_equal(excluded$value_buffer_count, rep(0, 4))
})

test_that("spatial context functions reject invalid inputs", {
  config <- test_config()
  expect_error(
    pg_neighbor_table(1, method = "distance", config = config),
    "distance.*required"
  )
  expect_error(pg_weights(data.frame(pgid = 1)), "Missing columns")
  expect_error(pg_distance(0, 1, config = config), "invalid")
  expect_error(
    pg_spatial_lag(
      data.frame(pgid = c(1, 1), value = 1:2), "value", config = config
    ),
    "duplicate"
  )
  expect_error(
    pg_buffer_summary(
      data.frame(pgid = 1, value = 1), "value", radius = -1,
      config = config
    ),
    "non-negative"
  )
})
