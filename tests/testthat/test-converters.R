test_that("raster conversion preserves an already aligned static surface", {
  test_priogrid_rawfolder()
  config <- test_config()
  source <- terra::rast(
    nrows = 18, ncols = 36,
    xmin = -180, xmax = 180, ymin = -90, ymax = 90,
    crs = "EPSG:4326"
  )
  terra::values(source) <- seq_len(terra::ncell(source))

  output <- pg_from_raster(
    source,
    variable = "surface",
    aggregation = "mean",
    config = config
  )

  expect_s3_class(output, "data.frame")
  expect_true(all(c("pgid", "surface") %in% names(output)))
  expect_equal(nrow(output), terra::ncell(source))
  expect_equal(sort(output$surface), sort(terra::values(source)[, 1L]))
})

test_that("raster conversion handles files, missing values, and return types", {
  test_priogrid_rawfolder()
  config <- test_config()
  source <- terra::rast(
    nrows = 18, ncols = 36,
    xmin = -180, xmax = 180, ymin = -90, ymax = 90,
    crs = "EPSG:4326"
  )
  values <- rep(2, terra::ncell(source))
  values[1L] <- -9999
  terra::values(source) <- values
  path <- tempfile(fileext = ".tif")
  terra::writeRaster(source, path)

  output <- pg_from_raster(
    path,
    variable = "surface",
    aggregation = "mean",
    na_values = -9999,
    return = "result",
    config = config
  )

  expect_s3_class(output, "pg_result")
  expect_s4_class(output$raster, "SpatRaster")
  expect_false(any(output$data$surface == -9999, na.rm = TRUE))
  expect_true(
    anyNA(output$data$surface) ||
      nrow(output$data) < terra::ncell(source)
  )
  expect_true(all(output$data$surface == 2, na.rm = TRUE))
})

test_that("raster conversion requires time for multiple layers", {
  test_priogrid_rawfolder()
  config <- test_config()
  layer <- terra::rast(
    nrows = 18, ncols = 36,
    xmin = -180, xmax = 180, ymin = -90, ymax = 90,
    crs = "EPSG:4326", vals = 1
  )
  source <- c(layer, layer + 1)

  expect_error(
    pg_from_raster(
      source, "surface", aggregation = "mean", config = config
    ),
    "require one `time` value"
  )
  output <- pg_from_raster(
    source,
    "surface",
    aggregation = "mean",
    time = 2000:2001,
    config = config
  )
  expect_equal(length(unique(output$measurement_date)), 2L)
})

test_that("NetCDF conversion uses raster time and supports layer selection", {
  test_priogrid_rawfolder()
  config <- test_config()
  layer <- terra::rast(
    nrows = 18, ncols = 36,
    xmin = -180, xmax = 180, ymin = -90, ymax = 90,
    crs = "EPSG:4326", vals = 1
  )
  source <- c(layer, layer + 1)
  terra::time(source) <- as.Date(c("2000-12-31", "2001-12-31"))

  output <- pg_from_netcdf(
    source,
    variable = "climate",
    aggregation = "mean",
    config = config
  )
  selected <- pg_from_netcdf(
    source,
    variable = "climate",
    aggregation = "mean",
    layer = 1,
    config = config
  )

  expect_equal(length(unique(output$measurement_date)), 2L)
  expect_equal(length(unique(selected$measurement_date)), 1L)
  expect_error(
    pg_from_netcdf("missing-file.nc", "x", aggregation = "mean"),
    "NetCDF file path"
  )
})

test_that("line conversion calculates positive length within one cell", {
  config <- test_config()
  center <- test_cell_center(config = config)
  line <- sf::st_sf(
    source_id = "A",
    geometry = sf::st_sfc(
      sf::st_linestring(matrix(
        c(
          center$xcoord - 1, center$ycoord,
          center$xcoord + 1, center$ycoord
        ),
        ncol = 2,
        byrow = TRUE
      )),
      crs = 4326
    )
  )

  output <- pg_from_vector(
    line,
    variable = "road_length",
    aggregation = "length",
    config = config
  )

  expect_equal(nrow(output), 1L)
  expect_equal(output$pgid, 325L)
  expect_gt(output$road_length, 0)
})

test_that("polygon conversion supports values, CRS conversion, and results", {
  config <- test_config()
  polygon <- test_square(value = 10, config = config)
  polygon <- sf::st_transform(polygon, 3857)

  output <- pg_from_vector(
    polygon,
    variable = "score",
    value = "value",
    aggregation = "weighted_mean",
    return = "result",
    config = config
  )

  expect_s3_class(output, "pg_result")
  expect_s4_class(output$raster, "SpatRaster")
  expect_equal(output$data$pgid, 325L)
  expect_equal(output$data$score, 10)
})

test_that("vector conversion validates geometry and grouped return types", {
  config <- test_config()
  points <- sf::st_as_sf(
    data.frame(x = c(0, 1), y = c(0, 1), group = c("a", "b")),
    coords = c("x", "y"),
    crs = 4326
  )

  expect_error(
    pg_from_vector(
      points, "events", aggregation = "count", geometry = "line",
      config = config
    ),
    "does not match"
  )
  expect_error(
    pg_from_vector(
      points, "events", aggregation = "count", group_columns = "group",
      return = "raster", config = config
    ),
    "Grouped vector results"
  )
})

test_that("table conversion transfers matched values", {
  config <- test_config()
  geography <- test_square(config = config)
  values <- data.frame(source_id = "A", total = 100)

  output <- pg_from_table(
    values,
    variable = "total",
    value = "total",
    geography = geography,
    source_id = "source_id",
    geography_id = "source_id",
    aggregation = "constant",
    config = config
  )

  expect_equal(output$pgid, 325L)
  expect_equal(output$total, 100)
})

test_that("table conversion rejects ambiguous and unmatched identifiers", {
  config <- test_config()
  geography <- test_square(config = config)
  duplicate_geography <- rbind(geography, geography)

  expect_error(
    pg_from_table(
      data.frame(source_id = "A", value = 1), "value", "value",
      duplicate_geography, "source_id", "source_id", config = config
    ),
    "uniquely identify"
  )
  expect_error(
    pg_from_table(
      data.frame(source_id = "B", value = 1), "value", "value",
      geography, "source_id", "source_id", config = config
    ),
    "no matching geography"
  )
  expect_error(
    pg_from_table(
      data.frame(source_id = c("A", "A"), value = 1:2),
      "value", "value", geography, "source_id", "source_id",
      config = config
    ),
    "duplicate geography-time"
  )
})

test_that("result writing covers ordinary R table formats", {
  source <- data.frame(pgid = 1:2, value = c(2, 4))
  csv <- tempfile(fileext = ".csv")
  rds <- tempfile(fileext = ".rds")

  expect_identical(pg_write_result(source, csv), csv)
  expect_identical(pg_write_result(source, rds), rds)
  expect_equal(utils::read.csv(csv), source)
  expect_equal(readRDS(rds), source)
})
