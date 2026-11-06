#' Convert NetCDF data to PRIO-GRID
#'
#' @param x A NetCDF path or `SpatRaster` opened from NetCDF.
#' @param variable Name of the resulting variable.
#' @param source_variable Optional NetCDF subdataset name.
#' @param aggregation Spatial raster aggregation rule.
#' @param time Optional explicit layer dates or years.
#' @param layer Optional layer selection passed to `[[`.
#' @param na_values Optional source values to replace with `NA`.
#' @param disagg_method Disaggregation method.
#' @param return One of `"data"`, `"raster"`, or `"result"`.
#' @param config A PRIO-GRID configuration object.
#' @param filename Optional output filename.
#' @param overwrite Replace an existing output file?
#' @param ... Additional arguments passed to
#'   [priogrid::robust_transformation()].
#' @return A data frame, `SpatRaster`, or `pg_result`.
#' @examplesIf interactive()
#' priogrid::pg_set_rawfolder(file.path(tempdir(), "priogrid-example"))
#' climate <- terra::rast(
#'   nrows = 18, ncols = 36, nlyrs = 2,
#'   xmin = -180, xmax = 180, ymin = -90, ymax = 90,
#'   crs = "EPSG:4326", vals = 1:(648 * 2)
#' )
#' config <- priogrid::pg_config(
#'   nrow = 18, ncol = 36,
#'   start_date = as.Date("2020-12-31"),
#'   end_date = as.Date("2021-12-31"),
#'   temporal_resolution = "1 year",
#'   verbose = FALSE
#' )
#' pg_from_netcdf(
#'   climate,
#'   variable = "temperature",
#'   aggregation = "mean",
#'   time = 2020:2021,
#'   config = config
#' )
#' @export
pg_from_netcdf <- function(
  x,
  variable,
  source_variable = NULL,
  aggregation,
  time = NULL,
  layer = NULL,
  na_values = NULL,
  disagg_method = c("near", "bilinear", "cubic"),
  return = c("data", "raster", "result"),
  config = priogrid::pg_current_config(),
  filename = NULL,
  overwrite = FALSE,
  ...
) {
  return <- match.arg(return)
  disagg_method <- match.arg(disagg_method)
  if (inherits(x, "SpatRaster")) {
    raster <- x
  } else {
    if (!is.character(x) || length(x) != 1L || !file.exists(x)) {
      stop("`x` must be a NetCDF file path or SpatRaster.", call. = FALSE)
    }
    raster <- if (is.null(source_variable)) {
      terra::rast(x)
    } else {
      terra::rast(x, subds = source_variable)
    }
  }
  if (!is.null(layer)) {
    raster <- raster[[layer]]
  }
  if (is.null(time)) {
    raster_time <- try(terra::time(raster), silent = TRUE)
    valid_time <- !inherits(raster_time, "try-error") &&
      length(raster_time) == terra::nlyr(raster) &&
      !all(is.na(raster_time))
    if (valid_time) {
      time <- as.Date(raster_time)
    }
  }
  pg_from_raster(
    x = raster,
    variable = variable,
    aggregation = aggregation,
    time = time,
    na_values = na_values,
    disagg_method = disagg_method,
    return = return,
    config = config,
    filename = filename,
    overwrite = overwrite,
    ...
  )
}

