#' Convert point or event data to PRIO-GRID
#'
#' @param x A data frame, `sf` object, `SpatVector`, or vector-file path.
#' @param variable Name of the resulting variable.
#' @param longitude,latitude Coordinate-column names for tabular input.
#' @param value Optional source value column.
#' @param aggregation Point aggregation rule.
#' @param time Optional static observation date or year.
#' @param time_column Optional observation-date column.
#' @param group_columns Optional additional grouping columns.
#' @param input_crs CRS of tabular coordinates.
#' @param keep_empty Complete unobserved cells with zero when meaningful?
#' @param return One of `"data"`, `"raster"`, or `"result"`.
#' @param config A PRIO-GRID configuration object.
#' @param filename Optional output filename.
#' @param overwrite Replace an existing output file?
#' @return A data frame, `SpatRaster`, or `pg_result`.
#' @examples
#' events <- data.frame(
#'   longitude = c(10, 10.1, 20),
#'   latitude = c(50, 50.1, 60)
#' )
#' config <- priogrid::pg_config(nrow = 18, ncol = 36, verbose = FALSE)
#' pg_from_points(
#'   events,
#'   variable = "event_count",
#'   longitude = "longitude",
#'   latitude = "latitude",
#'   aggregation = "count",
#'   config = config
#' )
#' @export
pg_from_points <- function(
  x,
  variable,
  longitude = NULL,
  latitude = NULL,
  value = NULL,
  aggregation = c("count", "presence", "sum", "mean", "min", "max"),
  time = NULL,
  time_column = NULL,
  group_columns = NULL,
  input_crs = 4326,
  keep_empty = FALSE,
  return = c("data", "raster", "result"),
  config = priogrid::pg_current_config(),
  filename = NULL,
  overwrite = FALSE
) {
  aggregation <- match.arg(aggregation)
  return <- match.arg(return)
  points <- as_point_sf(x, longitude, latitude, input_crs)
  pg_from_vector(
    x = points,
    variable = variable,
    value = value,
    aggregation = aggregation,
    geometry = "point",
    time = time,
    time_column = time_column,
    group_columns = group_columns,
    keep_empty = keep_empty,
    return = return,
    config = config,
    filename = filename,
    overwrite = overwrite
  )
}

