test_that("pg_paths creates and reports conventional project directories", {
  root <- tempfile("priogridR-paths-")
  paths <- pg_paths(
    root,
    raw = "inputs",
    processed = "outputs",
    temporary = "scratch",
    create = TRUE
  )

  expect_named(paths, c("root", "raw", "processed", "temporary"))
  expect_true(all(vapply(paths[-1L], dir.exists, logical(1))))
  expect_identical(paths$raw, file.path(paths$root, "inputs"))
})

test_that("time helpers normalize supported values and reject invalid input", {
  config <- test_config()

  expect_identical(
    priogridR:::normalize_pg_time(as.Date("2000-12-31"), 1L, config),
    as.Date("2000-12-31")
  )
  expect_identical(
    priogridR:::normalize_pg_time(
      as.POSIXct("2000-12-31 12:00:00", tz = "UTC"), 1L, config
    ),
    as.Date("2000-12-31")
  )
  expect_identical(
    priogridR:::normalize_pg_time(2001, 1L, config),
    as.Date("2001-12-31")
  )
  expect_error(
    priogridR:::normalize_pg_time(2000:2001, 1L, config),
    "one value per raster layer"
  )
  expect_error(
    priogridR:::normalize_pg_time("not-a-date", 1L, config),
    "date-like strings"
  )
})

test_that("temporal mapping rejects dates outside configured intervals", {
  config <- test_config()
  x <- data.frame(date = as.Date("1999-12-31"))
  malformed <- data.frame(date = "not-a-date")

  expect_true(is.na(
    priogridR:::map_dates_to_pg_intervals(x$date, config)
  ))
  expect_error(
    priogridR:::map_dates_to_pg_intervals(malformed$date, config),
    "cannot be converted to Date"
  )
  expect_error(
    priogridR:::add_measurement_date(
      malformed, time_column = "date", config = config
    ),
    "cannot be converted to Date"
  )
  expect_error(
    priogridR:::add_measurement_date(x, time_column = "date", config = config),
    "outside the configured intervals"
  )
  expect_error(
    priogridR:::add_measurement_date(x, time = 1999, config = config),
    "outside the configured intervals"
  )
  expect_error(
    priogridR:::add_measurement_date(
      x, time = 2000, time_column = "date", config = config
    ),
    "only one"
  )
})

test_that("grouping retains missing group values", {
  x <- data.frame(
    pgid = c(1L, 1L, 1L),
    group = c("a", NA, "a"),
    value = c(1, 2, 3)
  )
  groups <- priogridR:::group_rows(x, c("pgid", "group"))

  expect_length(groups, 2L)
  expect_setequal(unlist(groups, use.names = FALSE), seq_len(nrow(x)))

  output <- priogridR:::summarise_point_groups(
    x,
    variable = "total",
    value = "value",
    aggregation = "sum",
    group_columns = c("pgid", "group")
  )
  expect_equal(nrow(output), 2L)
  expect_true(anyNA(output$group))
})

test_that("observed all-missing sums remain missing", {
  x <- data.frame(pgid = 1L, value = NA_real_)
  output <- priogridR:::summarise_point_groups(
    x,
    variable = "total",
    value = "value",
    aggregation = "sum",
    group_columns = "pgid"
  )

  expect_true(is.na(output$total))

  completed <- priogridR:::fill_empty_pg_cells(
    output,
    variable = "total",
    aggregation = "sum",
    config = test_config()
  )
  expect_true(is.na(completed$total[completed$pgid == 1L]))
  expect_true(all(completed$total[completed$pgid != 1L] == 0))
})

test_that("empty conversion outputs preserve group-column prototypes", {
  prototype <- data.frame(
    category = factor(character(), levels = c("a", "b")),
    identifier = integer()
  )
  output <- priogridR:::empty_pg_data(
    "events",
    temporal = TRUE,
    group_columns = c("category", "identifier"),
    prototype = prototype
  )

  expect_s3_class(output$category, "factor")
  expect_type(output$identifier, "integer")
  expect_s3_class(output$measurement_date, "Date")
})

test_that("raster construction rejects duplicate cell-period keys", {
  config <- test_config()
  duplicate_static <- data.frame(pgid = c(1L, 1L), value = c(1, 2))
  duplicate_temporal <- data.frame(
    pgid = c(1L, 1L),
    measurement_date = as.Date(c("2000-12-31", "2000-12-31")),
    value = c(1, 2)
  )

  expect_error(
    priogridR:::pg_data_to_raster(duplicate_static, "value", config),
    "duplicate PRIO-GRID cell-period keys"
  )
  expect_error(
    priogridR:::pg_data_to_raster(duplicate_temporal, "value", config),
    "duplicate PRIO-GRID cell-period keys"
  )
})

test_that("pg_result validates, prints, and handles missing components", {
  raster <- terra::rast(nrows = 2, ncols = 2, vals = 1:4)
  result <- priogridR:::new_pg_result(
    data = data.frame(pgid = 1L, value = 2),
    raster = raster,
    metadata = list(variable = "value")
  )

  expect_output(print(result), "Rows: 1")
  expect_output(print(result), "Raster layers: 1")
  expect_output(print(result), "Variable: value")
  expect_error(priogridR:::new_pg_result(data = 1), "data frame")
  expect_error(priogridR:::new_pg_result(raster = 1), "SpatRaster")
  expect_error(priogridR:::new_pg_result(metadata = "x"), "list")
  expect_error(
    as.data.frame(priogridR:::new_pg_result(raster = raster)),
    "does not contain tabular data"
  )
})

test_that("pg_write_result validates formats and routes result components", {
  table_result <- priogridR:::new_pg_result(
    data = data.frame(pgid = 1L, value = 2)
  )
  raster <- terra::rast(nrows = 2, ncols = 2, vals = 1:4)
  raster_result <- priogridR:::new_pg_result(raster = raster)
  csv <- tempfile(fileext = ".csv")
  tif <- tempfile(fileext = ".tif")

  expect_identical(pg_write_result(table_result, csv), csv)
  expect_identical(pg_write_result(raster_result, tif), tif)
  expect_true(file.exists(csv))
  expect_true(file.exists(tif))
  expect_error(pg_write_result(table_result, tempfile(fileext = ".tif")),
               "does not contain raster data")
  expect_error(pg_write_result(raster_result, tempfile(fileext = ".csv")),
               "does not contain tabular data")
  expect_error(pg_write_result(data.frame(x = 1), tempfile(fileext = ".txt")),
               "Unsupported table extension")
  expect_error(pg_write_result(list(x = 1), tempfile(fileext = ".rds")),
               "must be a `pg_result`")
  expect_error(pg_write_result(data.frame(x = 1), character()),
               "one non-empty file path")
})

test_that("input readers reject invalid paths and coordinates", {
  raster <- terra::rast(nrows = 2, ncols = 2, vals = 1:4)
  points <- sf::st_as_sf(
    data.frame(x = 0, y = 0), coords = c("x", "y"), crs = 4326
  )

  expect_identical(priogridR:::read_raster_input(raster), raster)
  expect_s3_class(
    priogridR:::read_vector_input(terra::vect(points)),
    "sf"
  )
  expect_error(
    priogridR:::read_raster_input("missing-raster.tif"),
    "do not exist"
  )
  expect_error(
    priogridR:::read_vector_input("missing-vector.gpkg"),
    "does not exist"
  )
  expect_error(
    priogridR:::as_point_sf(
      data.frame(lon = "x", lat = 1), "lon", "lat"
    ),
    "must be numeric"
  )
  expect_error(
    priogridR:::as_point_sf(
      data.frame(lon = Inf, lat = 1), "lon", "lat"
    ),
    "finite values"
  )
})

test_that("vector conversion rejects missing CRS and invalid geometries", {
  config <- test_config()
  missing_crs <- sf::st_sf(
    geometry = sf::st_sfc(sf::st_point(c(0, 0)))
  )
  invalid_ring <- matrix(
    c(0, 0, 1, 1, 0, 1, 1, 0, 0, 0),
    ncol = 2,
    byrow = TRUE
  )
  invalid <- sf::st_sf(
    geometry = sf::st_sfc(sf::st_polygon(list(invalid_ring)), crs = 3857)
  )
  empty <- sf::st_sf(
    geometry = sf::st_sfc(sf::st_point(), crs = 4326)
  )

  expect_error(
    pg_from_vector(missing_crs, "events", aggregation = "count", config = config),
    "coordinate reference system"
  )
  expect_error(
    pg_from_vector(invalid, "area", aggregation = "area", config = config),
    "invalid geometries"
  )
  expect_error(
    pg_from_vector(empty, "events", aggregation = "count", config = config),
    "empty geometries"
  )
})
