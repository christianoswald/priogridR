aggregate_pg_points <- function(
  x,
  variable,
  value = NULL,
  aggregation,
  time = NULL,
  time_column = NULL,
  group_columns = NULL,
  keep_empty = FALSE,
  config = priogrid::pg_current_config()
) {
  if (aggregation %in% c("sum", "mean", "min", "max")) {
    if (is.null(value)) {
      stop("`value` is required for this point aggregation.", call. = FALSE)
    }
    validate_columns(x, value)
  }
  if (length(group_columns)) {
    validate_columns(x, group_columns)
  }
  x <- add_measurement_date(x, time, time_column, config)
  if (!nrow(x)) {
    return(empty_pg_data(
      variable,
      temporal = !is.null(time) || !is.null(time_column),
      group_columns = group_columns
    ))
  }
  if (any(sf::st_geometry_type(x) == "MULTIPOINT")) {
    x <- suppressWarnings(sf::st_cast(x, "POINT"))
  }
  template <- pg_blank(config)
  x <- sf::st_transform(x, terra::crs(template))
  pgid <- terra::extract(template, terra::vect(x), ID = FALSE)[[1L]]
  data <- sf::st_drop_geometry(x)
  data$pgid <- pgid
  data <- data[!is.na(data$pgid), , drop = FALSE]
  grouping <- c(
    "pgid",
    if ("measurement_date" %in% names(data)) "measurement_date",
    group_columns
  )
  result <- summarise_point_groups(
    data,
    variable,
    value,
    aggregation,
    grouping
  )
  if (isTRUE(keep_empty) && !length(group_columns)) {
    result <- fill_empty_pg_cells(result, variable, aggregation, config)
  }
  result
}

