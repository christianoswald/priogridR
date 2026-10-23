normalize_pg_time <- function(
  time,
  n,
  config = priogrid::pg_current_config()
) {
  if (is.null(time)) {
    return(NULL)
  }
  if (length(time) != n) {
    stop("`time` must contain one value per raster layer.", call. = FALSE)
  }
  if (inherits(time, "Date")) {
    return(time)
  }
  if (inherits(time, "POSIXt")) {
    return(as.Date(time))
  }
  if (is.numeric(time) || is.integer(time)) {
    years <- as.integer(time)
    month_day <- format(config$start_date, "%m-%d")
    result <- as.Date(sprintf("%04d-%s", years, month_day))
    if (anyNA(result)) {
      stop("Could not convert numeric `time` values to dates.", call. = FALSE)
    }
    return(result)
  }
  result <- as.Date(time)
  if (anyNA(result)) {
    stop("`time` must contain Dates, date-like strings, or years.", call. = FALSE)
  }
  result
}

map_dates_to_pg_intervals <- function(
  x,
  config = priogrid::pg_current_config()
) {
  x <- as.Date(x)
  if (anyNA(x)) {
    stop("The time column contains values that cannot be converted to Date.", call. = FALSE)
  }
  intervals <- priogrid::pg_date_intervals(config = config)
  starts <- as.Date(lubridate::int_start(intervals))
  ends <- as.Date(lubridate::int_end(intervals))
  index <- findInterval(as.numeric(x), as.numeric(starts))
  result <- as.Date(rep(NA_real_, length(x)), origin = "1970-01-01")
  inside <- index > 0L
  inside[inside] <- x[inside] <= ends[index[inside]]
  result[inside] <- ends[index[inside]]
  result
}

add_measurement_date <- function(
  x,
  time = NULL,
  time_column = NULL,
  config = priogrid::pg_current_config()
) {
  if (!is.null(time) && !is.null(time_column)) {
    stop("Supply only one of `time` and `time_column`.", call. = FALSE)
  }
  if (!is.null(time_column)) {
    validate_columns(x, time_column)
    x$measurement_date <- map_dates_to_pg_intervals(x[[time_column]], config)
    return(x)
  }
  if (!is.null(time)) {
    if (length(time) != 1L) {
      stop("For vector data, `time` must be a single date or year.", call. = FALSE)
    }
    date <- normalize_pg_time(time, 1L, config)
    x$measurement_date <- map_dates_to_pg_intervals(date, config)[1L]
  }
  x
}

