#' Transfer geographically indexed table data to PRIO-GRID
#'
#' @param x A data frame containing values.
#' @param variable Name of the resulting variable.
#' @param value Source value-column name.
#' @param geography Polygon geometries defining the source units.
#' @param source_id Identifier column in `x`.
#' @param geography_id Matching identifier column in `geography`.
#' @param time Optional static observation date or year.
#' @param time_column Optional observation-date column.
#' @param aggregation Spatial transfer rule.
#' @param return One of `"data"`, `"raster"`, or `"result"`.
#' @param config A PRIO-GRID configuration object.
#' @param filename Optional output filename.
#' @param overwrite Replace an existing output file?
#' @return A data frame, `SpatRaster`, or `pg_result`.
#' @export
pg_from_table <- function(
  x,
  variable,
  value,
  geography,
  source_id,
  geography_id,
  time = NULL,
  time_column = NULL,
  aggregation = c("area_weighted_mean", "area_weighted_sum", "constant"),
  return = c("data", "raster", "result"),
  config = priogrid::pg_current_config(),
  filename = NULL,
  overwrite = FALSE
) {
  aggregation <- match.arg(aggregation)
  return <- match.arg(return)
  if (!is.data.frame(x)) {
    stop("`x` must be a data frame.", call. = FALSE)
  }
  validate_columns(x, c(source_id, value, time_column))
  geography <- read_vector_input(geography)
  validate_columns(geography, geography_id)
  merged <- merge(
    geography,
    x,
    by.x = geography_id,
    by.y = source_id,
    all = FALSE,
    sort = FALSE
  )
  vector_aggregation <- switch(
    aggregation,
    area_weighted_mean = "weighted_mean",
    area_weighted_sum = "weighted_sum",
    constant = "mean"
  )
  pg_from_vector(
    x = merged,
    variable = variable,
    value = value,
    aggregation = vector_aggregation,
    geometry = "polygon",
    time = time,
    time_column = time_column,
    return = return,
    config = config,
    filename = filename,
    overwrite = overwrite
  )
}

