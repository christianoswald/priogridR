#' Convert vector data to PRIO-GRID
#'
#' @param x An `sf` object, `SpatVector`, or vector-file path.
#' @param variable Name of the resulting variable.
#' @param value Optional source value column.
#' @param aggregation Geometry-specific aggregation rule.
#' @param geometry Geometry type, or `"auto"`.
#' @param time Optional static observation date or year.
#' @param time_column Optional observation-date column.
#' @param group_columns Optional additional grouping columns.
#' @param keep_empty For points, complete unobserved cells with zero when the
#'   aggregation has a meaningful zero.
#' @param return One of `"data"`, `"raster"`, or `"result"`.
#' @param config A PRIO-GRID configuration object.
#' @param filename Optional output filename.
#' @param overwrite Replace an existing output file?
#' @return A data frame, `SpatRaster`, or `pg_result`.
#' @export
pg_from_vector <- function(
  x,
  variable,
  value = NULL,
  aggregation,
  geometry = c("auto", "point", "line", "polygon"),
  time = NULL,
  time_column = NULL,
  group_columns = NULL,
  keep_empty = FALSE,
  return = c("data", "raster", "result"),
  config = priogrid::pg_current_config(),
  filename = NULL,
  overwrite = FALSE
) {
  geometry <- match.arg(geometry)
  return <- match.arg(return)
  validate_variable(variable)
  validate_pg_config(config)
  vector <- read_vector_input(x)
  if (!nrow(vector)) {
    stop("`x` contains no vector features.", call. = FALSE)
  }
  detected <- detect_geometry_type(vector)
  if (geometry == "auto") {
    geometry <- detected
  }
  if (geometry != detected) {
    stop("`geometry` does not match the input geometry type.", call. = FALSE)
  }
  allowed <- switch(
    geometry,
    point = c("count", "presence", "sum", "mean", "min", "max"),
    line = c("length", "length_density", "count", "presence"),
    polygon = c(
      "area", "area_share", "coverage", "count", "presence", "sum", "mean",
      "weighted_mean", "weighted_sum", "min", "max", "modal"
    )
  )
  validate_choice(aggregation, allowed, "aggregation")
  data <- switch(
    geometry,
    point = aggregate_pg_points(
      vector, variable, value, aggregation, time, time_column,
      group_columns, keep_empty, config
    ),
    line = aggregate_pg_lines(
      vector, variable, aggregation, time, time_column,
      group_columns, config
    ),
    polygon = aggregate_pg_polygons(
      vector, variable, value, aggregation, time, time_column,
      group_columns, config
    )
  )
  if (length(group_columns) && return != "data") {
    stop(
      "Grouped vector results support only `return = \"data\"`.",
      call. = FALSE
    )
  }
  finalize_pg_output(
    data,
    NULL,
    variable,
    geometry,
    aggregation,
    return,
    config,
    filename,
    overwrite
  )
}
