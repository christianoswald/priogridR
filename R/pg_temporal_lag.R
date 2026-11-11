#' Lag values within PRIO-GRID cells
#'
#' Adds a row-based lag after ordering observations by time within each cell
#' and optional additional groups. Missing periods are not inserted
#' automatically; use [pg_complete_panel()] first when calendar-complete lags
#' are required.
#'
#' @param data A data frame containing a cell-time panel.
#' @param value Name of the column to lag.
#' @param time Name of the temporal ordering column.
#' @param pgid Name of the PRIO-GRID cell-ID column.
#' @param periods Positive integer number of rows to lag.
#' @param group Optional additional grouping-column names.
#' @param name Name of the appended lag column.
#' @param config A PRIO-GRID configuration object.
#' @return `data` in its original row order with the lag column appended.
#' @examples
#' config <- priogrid::pg_config(nrow = 2, ncol = 3)
#' x <- data.frame(
#'   pgid = rep(1:2, each = 3),
#'   year = rep(2020:2022, 2),
#'   events = 1:6
#' )
#' pg_temporal_lag(x, "events", time = "year", config = config)
#' @export
pg_temporal_lag <- function(
  data,
  value,
  time = "measurement_date",
  pgid = "pgid",
  periods = 1L,
  group = NULL,
  name = paste0(value, "_lag", periods),
  config = priogrid::pg_current_config()
) {
  periods <- validate_periods(periods)
  panel <- validate_temporal_panel(
    data, value, pgid, time, group, config = config
  )
  validate_new_column(data, name)
  data[[name]] <- temporal_shift_values(
    data[[value]], panel$rows, periods, "lag"
  )
  data
}
