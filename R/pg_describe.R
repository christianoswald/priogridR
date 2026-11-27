#' Describe a PRIO-GRID dataset
#'
#' Produces a compact structural summary without constructing a complete panel.
#'
#' @param x A data frame or `pg_result` with a tabular component.
#' @param id Cell identifier column.
#' @param time Optional temporal column.
#' @param variables Variables for missingness summaries.
#' @param config Optional PRIO-GRID configuration.
#' @return A `pg_description` object containing overview, missingness, validation,
#'   and metadata components.
#' @examples
#' x <- data.frame(pgid = c(1, 2, 2), year = c(2020, 2020, 2021), value = c(1, NA, 3))
#' pg_describe(x, time = "year", config = priogrid::pg_config(nrow = 2, ncol = 3, verbose = FALSE))
#' @export
pg_describe <- function(x, id = "pgid", time = NULL, variables = NULL,
                        config = NULL) {
  data <- pg_data_component(x)
  validate_columns(data, c(id, time))
  variables <- pg_selected_variables(data, variables, id, time)
  keys <- c(id, time)
  complete <- stats::complete.cases(data[keys])
  duplicates <- if (any(complete)) sum(duplicated(data[complete, keys, drop = FALSE])) else 0L
  cells <- unique(data[[id]][!is.na(data[[id]])])
  periods <- if (is.null(time)) NULL else sort(unique(data[[time]][!is.na(data[[time]])]))
  possible <- if (is.null(time)) length(cells) else length(cells) * length(periods)
  observed <- nrow(unique(data[complete, keys, drop = FALSE]))
  overview <- list(
    n_rows = nrow(data), n_columns = ncol(data), n_cells = length(cells),
    n_periods = if (is.null(time)) 0L else length(periods),
    n_variables = length(variables), duplicate_keys = duplicates,
    observed_keys = observed, possible_observed_domain_keys = possible,
    balanced_observed_domain = observed == possible && duplicates == 0L
  )
  validation <- if (is.null(config)) NULL else pg_validate_data(
    data, pg_id = id, time = time, require_unique = TRUE,
    require_complete = FALSE, config = config
  )
  structure(list(
    overview = overview,
    time = pg_time_metadata(data, time),
    missingness = if (length(variables)) pg_missingness(data, variables, id, time) else data.frame(),
    validation = validation,
    metadata = pg_metadata(x, config = config, id = id, time = time)
  ), class = "pg_description")
}

#' @rdname pg_describe
#' @param ... Additional arguments, currently unused.
#' @export
print.pg_description <- function(x, ...) {
  o <- x$overview
  cat("<pg_description>\n")
  cat("  Rows: ", o$n_rows, "; cells: ", o$n_cells, sep = "")
  if (o$n_periods) cat("; periods: ", o$n_periods, sep = "")
  cat("\n  Variables: ", o$n_variables, "; duplicate keys: ", o$duplicate_keys, "\n", sep = "")
  cat("  Balanced over observed domain: ", if (o$balanced_observed_domain) "yes" else "no", "\n", sep = "")
  invisible(x)
}

