group_rows <- function(x, group_columns) {
  if (!nrow(x)) {
    return(list())
  }
  if (!length(group_columns)) {
    return(list(seq_len(nrow(x))))
  }
  key_parts <- lapply(x[group_columns], function(value) {
    if (inherits(value, "Date")) format(value, "%Y-%m-%d") else as.character(value)
  })
  key <- do.call(
    interaction,
    c(key_parts, list(drop = TRUE, lex.order = TRUE, sep = "\r"))
  )
  split(seq_len(nrow(x)), key, drop = TRUE)
}

validate_geodesic_engine <- function(x) {
  if (isTRUE(sf::st_is_longlat(x)) && !isTRUE(sf::sf_use_s2())) {
    stop(
      paste0(
        "Area and length calculations on longitude/latitude geometries ",
        "require the s2 engine. Enable it with `sf::sf_use_s2(TRUE)` or ",
        "use a suitable projected PRIO-GRID configuration."
      ),
      call. = FALSE
    )
  }
  invisible(x)
}

geometry_area_m2 <- function(x) {
  validate_geodesic_engine(x)
  as.numeric(units::set_units(sf::st_area(x), "m^2"))
}

geometry_length_m <- function(x) {
  validate_geodesic_engine(x)
  as.numeric(units::set_units(sf::st_length(x), "m"))
}

empty_pg_data <- function(variable, temporal = FALSE, group_columns = NULL) {
  result <- data.frame(pgid = integer())
  if (temporal) {
    result$measurement_date <- as.Date(character())
  }
  for (column in group_columns) {
    result[[column]] <- character()
  }
  result[[variable]] <- numeric()
  result
}

summarise_point_groups <- function(
  x,
  variable,
  value = NULL,
  aggregation,
  group_columns
) {
  groups <- group_rows(x, group_columns)
  if (!length(groups)) {
    return(empty_pg_data(
      variable,
      temporal = "measurement_date" %in% group_columns,
      group_columns = setdiff(group_columns, c("pgid", "measurement_date"))
    ))
  }
  output <- lapply(groups, function(index) {
    row <- x[index[1L], group_columns, drop = FALSE]
    values <- if (is.null(value)) NULL else x[[value]][index]
    result <- switch(
      aggregation,
      count = length(index),
      presence = 1,
      sum = sum(values, na.rm = TRUE),
      mean = if (all(is.na(values))) NA_real_ else mean(values, na.rm = TRUE),
      min = if (all(is.na(values))) NA_real_ else min(values, na.rm = TRUE),
      max = if (all(is.na(values))) NA_real_ else max(values, na.rm = TRUE)
    )
    row[[variable]] <- result
    row
  })
  result <- do.call(rbind, output)
  rownames(result) <- NULL
  result
}

fill_empty_pg_cells <- function(data, variable, aggregation, config) {
  if (!aggregation %in% c("count", "presence", "sum")) {
    return(data)
  }
  pgids <- terra::values(pg_blank(config), mat = FALSE)
  pgids <- pgids[!is.na(pgids)]
  if (!"measurement_date" %in% names(data)) {
    full <- data.frame(pgid = pgids)
    result <- merge(full, data, by = "pgid", all.x = TRUE, sort = FALSE)
    result[[variable]][is.na(result[[variable]])] <- 0
    return(result)
  }
  dates <- sort(unique(data$measurement_date))
  if (!length(dates)) {
    return(data)
  }
  full <- expand.grid(
    pgid = pgids,
    measurement_date = dates,
    KEEP.OUT.ATTRS = FALSE
  )
  full$measurement_date <- as.Date(full$measurement_date, origin = "1970-01-01")
  result <- merge(
    full,
    data,
    by = c("pgid", "measurement_date"),
    all.x = TRUE,
    sort = FALSE
  )
  result[[variable]][is.na(result[[variable]])] <- 0
  result
}

pg_data_to_raster <- function(
  data,
  variable,
  config = priogrid::pg_current_config()
) {
  validate_columns(data, c("pgid", variable))
  template <- pg_blank(config)
  pgid_values <- terra::values(template, mat = FALSE)
  if (!"measurement_date" %in% names(data)) {
    values <- data[[variable]][match(pgid_values, data$pgid)]
    result <- terra::setValues(template, values)
    names(result) <- variable
    return(result)
  }
  dates <- sort(unique(as.Date(data$measurement_date)))
  if (!length(dates)) {
    stop("Cannot construct a time-varying raster from zero dates.", call. = FALSE)
  }
  layers <- lapply(dates, function(date) {
    rows <- data[as.Date(data$measurement_date) == date, , drop = FALSE]
    values <- rows[[variable]][match(pgid_values, rows$pgid)]
    layer <- terra::setValues(template, values)
    names(layer) <- format(date, "%Y-%m-%d")
    layer
  })
  do.call(c, layers)
}

finalize_pg_output <- function(
  data,
  raster,
  variable,
  source_type,
  aggregation,
  return,
  config,
  filename = NULL,
  overwrite = FALSE
) {
  if (return %in% c("raster", "result") && is.null(raster)) {
    raster <- pg_data_to_raster(data, variable, config)
  }
  result <- switch(
    return,
    data = data,
    raster = raster,
    result = new_pg_result(
      data = data,
      raster = raster,
      metadata = list(
        variable = variable,
        source_type = source_type,
        aggregation = aggregation,
        config = config
      )
    )
  )
  if (!is.null(filename)) {
    pg_write_result(result, filename, overwrite)
  }
  result
}

