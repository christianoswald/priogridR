#' Calculate rolling summaries within PRIO-GRID cells
#'
#' Calculates row-based windows after ordering observations by time within each
#' cell and optional additional groups. Missing periods are not inserted
#' automatically; complete the panel first when windows must represent fixed
#' calendar intervals.
#'
#' @param data A data frame containing a cell-time panel.
#' @param value Name of a numeric value column.
#' @param time Name of the temporal ordering column.
#' @param pgid Name of the PRIO-GRID cell-ID column.
#' @param window Positive integer window size.
#' @param fun Summary function: `"mean"`, `"sum"`, `"min"`, `"max"`,
#'   `"median"`, or `"sd"`.
#' @param align Window alignment: `"right"`, `"center"`, or `"left"`.
#' @param min_obs Minimum number of non-missing observations required.
#' @param na_rm Should missing values be removed before summarizing?
#' @param group Optional additional grouping-column names.
#' @param name Name of the appended summary column.
#' @param config A PRIO-GRID configuration object.
#' @return `data` in its original row order with the rolling summary appended.
#' @examples
#' config <- priogrid::pg_config(nrow = 2, ncol = 3)
#' x <- data.frame(pgid = 1, year = 2018:2022, events = 1:5)
#' pg_rolling_summary(
#'   x, "events", time = "year", window = 3, min_obs = 1,
#'   config = config
#' )
#' @export
pg_rolling_summary <- function(
  data,
  value,
  time = "measurement_date",
  pgid = "pgid",
  window = 3L,
  fun = c("mean", "sum", "min", "max", "median", "sd"),
  align = c("right", "center", "left"),
  min_obs = window,
  na_rm = FALSE,
  group = NULL,
  name = NULL,
  config = priogrid::pg_current_config()
) {
  fun <- match.arg(fun)
  align <- match.arg(align)
  window <- validate_periods(window, "window")
  if (is.null(name)) name <- paste0(value, "_rolling_", fun, "_", window)
  if (!is.numeric(min_obs) || length(min_obs) != 1L || is.na(min_obs) ||
      !is.finite(min_obs) || min_obs < 1 || min_obs %% 1 != 0 ||
      min_obs > window) {
    stop("`min_obs` must be a positive integer no larger than `window`.",
         call. = FALSE)
  }
  min_obs <- as.integer(min_obs)
  validate_flag(na_rm, "na_rm")
  panel <- validate_temporal_panel(
    data, value, pgid, time, group, numeric_value = TRUE, config = config
  )
  validate_new_column(data, name)
  output <- rep(NA_real_, nrow(data))
  values <- data[[value]]
  for (rows in panel$rows) {
    n <- length(rows)
    for (position in seq_len(n)) {
      bounds <- rolling_bounds(position, n, window, align)
      window_rows <- rows[bounds[1L]:bounds[2L]]
      window_values <- values[window_rows]
      if (sum(!is.na(window_values)) < min_obs) next
      output[rows[position]] <- apply_rolling_function(
        window_values, fun, na_rm
      )
    }
  }
  data[[name]] <- output
  data
}
