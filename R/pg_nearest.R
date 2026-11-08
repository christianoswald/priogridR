#' Find nearest PRIO-GRID cells
#'
#' Finds the nearest candidate cell centres for one or more source cells.
#'
#' @param from Source cell IDs.
#' @param candidates Candidate destination cell IDs.
#' @param n Number of nearest candidates to return per source cell.
#' @param include_self Should a source cell be eligible as its own nearest cell?
#' @param config A PRIO-GRID configuration object.
#' @return A data frame with source and nearest cell IDs, distance in
#'   kilometres, and rank.
#' @examples
#' config <- priogrid::pg_config(nrow = 18, ncol = 36)
#' pg_nearest(1:2, candidates = 1:6, n = 2, config = config)
#' @export
pg_nearest <- function(
  from,
  candidates,
  n = 1L,
  include_self = FALSE,
  config = priogrid::pg_current_config()
) {
  validate_pg_config(config)
  validate_flag(include_self, "include_self")
  from <- unique(validate_pgid_values(from, "from", config))
  candidates <- unique(validate_pgid_values(candidates, "candidates", config))
  if (length(n) != 1L || !is.numeric(n) || is.na(n) || n < 1 || n %% 1 != 0) {
    stop("`n` must be one positive integer.", call. = FALSE)
  }
  n <- as.integer(n)
  if (!length(from) || !length(candidates)) {
    return(data.frame(
      from_pgid = integer(), nearest_pgid = integer(),
      distance_km = numeric(), rank = integer()
    ))
  }
  check_distance_workload(length(from), length(candidates))
  distances <- pg_distance_matrix(from, candidates, config)
  rows <- vector("list", length(from))
  for (i in seq_along(from)) {
    indices <- seq_along(candidates)
    if (!include_self) indices <- indices[candidates != from[i]]
    indices <- indices[order(distances[i, indices], candidates[indices])]
    indices <- utils::head(indices, n)
    rows[[i]] <- data.frame(
      from_pgid = rep.int(from[i], length(indices)),
      nearest_pgid = candidates[indices],
      distance_km = distances[i, indices],
      rank = seq_along(indices)
    )
  }
  out <- do.call(rbind, rows)
  if (is.null(out)) {
    return(data.frame(
      from_pgid = integer(), nearest_pgid = integer(),
      distance_km = numeric(), rank = integer()
    ))
  }
  rownames(out) <- NULL
  out
}
