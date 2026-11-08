#' Calculate distances between PRIO-GRID cells
#'
#' Calculates great-circle distances between cell centres.
#'
#' @param from Source cell IDs.
#' @param to Destination cell IDs.
#' @param pairwise If `TRUE`, calculate element-wise distances with safe scalar
#'   recycling. If `FALSE`, calculate every source-destination combination.
#' @param config A PRIO-GRID configuration object.
#' @return A data frame with source and destination IDs and `distance_km`.
#' @examples
#' config <- priogrid::pg_config(nrow = 18, ncol = 36)
#' pg_distance(1:2, 2:3, config = config)
#' pg_distance(1:2, 1:3, pairwise = FALSE, config = config)
#' @export
pg_distance <- function(
  from,
  to,
  pairwise = TRUE,
  config = priogrid::pg_current_config()
) {
  validate_pg_config(config)
  validate_flag(pairwise, "pairwise")
  from <- validate_pgid_values(from, "from", config)
  to <- validate_pgid_values(to, "to", config)
  if (!length(from) || !length(to)) {
    return(data.frame(
      from_pgid = integer(), to_pgid = integer(), distance_km = numeric()
    ))
  }
  if (pairwise) {
    recycled <- recycle_coordinate_pair(from, to)
    from <- as.integer(recycled$x)
    to <- as.integer(recycled$y)
    distance_km <- pg_pairwise_distances(from, to, config)
  } else {
    from <- unique(from)
    to <- unique(to)
    check_distance_workload(length(from), length(to))
    all_distances <- pg_distance_matrix(from, to, config)
    distance_km <- as.vector(t(all_distances))
    to <- rep(to, times = length(from))
    from <- rep(from, each = ncol(all_distances))
  }
  data.frame(from_pgid = from, to_pgid = to, distance_km = distance_km)
}
