test_that("pg_metadata describes data, results, rasters, and configs", {
  config <- priogrid::pg_config(nrow = 2, ncol = 3, verbose = FALSE)
  x <- data.frame(pgid = 1:3, year = 2020:2022, value = 1:3)
  meta <- pg_metadata(x, config = config, time = "year")
  expect_s3_class(meta, "pg_metadata")
  expect_equal(meta$grid$n_cells, 6)
  expect_equal(meta$time$n_periods, 3)
  expect_equal(meta$variables, "value")
  expect_output(print(meta), "pg_metadata")

  raster <- terra::rast(nrows = 2, ncols = 3, vals = 1:6)
  expect_equal(pg_metadata(raster)$grid$n_cells, 6)
  expect_equal(pg_metadata(config)$grid$nrow, 2)

  result <- priogridR:::new_pg_result(x, metadata = list(variable = "value", source_type = "test"))
  expect_equal(pg_metadata(result, config = config)$variable, "value")
  expect_error(pg_metadata(1), "must be")
})

test_that("pg_missingness distinguishes observed values", {
  x <- data.frame(
    pgid = c(1, 1, 2), year = c(2020, 2021, 2020),
    a = c(1, NA, 3), b = c(NA, NA, 2), group = c("x", "x", "y")
  )
  overall <- pg_missingness(x, c("a", "b"), time = "year")
  expect_equal(overall$n_missing, c(1, 2))
  expect_equal(overall$n_observed, c(3, 3))
  expect_equal(nrow(pg_missingness(x, "a", time = "year", by = "cell")), 2)
  expect_equal(nrow(pg_missingness(x, "a", time = "year", by = "time")), 2)
  expect_equal(nrow(pg_missingness(x, "a", time = "year", group_columns = "group", by = "group")), 2)
  expect_error(pg_missingness(x, "unknown"), "Missing columns")
  expect_error(pg_missingness(x, "a", by = "time"), "time.*required")
})

test_that("pg_coverage separates absence and missingness", {
  config <- priogrid::pg_config(nrow = 2, ncol = 3, verbose = FALSE)
  x <- data.frame(pgid = c(1, 2, 1), year = c(2020, 2020, 2021), value = c(1, NA, 3))
  overall <- pg_coverage(x, time = "year", config = config, reference_time = 2020:2021)
  expect_equal(overall$n_expected, 12)
  expect_equal(overall$n_present, 3)
  expect_equal(overall$n_structurally_absent, 9)
  expect_equal(overall$n_observed_missing, 1)
  expect_equal(nrow(pg_coverage(x, time = "year", config = config, reference_time = 2020:2021, by = "cell")), 6)
  expect_equal(nrow(pg_coverage(x, time = "year", config = config, reference_time = 2020:2021, by = "time")), 2)
  expect_equal(pg_coverage(x, time = "year", config = config, reference_time = 2020:2021, by = "variable")$variable, "value")

  outside <- rbind(x, data.frame(pgid = 99, year = 2020, value = 1))
  expect_equal(pg_coverage(outside, time = "year", config = config, reference_time = 2020:2021)$n_outside_reference, 1)
  expect_error(
    pg_coverage(rbind(x, x[1, ]), time = "year", config = config,
                reference_time = 2020:2021),
    "duplicate reference keys"
  )
})

test_that("pg_describe summarizes static and temporal data", {
  config <- priogrid::pg_config(nrow = 2, ncol = 3, verbose = FALSE)
  x <- data.frame(pgid = c(1, 2, 2), year = c(2020, 2020, 2021), value = c(1, NA, 3))
  description <- pg_describe(x, time = "year", config = config)
  expect_s3_class(description, "pg_description")
  expect_equal(description$overview$n_rows, 3)
  expect_equal(description$overview$n_periods, 2)
  expect_output(print(description), "Rows: 3")
  expect_equal(pg_describe(data.frame(pgid = integer(), value = numeric()))$overview$n_rows, 0)
})

test_that("pg_assert_compatible reports multiple incompatibilities", {
  config <- priogrid::pg_config(nrow = 2, ncol = 3, verbose = FALSE)
  x <- data.frame(pgid = 1:2, year = 2020:2021, value = 1:2)
  y <- data.frame(pgid = 3:4, year = 2022:2023, value = 3:4)
  expect_invisible(pg_assert_compatible(x, y, config = config, time = "year"))
  bad <- data.frame(pgid = c("1", "2"), year = as.character(2020:2021), value = 1:2)
  expect_error(pg_assert_compatible(x, bad, config = config, time = "year"), "different classes")
  duplicate <- rbind(x, x[1, ])
  expect_error(pg_assert_compatible(x, duplicate, config = config, time = "year"), "Duplicate keys")
})

test_that("pg_bind combines rows conservatively", {
  config <- priogrid::pg_config(nrow = 2, ncol = 3, verbose = FALSE)
  x <- data.frame(pgid = 1:2, value = 1:2)
  y <- data.frame(pgid = 3:4, value = 3:4, extra = c("a", "b"))
  out <- pg_bind(x, y, config = config)
  expect_equal(out$pgid, 1:4)
  expect_true(all(is.na(out$extra[1:2])))
  expect_equal(attr(out, "pg_metadata")$source_type, "bind")
  expect_error(pg_bind(x, x, config = config), "Duplicate keys")
  expect_equal(nrow(pg_bind(x, x, config = config, conflict = "first")), 2)
})

test_that("pg_bind combines variables and detects conflicts", {
  config <- priogrid::pg_config(nrow = 2, ncol = 3, verbose = FALSE)
  x <- data.frame(pgid = 1:3, a = 1:3)
  y <- data.frame(pgid = 1:3, b = 4:6)
  out <- pg_bind(x, y, along = "variables", config = config)
  expect_equal(names(out), c("pgid", "a", "b"))
  same <- data.frame(pgid = 1:3, a = 1:3, b = 4:6)
  expect_equal(pg_bind(x, same, along = "variables", config = config)$a, 1:3)
  conflict <- data.frame(pgid = 1:3, a = 4:6)
  expect_error(pg_bind(x, conflict, along = "variables", config = config), "Conflicting values")
  expect_equal(pg_bind(x, conflict, along = "variables", conflict = "last", config = config)$a, 4:6)
})

test_that("pg_compare keeps absent and missing values separate", {
  config <- priogrid::pg_config(nrow = 2, ncol = 3, verbose = FALSE)
  x <- data.frame(pgid = 1:3, value = c(1, NA, 3), label = c("a", "b", "c"))
  y <- data.frame(pgid = 2:4, value = c(NA, 3 + 1e-10, 4), label = c("b", "c", "d"))
  comparison <- pg_compare(x, y, config_x = config, config_y = config)
  expect_s3_class(comparison, "pg_comparison")
  expect_equal(comparison$keys$shared, 2)
  expect_equal(comparison$keys$x_only, 1)
  expect_equal(comparison$keys$y_only, 1)
  expect_equal(comparison$variables$n_paired_missing[comparison$variables$variable == "value"], 1)
  expect_output(print(comparison), "2 shared")
  expect_error(pg_compare(rbind(x, x[1, ]), y), "unique comparison keys")
})

