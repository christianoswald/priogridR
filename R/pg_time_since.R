#' Calculate time since the most recent within-cell event
#'
#' Adds the number of rows or days since the latest event in each cell and
#' optional additional group. Event rows receive zero and observations before
#' the first event receive `NA`.
#'
#' @param data A data frame containing a cell-time panel.
#' @param event Name of a logical or binary numeric event column.
#' @param time Name of the temporal ordering column.
#' @param pgid Name of the PRIO-GRID cell-ID column.
#' @param units Measure elapsed time in `"periods"` or `"days"`.
#' @param group Optional additional grouping-column names.
#' @param name Name of the appended elapsed-time column.
#' @param config A PRIO-GRID configuration object.
#' @return `data` in its original row order with elapsed time appended.
#' @examples
#' config <- priogrid::pg_config(nrow = 2, ncol = 3)
#' x <- data.frame(
#'   pgid = 1,
#'   date = as.Date("2020-01-01") + c(0, 10, 20, 30),
#'   event = c(FALSE, TRUE, FALSE, FALSE)
#' )
#' pg_time_since(x, "event", time = "date", units = "days", config = config)
#' @export
pg_time_since <- function(
  data,
  event,
  time = "measurement_date",
  pgid = "pgid",
  units = c("periods", "days"),
  group = NULL,
  name = paste0(event, "_time_since"),
  config = priogrid::pg_current_config()
) {
  units <- match.arg(units)
  panel <- validate_temporal_panel(
    data, event, pgid, time, group, config = config
  )
  validate_new_column(data, name)
  events <- data[[event]]
  if (is.logical(events)) {
    if (anyNA(events)) {
      stop("`event` must not contain missing values.", call. = FALSE)
    }
  } else if (is.numeric(events)) {
    if (anyNA(events) || any(!events %in% c(0, 1))) {
      stop("A numeric `event` column must contain only zero and one.",
           call. = FALSE)
    }
    events <- as.logical(events)
  } else {
    stop("`event` must identify a logical or binary numeric column.",
         call. = FALSE)
  }
  if (units == "days" &&
      !inherits(data[[time]], c("Date", "POSIXt"))) {
    stop("`time` must be a Date or POSIXt column when `units = \"days\"`.",
         call. = FALSE)
  }
  output <- rep(NA_real_, nrow(data))
  for (rows in panel$rows) {
    last_event_position <- NA_integer_
    last_event_time <- NULL
    for (position in seq_along(rows)) {
      row <- rows[position]
      if (events[row]) {
        last_event_position <- position
        last_event_time <- data[[time]][row]
        output[row] <- 0
      } else if (!is.na(last_event_position)) {
        output[row] <- if (units == "periods") {
          position - last_event_position
        } else {
          as.numeric(difftime(
            data[[time]][row], last_event_time, units = "days"
          ))
        }
      }
    }
  }
  data[[name]] <- output
  data
}
