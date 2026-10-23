#' Convert raster data to PRIO-GRID
#'
#' @param x A `SpatRaster` or one or more raster-file paths.
#' @param variable Name of the resulting variable.
#' @param aggregation Spatial aggregation passed as `agg_fun` to
#'   [priogrid::robust_transformation()].
#' @param time Optional date or year for each raster layer.
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
#' @export
pg_from_raster <- function(
  x,
  variable,
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
  validate_variable(variable)
  validate_choice(
    aggregation,
    c("sum", "mean", "min", "max", "median", "modal"),
    "aggregation"
  )
  validate_pg_config(config)
  raster <- read_raster_input(x)
  if (!is.null(layer)) {
    raster <- raster[[layer]]
  }
  if (!is.null(na_values)) {
    raster <- terra::subst(raster, from = na_values, to = NA)
  }
  pg_time <- normalize_pg_time(time, terra::nlyr(raster), config)
  if (is.null(pg_time) && terra::nlyr(raster) != 1L) {
    stop("Multi-layer rasters require one `time` value per layer.", call. = FALSE)
  }
  aligned <- transform_raster_to_pg(
    raster,
    aggregation,
    disagg_method,
    config,
    ...
  )
  if (is.null(pg_time)) {
    names(aligned) <- variable
  } else {
    names(aligned) <- format(pg_time, "%Y-%m-%d")
  }
  data <- if (return %in% c("data", "result")) {
    raster_to_pg_data(aligned, variable, pg_time, config)
  } else {
    NULL
  }
  result <- switch(
    return,
    data = data,
    raster = aligned,
    result = new_pg_result(
      data,
      aligned,
      list(
        variable = variable,
        source_type = "raster",
        aggregation = aggregation,
        time = pg_time,
        config = config
      )
    )
  )
  if (!is.null(filename)) {
    write_pg_result(result, filename, overwrite)
  }
  result
}

