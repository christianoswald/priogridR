aggregate_pg_lines <- function(
  x,
  variable,
  aggregation,
  time = NULL,
  time_column = NULL,
  group_columns = NULL,
  config = priogrid::pg_current_config()
) {
  if (length(group_columns)) {
    validate_columns(x, group_columns)
  }
  x <- add_measurement_date(x, time, time_column, config)
  grid <- pg_grid_as_sf(config)
  x <- sf::st_transform(x, sf::st_crs(grid))
  validate_geodesic_engine(grid)
  x$.feature_id <- seq_len(nrow(x))
  grid$.cell_area <- geometry_area_m2(grid)
  keep <- unique(c("measurement_date", group_columns, ".feature_id"))
  keep <- keep[keep %in% names(x)]
  intersections <- suppressWarnings(sf::st_intersection(
    grid[c("pgid", ".cell_area")],
    x[keep]
  ))
  if (!nrow(intersections)) {
    return(empty_pg_data(variable, !is.null(time) || !is.null(time_column), group_columns))
  }
  intersections$.segment_length <- geometry_length_m(intersections)
  data <- sf::st_drop_geometry(intersections)
  grouping <- c(
    "pgid",
    if ("measurement_date" %in% names(data)) "measurement_date",
    group_columns
  )
  groups <- group_rows(data, grouping)
  output <- lapply(groups, function(index) {
    row <- data[index[1L], grouping, drop = FALSE]
    result <- switch(
      aggregation,
      length = sum(data$.segment_length[index], na.rm = TRUE),
      length_density = sum(data$.segment_length[index], na.rm = TRUE) /
        data$.cell_area[index[1L]],
      count = length(unique(data$.feature_id[index])),
      presence = 1
    )
    row[[variable]] <- result
    row
  })
  result <- do.call(rbind, output)
  rownames(result) <- NULL
  result
}
