#' Calculate PRIO-GRID coverage
#'
#' Distinguishes structurally absent keys from present rows containing missing
#' measurements relative to an explicit grid and temporal reference.
#'
#' @param x A data frame or `pg_result` with a tabular component.
#' @param id Cell identifier column.
#' @param time Optional temporal column.
#' @param variables Measurement columns used to count observed missing values.
#' @param config PRIO-GRID configuration defining reference cells.
#' @param reference_ids Optional explicit reference cell identifiers.
#' @param reference_time Optional explicit reference periods.
#' @param by Summary dimension.
#' @return A data frame with expected, present, structurally absent, outside,
#'   and observed-missing counts.
#' @examples
#' config <- priogrid::pg_config(nrow = 2, ncol = 3, verbose = FALSE)
#' x <- data.frame(pgid = c(1, 3), value = c(1, NA))
#' pg_coverage(x, config = config)
#' @export
pg_coverage <- function(x, id = "pgid", time = NULL, variables = NULL,
                        config = priogrid::pg_current_config(),
                        reference_ids = NULL, reference_time = NULL,
                        by = c("overall", "cell", "time", "variable")) {
  by <- match.arg(by)
  data <- pg_data_component(x)
  validate_columns(data, c(id, time))
  variables <- pg_selected_variables(data, variables, id, time)
  if (is.null(reference_ids)) {
    if (is.null(config)) stop("Supply `config` or `reference_ids`.", call. = FALSE)
    reference_ids <- pg_cell_lookup(config)$pgid
  }
  if (anyNA(reference_ids) || anyDuplicated(reference_ids)) {
    stop("`reference_ids` must contain unique, non-missing values.", call. = FALSE)
  }
  if (!is.null(time)) {
    if (is.null(reference_time)) reference_time <- sort(unique(data[[time]][!is.na(data[[time]])]))
    if (anyNA(reference_time) || anyDuplicated(reference_time)) {
      stop("`reference_time` must contain unique, non-missing values.", call. = FALSE)
    }
  } else if (!is.null(reference_time)) {
    stop("`reference_time` requires a `time` column.", call. = FALSE)
  }
  keys <- c(id, time)
  complete <- stats::complete.cases(data[keys])
  if (anyDuplicated(data[complete, keys, drop = FALSE])) {
    stop("`x` contains duplicate reference keys; summarize or resolve them first.",
         call. = FALSE)
  }
  present_data <- unique(data[complete, keys, drop = FALSE])
  in_reference <- present_data[[id]] %in% reference_ids
  if (!is.null(time)) in_reference <- in_reference & present_data[[time]] %in% reference_time
  outside <- sum(!in_reference)
  present_data <- present_data[in_reference, , drop = FALSE]
  periods <- if (is.null(time)) 1L else length(reference_time)
  expected_total <- length(reference_ids) * periods

  make_row <- function(expected, present, outside_reference = 0L, subset = data) {
    missing <- if (length(variables) && nrow(subset)) sum(vapply(subset[variables], function(z) sum(is.na(z)), integer(1))) else 0L
    data.frame(
      n_expected = as.integer(expected), n_present = as.integer(present),
      n_structurally_absent = as.integer(max(0, expected - present)),
      n_outside_reference = as.integer(outside_reference),
      n_observed_missing = as.integer(missing),
      coverage_share = if (expected) present / expected else NA_real_
    )
  }
  if (by == "overall") return(make_row(expected_total, nrow(present_data), outside, data[complete, , drop = FALSE]))
  if (by == "variable") {
    return(do.call(rbind, lapply(variables, function(variable) {
      row <- make_row(expected_total, nrow(present_data), outside, data[complete, variable, drop = FALSE])
      row$variable <- variable
      row[c("variable", setdiff(names(row), "variable"))]
    })))
  }
  reference <- if (by == "cell") reference_ids else reference_time
  column <- if (by == "cell") id else {
    if (is.null(time)) stop("`time` is required for `by = \"time\"`.", call. = FALSE)
    time
  }
  expected_each <- if (by == "cell") periods else length(reference_ids)
  out <- lapply(reference, function(value) {
    key_subset <- present_data[present_data[[column]] == value, , drop = FALSE]
    data_subset <- data[complete & data[[column]] == value, , drop = FALSE]
    row <- make_row(expected_each, nrow(key_subset), 0L, data_subset)
    row[[column]] <- value
    row[c(column, setdiff(names(row), column))]
  })
  do.call(rbind, out)
}

