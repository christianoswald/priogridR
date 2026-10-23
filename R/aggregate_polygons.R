aggregate_pg_polygons <- function(
  x,
  variable,
  value = NULL,
  aggregation,
  time = NULL,
  time_column = NULL,
  group_columns = NULL,
  config = priogrid::pg_current_config()
) {
  needs_value <- aggregation %in% c(
    "sum", "mean", "weighted_mean", "weighted_sum", "min", "max", "modal"
  )
  if (needs_value) {
    if (is.null(value)) {
      stop("`value` is required for this polygon aggregation.", call. = FALSE)
    }
    validate_columns(x, value)
  }
  if (length(group_columns)) {
    validate_columns(x, group_columns)
  }
  x <- add_measurement_date(x, time, time_column, config)
  grid <- pg_grid_as_sf(config)
  x <- sf::st_transform(x, sf::st_crs(grid))
  validate_geodesic_engine(grid)
  x$.feature_id <- seq_len(nrow(x))
  x$.source_area <- geometry_area_m2(x)
  grid$.cell_area <- geometry_area_m2(grid)
  keep <- unique(c(
    value, "measurement_date", group_columns, ".feature_id", ".source_area"
  ))
  keep <- keep[keep %in% names(x)]
  intersections <- suppressWarnings(sf::st_intersection(
    grid[c("pgid", ".cell_area")],
    x[keep]
  ))
  if (!nrow(intersections)) {
    return(empty_pg_data(variable, !is.null(time) || !is.null(time_column), group_columns))
  }
  intersections$.overlap_area <- geometry_area_m2(intersections)
  data <- sf::st_drop_geometry(intersections)
  grouping <- c(
    "pgid",
    if ("measurement_date" %in% names(data)) "measurement_date",
    group_columns
  )
  groups <- group_rows(data, grouping)
  output <- lapply(groups, function(index) {
    row <- data[index[1L], grouping, drop = FALSE]
    area <- data$.overlap_area[index]
    values <- if (is.null(value)) NULL else data[[value]][index]
    result <- switch(
      aggregation,
      area = sum(area, na.rm = TRUE),
      area_share = min(
        1,
        geometry_area_m2(sf::st_union(intersections[index, ])) /
          data$.cell_area[index[1L]]
      ),
      coverage = min(
        1,
        geometry_area_m2(sf::st_union(intersections[index, ])) /
          data$.cell_area[index[1L]]
      ),
      count = length(unique(data$.feature_id[index])),
      presence = 1,
      sum = sum(values, na.rm = TRUE),
      mean = if (all(is.na(values))) NA_real_ else mean(values, na.rm = TRUE),
      weighted_mean = if (all(is.na(values))) {
        NA_real_
      } else {
        stats::weighted.mean(values, w = area, na.rm = TRUE)
      },
      weighted_sum = sum(
        values * (area / data$.source_area[index]),
        na.rm = TRUE
      ),
      min = if (all(is.na(values))) NA_real_ else min(values, na.rm = TRUE),
      max = if (all(is.na(values))) NA_real_ else max(values, na.rm = TRUE),
      modal = if (all(is.na(values))) {
        NA_character_
      } else {
        weights <- tapply(area, as.character(values), sum, na.rm = TRUE)
        names(weights)[which.max(weights)]
      }
    )
    row[[variable]] <- result
    row
  })
  result <- do.call(rbind, output)
  rownames(result) <- NULL
  result
}

