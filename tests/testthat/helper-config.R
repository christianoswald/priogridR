test_config <- function() {
  priogrid::pg_config(
    nrow = 18,
    ncol = 36,
    start_date = as.Date("2000-12-31"),
    end_date = as.Date("2001-12-31"),
    temporal_resolution = "1 year"
  )
}

test_priogrid_rawfolder <- function() {
  path <- file.path(tempdir(), "priogridR-tests")
  dir.create(path, recursive = TRUE, showWarnings = FALSE)
  path <- normalizePath(path, winslash = "/", mustWork = TRUE)
  priogrid::pg_set_rawfolder(path)
  invisible(path)
}

test_cell_center <- function(pgid = 325L, config = test_config()) {
  pg_coords_from_id(pgid, config = config)[1L, ]
}

test_square <- function(pgid = 325L, value = NULL, config = test_config()) {
  center <- test_cell_center(pgid, config)
  ring <- matrix(
    c(
      center$xcoord - 1, center$ycoord - 1,
      center$xcoord + 1, center$ycoord - 1,
      center$xcoord + 1, center$ycoord + 1,
      center$xcoord - 1, center$ycoord + 1,
      center$xcoord - 1, center$ycoord - 1
    ),
    ncol = 2,
    byrow = TRUE
  )
  result <- sf::st_sf(
    source_id = "A",
    geometry = sf::st_sfc(sf::st_polygon(list(ring)), crs = 4326)
  )
  if (!is.null(value)) result$value <- value
  result
}

