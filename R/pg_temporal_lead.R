#' Lead values within PRIO-GRID cells
#'
#' Adds a row-based lead after ordering observations by time within each cell
#' and optional additional groups. Missing periods are not inserted
#' automatically; use [pg_complete_panel()] first when calendar-complete leads
#' are required.
#'
#' @inheritParams pg_temporal_lag
#' @param value Name of the column to lead.
#' @param periods Positive integer number of rows to lead.
#' @param name Name of the appended lead column.
#' @return `data` in its original row order with the lead column appended.
#' @examples
#' config <- priogrid::pg_config(nrow = 2, ncol = 3)
#' x <- data.frame(
#'   pgid = rep(1:2, each = 3),
#'   year = rep(2020:2022, 2),
#'   events = 1:6
#' )
#' pg_temporal_lead(x, "events", time = "year", config = config)
#' @export
pg_temporal_lead <- function(
  data,
  value,
  time = "measurement_date",
  pgid = "pgid",
  periods = 1L,
  group = NULL,
  name = paste0(value, "_lead", periods),
  config = priogrid::pg_current_config()
) {
  periods <- validate_periods(periods)
  panel <- validate_temporal_panel(
    data, value, pgid, time, group, config = config
  )
  validate_new_column(data, name)
  data[[name]] <- temporal_shift_values(
    data[[value]], panel$rows, periods, "lead"
  )
  data
}
