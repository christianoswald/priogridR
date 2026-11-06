#' Validate PRIO-GRID data
#'
#' Checks cell identifiers, missing keys, duplicate cell-time observations,
#' and optionally whether all configured cells and observed time periods are
#' represented.
#'
#' @param data A data frame containing PRIO-GRID data.
#' @param pg_id Name of the cell-ID column.
#' @param time Optional name of the temporal identifier column.
#' @param require_unique Should duplicate cell or cell-time keys make the data
#'   invalid?
#' @param require_complete Should missing cell or cell-time combinations make
#'   the data invalid?
#' @param config A PRIO-GRID configuration object.
#' @return A `pg_validation` object containing the overall result, counts, and
#'   a table of detected issues.
#' @examples
#' config <- priogrid::pg_config(nrow = 2, ncol = 3)
#' x <- data.frame(pgid = 1:6, value = runif(6))
#' pg_validate_data(x, config = config)
#' @export
pg_validate_data <- function(
  data,
  pg_id = "pgid",
  time = NULL,
  require_unique = TRUE,
  require_complete = FALSE,
  config = priogrid::pg_current_config()
) {
  if (!is.data.frame(data)) {
    stop("`data` must be a data frame.", call. = FALSE)
  }
  validate_columns(data, c(pg_id, time))
  for (argument in c("require_unique", "require_complete")) {
    value <- get(argument)
    if (!is.logical(value) || length(value) != 1L || is.na(value)) {
      stop("`", argument, "` must be TRUE or FALSE.", call. = FALSE)
    }
  }
  lookup <- pg_cell_lookup(config)
  ids <- data[[pg_id]]
  id_numeric <- is.numeric(ids)
  missing_id <- sum(is.na(ids))
  invalid_id <- if (id_numeric) {
    sum(!is.na(ids) & (ids %% 1 != 0 | !ids %in% lookup$pgid))
  } else {
    sum(!is.na(ids))
  }
  missing_time <- if (is.null(time)) 0L else sum(is.na(data[[time]]))
  keys <- c(pg_id, time)
  complete_keys <- stats::complete.cases(data[keys])
  duplicate_rows <- 0L
  if (any(complete_keys)) {
    key_data <- data[complete_keys, keys, drop = FALSE]
    duplicate_rows <- sum(
      duplicated(key_data) | duplicated(key_data, fromLast = TRUE)
    )
  }
  valid_ids <- if (id_numeric) {
    !is.na(ids) & ids %% 1 == 0 & ids %in% lookup$pgid
  } else {
    rep.int(FALSE, length(ids))
  }
  observed <- data[valid_ids & complete_keys, keys, drop = FALSE]
  observed <- unique(observed)
  if (is.null(time)) {
    expected <- length(lookup$pgid)
  } else {
    periods <- unique(data[[time]][!is.na(data[[time]])])
    expected <- length(lookup$pgid) * length(periods)
  }
  missing_combinations <- max(0L, expected - nrow(observed))
  issues <- data.frame(
    check = c("missing_id", "invalid_id", "missing_time",
              "duplicate_keys", "missing_combinations"),
    severity = c("error", "error", "error",
                 if (require_unique) "error" else "warning",
                 if (require_complete) "error" else "information"),
    n = as.integer(c(missing_id, invalid_id, missing_time,
                     duplicate_rows, missing_combinations)),
    stringsAsFactors = FALSE
  )
  issues <- issues[issues$n > 0L, , drop = FALSE]
  valid <- !any(issues$severity == "error")
  structure(
    list(
      valid = valid,
      n_rows = nrow(data),
      n_cells = length(unique(ids[valid_ids])),
      expected_combinations = expected,
      issues = issues,
      keys = keys
    ),
    class = "pg_validation"
  )
}

#' @rdname pg_validate_data
#' @param x A `pg_validation` object.
#' @param ... Additional arguments, currently unused.
#' @export
print.pg_validation <- function(x, ...) {
  cat("PRIO-GRID validation: ", if (isTRUE(x$valid)) "valid" else "invalid",
      "\n", sep = "")
  cat("Rows: ", x$n_rows, "; observed cells: ", x$n_cells, "\n", sep = "")
  if (!nrow(x$issues)) {
    cat("No issues detected.\n")
  } else {
    print(x$issues, row.names = FALSE)
  }
  invisible(x)
}
