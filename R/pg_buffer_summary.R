#' Summarize values around PRIO-GRID cells
#'
#' Adds a summary of values observed in cells whose centres fall within a
#' specified radius of each focal cell. Temporal columns can be supplied to
#' prevent values from different periods being combined.
#'
#' @param data A data frame containing one observation per cell or cell-period.
#' @param value Name of the numeric value column.
#' @param radius Buffer radius in kilometres.
#' @param statistic Summary to calculate.
#' @param pgid Name of the cell-ID column.
#' @param time Optional character vector naming temporal grouping columns.
#' @param include_self Should the focal cell be included in its own buffer?
#' @param na_rm Should missing values be omitted?
#' @param name Name of the new summary column.
#' @param config A PRIO-GRID configuration object.
#' @return `data` with the buffer-summary column appended.
#' @examples
#' config <- priogrid::pg_config(nrow = 18, ncol = 36)
#' x <- data.frame(pgid = 1:4, events = c(1, 0, 2, 1))
#' pg_buffer_summary(x, "events", radius = 1500, statistic = "sum",
#'                   config = config)
#' @export
pg_buffer_summary <- function(
  data,
  value,
  radius,
  statistic = c("sum", "mean", "count", "min", "max"),
  pgid = "pgid",
  time = NULL,
  include_self = TRUE,
  na_rm = TRUE,
  name = paste0(value, "_buffer_", statistic[1L]),
  config = priogrid::pg_current_config()
) {
  statistic <- match.arg(statistic)
  if (!is.data.frame(data)) stop("`data` must be a data frame.", call. = FALSE)
  validate_columns(data, c(pgid, value, time))
  validate_variable(value)
  validate_variable(name)
  validate_positive_number(radius, "radius", allow_zero = TRUE)
  validate_flag(include_self, "include_self")
  validate_flag(na_rm, "na_rm")
  if (!is.numeric(data[[value]])) {
    stop("`value` must identify a numeric column.", call. = FALSE)
  }
  ids <- validate_pgid_values(data[[pgid]], pgid, config)
  if (length(time) && anyNA(data[time])) {
    stop("`data` contains missing values in its temporal columns.", call. = FALSE)
  }
  if (anyDuplicated(data[c(pgid, time)])) {
    stop("`data` contains duplicate cell-time keys.", call. = FALSE)
  }
  cells <- sort(unique(ids))
  neighborhoods <- pg_neighbor_table(
    cells, candidates = cells, method = "distance", distance = radius,
    include_self = include_self, config = config
  )
  output <- rep(NA_real_, nrow(data))
  groups <- split_panel_rows(data, time)
  for (rows in groups) {
    group_ids <- ids[rows]
    group_values <- data[[value]][rows]
    for (j in seq_along(rows)) {
      targets <- neighborhoods$neighbor_pgid[neighborhoods$pgid == group_ids[j]]
      values_j <- group_values[match(targets, group_ids)]
      output[rows[j]] <- summarise_buffer_values(values_j, statistic, na_rm)
    }
  }
  data[[name]] <- output
  data
}
