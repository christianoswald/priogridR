test_that("cell centres round-trip through coordinate lookup", {
  config <- test_config()
  ids <- c(1L, 37L, 648L)
  coordinates <- pg_coords_from_id(ids, config = config)
  recovered <- pg_id_from_coords(
    coordinates$xcoord, coordinates$ycoord, config = config
  )
  expect_identical(recovered, ids)
})

test_that("coordinate lookup handles invalid and outside coordinates", {
  config <- test_config()
  expect_true(is.na(pg_id_from_coords(NA_real_, 0, config = config)))
  expect_error(
    pg_id_from_coords(NA_real_, 0, outside = "error", config = config),
    "positions"
  )
  expect_error(
    pg_id_from_coords(c(0, 1), c(0, 1, 2), config = config),
    "equal lengths"
  )
})

test_that("ID lookup validates cells and can retain invalid rows", {
  config <- test_config()
  expect_error(pg_coords_from_id(0, config = config), "positions")
  result <- pg_coords_from_id(c(1, 0), invalid = "NA", config = config)
  expect_equal(result$pgid, c(1L, 0L))
  expect_true(is.na(result$xcoord[2]))
})

test_that("pg_geometry returns requested cells in requested order", {
  config <- test_config()
  polygons <- pg_geometry(c(3, 1), config = config)
  points <- pg_geometry(c(3, 1), geometry = "point", config = config)
  expect_s3_class(polygons, "sf")
  expect_s3_class(points, "sf")
  expect_identical(polygons$pgid, c(3L, 1L))
  expect_identical(points$pgid, c(3L, 1L))
  expect_true(all(sf::st_geometry_type(polygons) %in% c("POLYGON", "MULTIPOLYGON")))
  expect_true(all(sf::st_geometry_type(points) == "POINT"))
})

test_that("pg_validate_data reports valid and invalid panels", {
  config <- test_config()
  valid <- data.frame(pgid = 1:3, year = 2020L, value = 1:3)
  result <- pg_validate_data(valid, time = "year", config = config)
  expect_s3_class(result, "pg_validation")
  expect_true(result$valid)

  invalid <- rbind(valid, valid[1, ])
  result <- pg_validate_data(invalid, time = "year", config = config)
  expect_false(result$valid)
  expect_true("duplicate_keys" %in% result$issues$check)

  incomplete <- pg_validate_data(
    valid, time = "year", require_complete = TRUE, config = config
  )
  expect_false(incomplete$valid)
  expect_true("missing_combinations" %in% incomplete$issues$check)
})

test_that("pg_complete_panel fills only newly introduced rows", {
  config <- test_config()
  input <- data.frame(
    pgid = c(1L, 2L),
    year = c(2020L, 2020L),
    events = c(NA_integer_, 2L)
  )
  result <- pg_complete_panel(
    input,
    time = "year",
    cells = 1:2,
    times = 2020:2021,
    fill = list(events = 0L),
    config = config
  )
  expect_equal(nrow(result), 4L)
  expect_true(is.na(result$events[result$pgid == 1L & result$year == 2020L]))
  expect_true(all(result$events[result$year == 2021L] == 0L))
})

test_that("pg_complete_panel rejects duplicate keys", {
  config <- test_config()
  input <- data.frame(pgid = c(1L, 1L), value = 1:2)
  expect_error(pg_complete_panel(input, config = config), "duplicate")
})

test_that("pg_join checks relationships and unmatched keys", {
  x <- data.frame(pgid = c(1L, 1L, 2L), value = 1:3)
  y <- data.frame(pgid = 1:2, region = c("a", "b"))
  result <- pg_join(x, y)
  expect_equal(nrow(result), 3L)
  expect_equal(result$region, c("a", "a", "b"))

  duplicate_y <- rbind(y, y[1, ])
  expect_error(pg_join(x, duplicate_y), "many-to-one")
  expect_error(
    pg_join(x, data.frame(pgid = 1L), unmatched = "error"),
    "Unmatched"
  )
})

test_that("pg_plot returns a ggplot and validates temporal selection", {
  config <- test_config()
  input <- data.frame(
    pgid = rep(1:2, 2),
    year = rep(2020:2021, each = 2),
    value = 1:4
  )
  plot <- pg_plot(
    input, "value", time = "year", time_value = 2020,
    config = config
  )
  expect_s3_class(plot, "ggplot")
  expect_error(
    pg_plot(input, "value", time = "year", config = config),
    "time_value"
  )
})
