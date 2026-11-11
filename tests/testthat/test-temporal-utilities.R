test_that("temporal lag and lead order within cells and restore row order", {
  config <- priogrid::pg_config(nrow = 2, ncol = 3)
  x <- data.frame(
    pgid = c(1, 2, 1, 2),
    year = c(2021, 2020, 2020, 2021),
    value = c(2, 10, 1, 20)
  )

  lagged <- pg_temporal_lag(x, "value", time = "year", config = config)
  led <- pg_temporal_lead(x, "value", time = "year", config = config)

  expect_equal(lagged$value_lag1, c(1, NA, NA, 10))
  expect_equal(led$value_lead1, c(NA, 20, 2, NA))
  expect_equal(lagged[c("pgid", "year", "value")], x)
})

test_that("temporal shifts support multiple periods and additional groups", {
  config <- priogrid::pg_config(nrow = 2, ncol = 3)
  x <- data.frame(
    pgid = rep(1, 6),
    scenario = rep(c("a", "b"), each = 3),
    year = rep(2020:2022, 2),
    value = 1:6
  )

  output <- pg_temporal_lag(
    x, "value", time = "year", periods = 2,
    group = "scenario", config = config
  )

  expect_equal(output$value_lag2, c(NA, NA, 1, NA, NA, 4))
})

test_that("temporal change supports difference, percent, and log change", {
  config <- priogrid::pg_config(nrow = 2, ncol = 3)
  x <- data.frame(
    pgid = 1,
    year = 2020:2023,
    value = c(0, 10, 20, 10)
  )

  difference <- pg_temporal_change(
    x, "value", time = "year", config = config
  )
  percent <- pg_temporal_change(
    x, "value", time = "year", type = "percent", config = config
  )
  logged <- pg_temporal_change(
    x, "value", time = "year", type = "log", config = config
  )

  expect_equal(difference$value_difference, c(NA, 10, 10, -10))
  expect_equal(percent$value_percent, c(NA, NA, 100, -50))
  expect_equal(
    logged$value_log,
    c(NA, NA, log(20) - log(10), log(10) - log(20))
  )
})

test_that("rolling summaries honor alignment, missingness, and minimum data", {
  config <- priogrid::pg_config(nrow = 2, ncol = 3)
  x <- data.frame(
    pgid = 1,
    year = 2020:2023,
    value = c(1, 2, NA, 4)
  )

  trailing <- pg_rolling_summary(
    x, "value", time = "year", window = 3, min_obs = 2,
    na_rm = TRUE, config = config
  )
  strict <- pg_rolling_summary(
    x, "value", time = "year", window = 3, min_obs = 1,
    na_rm = FALSE, name = "strict", config = config
  )
  forward <- pg_rolling_summary(
    x, "value", time = "year", window = 2, fun = "sum",
    align = "left", min_obs = 1, na_rm = TRUE, config = config
  )

  expect_equal(trailing$value_rolling_mean_3, c(NA, 1.5, 1.5, 3))
  expect_equal(strict$strict, c(1, 1.5, NA, NA))
  expect_equal(forward$value_rolling_sum_2, c(3, 2, 4, 4))
})

test_that("rolling summaries do not cross cell boundaries", {
  config <- priogrid::pg_config(nrow = 2, ncol = 3)
  x <- data.frame(
    pgid = rep(1:2, each = 2),
    year = rep(2020:2021, 2),
    value = c(1, 3, 100, 200)
  )

  output <- pg_rolling_summary(
    x, "value", time = "year", window = 2, min_obs = 1,
    config = config
  )

  expect_equal(output$value_rolling_mean_2, c(1, 2, 100, 150))
})

test_that("time since resets at events and supports periods and days", {
  config <- priogrid::pg_config(nrow = 2, ncol = 3)
  x <- data.frame(
    pgid = 1,
    date = as.Date("2020-01-01") + c(0, 10, 20, 35, 50),
    event = c(FALSE, TRUE, FALSE, TRUE, FALSE)
  )

  periods <- pg_time_since(x, "event", time = "date", config = config)
  days <- pg_time_since(
    x, "event", time = "date", units = "days",
    name = "days_since", config = config
  )

  expect_equal(periods$event_time_since, c(NA, 0, 1, 0, 1))
  expect_equal(days$days_since, c(NA, 0, 10, 0, 15))
})

test_that("time since accepts binary numeric events and isolates groups", {
  config <- priogrid::pg_config(nrow = 2, ncol = 3)
  x <- data.frame(
    pgid = rep(1, 6),
    scenario = rep(c("a", "b"), each = 3),
    year = rep(2020:2022, 2),
    event = c(1, 0, 0, 0, 1, 0)
  )

  output <- pg_time_since(
    x, "event", time = "year", group = "scenario", config = config
  )

  expect_equal(output$event_time_since, c(0, 1, 2, NA, 0, 1))
})

test_that("temporal utilities reject invalid panel structures", {
  config <- priogrid::pg_config(nrow = 2, ncol = 3)
  duplicate <- data.frame(pgid = c(1, 1), year = c(2020, 2020), value = 1:2)
  missing_time <- data.frame(pgid = 1, year = NA_integer_, value = 1)
  existing <- data.frame(
    pgid = 1, year = 2020, value = 1, value_lag1 = 9
  )

  expect_error(
    pg_temporal_lag(duplicate, "value", time = "year", config = config),
    "duplicate cell-time"
  )
  expect_error(
    pg_temporal_lag(missing_time, "value", time = "year", config = config),
    "must not contain missing"
  )
  expect_error(
    pg_temporal_lag(existing, "value", time = "year", config = config),
    "already exists"
  )
  expect_error(
    pg_temporal_lag(existing, "value", time = "year", periods = 0,
                    name = "new", config = config),
    "positive integer"
  )
})

test_that("numeric temporal utilities validate values and arguments", {
  config <- priogrid::pg_config(nrow = 2, ncol = 3)
  character_value <- data.frame(pgid = 1, year = 2020, value = "a")
  bad_event <- data.frame(pgid = 1, year = 2020, event = 2)

  expect_error(
    pg_temporal_change(
      character_value, "value", time = "year", config = config
    ),
    "numeric column"
  )
  expect_error(
    pg_rolling_summary(
      character_value, "value", time = "year", config = config
    ),
    "numeric column"
  )
  expect_error(
    pg_rolling_summary(
      transform(character_value, value = 1), "value", time = "year",
      window = 2, min_obs = 3, config = config
    ),
    "no larger"
  )
  expect_error(
    pg_time_since(bad_event, "event", time = "year", config = config),
    "zero and one"
  )
  expect_error(
    pg_time_since(
      transform(bad_event, event = 1), "event", time = "year",
      units = "days", config = config
    ),
    "Date or POSIXt"
  )
})
