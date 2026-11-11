#' Calculate within-cell temporal change
#'
#' Compares each observation with an earlier row from the same cell and
#' optional additional group. Percentage changes use the earlier value as the
#' denominator and return `NA` when it is zero. Log differences require both
#' values to be strictly positive.
#'
#' @param data A data frame containing a cell-time panel.
#' @param value Name of a numeric value column.
#' @param time Name of the temporal ordering column.
#' @param pgid Name of the PRIO-GRID cell-ID column.
#' @param periods Positive integer comparison lag.
#' @param type One of `"difference"`, `"percent"`, or `"log"`.
#' @param group Optional additional grouping-column names.
#' @param name Name of the appended change column.
#' @param config A PRIO-GRID configuration object.
#' @return `data` in its original row order with the change column appended.
#' @examples
#' config <- priogrid::pg_config(nrow = 2, ncol = 3)
#' x <- data.frame(pgid = 1, year = 2020:2022, value = c(10, 15, 12))
#' pg_temporal_change(x, "value", time = "year", config = config)
#' @export
pg_temporal_change <- function(
  data,
  value,
  time = "measurement_date",
  pgid = "pgid",
  periods = 1L,
  type = c("difference", "percent", "log"),
  group = NULL,
  name = NULL,
  config = priogrid::pg_current_config()
) {
  type <- match.arg(type)
  if (is.null(name)) name <- paste0(value, "_", type)
  periods <- validate_periods(periods)
  panel <- validate_temporal_panel(
    data, value, pgid, time, group, numeric_value = TRUE, config = config
  )
  validate_new_column(data, name)
  current <- data[[value]]
  previous <- temporal_shift_values(current, panel$rows, periods, "lag")
  output <- switch(
    type,
    difference = current - previous,
    percent = {
      result <- 100 * (current - previous) / previous
      result[!is.na(previous) & previous == 0] <- NA_real_
      result
    },
    log = {
      valid <- !is.na(current) & !is.na(previous) &
        current > 0 & previous > 0
      result <- rep(NA_real_, length(current))
      result[valid] <- log(current[valid]) - log(previous[valid])
      result
    }
  )
  data[[name]] <- output
  data
}
