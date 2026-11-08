#' Calculate a spatial lag
#'
#' Adds a weighted sum of neighboring cell values to a cell-level or
#' cell-period data frame. The default is a row-standardized first-order queen
#' neighborhood, so the resulting lag is the neighboring-cell mean.
#'
#' @param data A data frame containing cell IDs and the variable to lag.
#' @param value Name of the numeric value column.
#' @param pgid Name of the PRIO-GRID cell-ID column.
#' @param time Optional character vector naming temporal grouping columns.
#' @param weights Optional table with `pgid`, `neighbor_pgid`, and `weight`.
#'   When omitted, weights are created from [pg_neighbor_table()].
#' @param method Contiguity method used when `weights` is omitted.
#' @param wrap_longitude Should default neighborhoods wrap across the
#'   antimeridian?
#' @param na_rm Should missing and unavailable neighbor values be omitted?
#' @param name Name of the new spatial-lag column.
#' @param config A PRIO-GRID configuration object.
#' @return `data` with the spatial-lag column appended.
#' @examples
#' config <- priogrid::pg_config(nrow = 18, ncol = 36)
#' x <- data.frame(pgid = 1:4, value = c(1, 2, 3, 4))
#' pg_spatial_lag(x, "value", config = config)
#' @export
pg_spatial_lag <- function(
  data,
  value,
  pgid = "pgid",
  time = NULL,
  weights = NULL,
  method = c("queen", "rook"),
  wrap_longitude = TRUE,
  na_rm = FALSE,
  name = paste0(value, "_spatial_lag"),
  config = priogrid::pg_current_config()
) {
  method <- match.arg(method)
  if (!is.data.frame(data)) stop("`data` must be a data frame.", call. = FALSE)
  validate_columns(data, c(pgid, value, time))
  validate_variable(value)
  validate_variable(name)
  validate_flag(wrap_longitude, "wrap_longitude")
  validate_flag(na_rm, "na_rm")
  if (!is.numeric(data[[value]])) {
    stop("`value` must identify a numeric column.", call. = FALSE)
  }
  ids <- validate_pgid_values(data[[pgid]], pgid, config)
  if (length(time) && anyNA(data[time])) {
    stop("`data` contains missing values in its temporal columns.", call. = FALSE)
  }
  keys <- data[c(pgid, time)]
  if (anyDuplicated(keys)) {
    stop("`data` contains duplicate cell-time keys.", call. = FALSE)
  }
  observed_ids <- sort(unique(ids))
  if (is.null(weights)) {
    neighbors <- pg_neighbor_table(
      observed_ids, candidates = observed_ids, method = method,
      wrap_longitude = wrap_longitude, config = config
    )
    weights <- pg_weights(neighbors)
  } else {
    if (!is.data.frame(weights)) stop("`weights` must be a data frame.", call. = FALSE)
    validate_columns(weights, c("pgid", "neighbor_pgid", "weight"))
    validate_pgid_values(weights$pgid, "weights$pgid", config)
    validate_pgid_values(weights$neighbor_pgid, "weights$neighbor_pgid", config)
    if (!is.numeric(weights$weight) || anyNA(weights$weight) ||
        any(!is.finite(weights$weight))) {
      stop("`weights$weight` must contain finite numeric values.", call. = FALSE)
    }
    if (anyDuplicated(weights[c("pgid", "neighbor_pgid")])) {
      stop("`weights` contains duplicate source-neighbor pairs.", call. = FALSE)
    }
  }
  output <- rep(NA_real_, nrow(data))
  groups <- split_panel_rows(data, time)
  for (rows in groups) {
    group_ids <- ids[rows]
    group_values <- data[[value]][rows]
    value_index <- match(weights$neighbor_pgid, group_ids)
    neighbor_values <- group_values[value_index]
    for (j in seq_along(rows)) {
      source <- group_ids[j]
      use <- which(weights$pgid == source)
      if (!length(use)) next
      values_j <- neighbor_values[use]
      weights_j <- weights$weight[use]
      if (!na_rm && anyNA(values_j)) next
      keep <- !is.na(values_j)
      if (any(keep)) output[rows[j]] <- sum(values_j[keep] * weights_j[keep])
    }
  }
  data[[name]] <- output
  data
}
