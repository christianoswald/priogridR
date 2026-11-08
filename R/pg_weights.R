#' Create spatial weights
#'
#' Adds binary or inverse-distance weights to a neighbor table, with optional
#' row standardization.
#'
#' @param neighbors A neighbor table produced by [pg_neighbor_table()].
#' @param type Use binary or inverse-distance weights.
#' @param row_standardize Should weights sum to one within each source cell?
#' @param power Positive distance-decay exponent for inverse-distance weights.
#' @return The neighbor table with an added `weight` column.
#' @examples
#' neighbors <- data.frame(
#'   pgid = c(1L, 1L, 2L),
#'   neighbor_pgid = c(2L, 3L, 1L),
#'   distance_km = c(10, 20, 10)
#' )
#' pg_weights(neighbors)
#' pg_weights(neighbors, type = "inverse_distance")
#' @export
pg_weights <- function(
  neighbors,
  type = c("binary", "inverse_distance"),
  row_standardize = TRUE,
  power = 1
) {
  type <- match.arg(type)
  if (!is.data.frame(neighbors)) {
    stop("`neighbors` must be a data frame.", call. = FALSE)
  }
  validate_columns(neighbors, c("pgid", "neighbor_pgid"))
  validate_flag(row_standardize, "row_standardize")
  validate_positive_number(power, "power")
  out <- neighbors
  if (identical(type, "binary")) {
    out$weight <- rep(1, nrow(out))
  } else {
    validate_columns(out, "distance_km")
    if (anyNA(out$distance_km) || any(!is.finite(out$distance_km)) ||
        any(out$distance_km <= 0)) {
      stop("Inverse-distance weights require finite, positive `distance_km` values.",
           call. = FALSE)
    }
    out$weight <- 1 / (out$distance_km ^ power)
  }
  if (row_standardize && nrow(out)) {
    totals <- stats::ave(out$weight, out$pgid, FUN = sum)
    out$weight <- out$weight / totals
  }
  out
}
