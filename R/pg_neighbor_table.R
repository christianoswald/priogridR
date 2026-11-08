#' Build a PRIO-GRID neighbor table
#'
#' Creates a reusable directed table of neighboring PRIO-GRID cells using
#' queen or rook contiguity, a distance band, or k-nearest neighbors.
#'
#' @param pgid Source cell IDs. `NULL` uses all configured cells.
#' @param candidates Candidate neighbor cell IDs. `NULL` uses all configured
#'   cells.
#' @param method Neighborhood definition: queen contiguity, rook contiguity,
#'   a distance band, or k-nearest neighbors.
#' @param distance Maximum great-circle distance in kilometres. Required for
#'   `method = "distance"`.
#' @param k Number of neighbors for `method = "knn"`.
#' @param include_self Should a cell be allowed to neighbor itself?
#' @param wrap_longitude Should contiguity wrap across the antimeridian?
#' @param config A PRIO-GRID configuration object.
#' @return A data frame with `pgid` and `neighbor_pgid`. Distance and k-nearest
#'   tables also contain `distance_km`.
#' @examples
#' config <- priogrid::pg_config(nrow = 18, ncol = 36)
#' pg_neighbor_table(20, method = "rook", config = config)
#' pg_neighbor_table(1:3, candidates = 1:6, method = "knn", k = 2,
#'                   config = config)
#' @export
pg_neighbor_table <- function(
  pgid = NULL,
  candidates = NULL,
  method = c("queen", "rook", "distance", "knn"),
  distance = NULL,
  k = 1L,
  include_self = FALSE,
  wrap_longitude = TRUE,
  config = priogrid::pg_current_config()
) {
  method <- match.arg(method)
  validate_pg_config(config)
  validate_flag(include_self, "include_self")
  validate_flag(wrap_longitude, "wrap_longitude")
  lookup <- pg_cell_lookup(config)
  if (is.null(pgid)) pgid <- lookup$pgid
  if (is.null(candidates)) candidates <- lookup$pgid
  pgid <- unique(validate_pgid_values(pgid, "pgid", config))
  candidates <- unique(validate_pgid_values(candidates, "candidates", config))
  if (!length(pgid) || !length(candidates)) {
    return(empty_neighbor_table(method %in% c("distance", "knn")))
  }

  if (method %in% c("queen", "rook")) {
    blank <- pg_blank(config)
    nr <- terra::nrow(blank)
    nc <- terra::ncol(blank)
    source_cells <- lookup$cell[match(pgid, lookup$pgid)]
    candidate_lookup <- stats::setNames(lookup$pgid, lookup$cell)
    if (identical(method, "queen")) {
      offsets <- expand.grid(row = -1L:1L, col = -1L:1L)
      offsets <- offsets[offsets$row != 0L | offsets$col != 0L, ]
    } else {
      offsets <- data.frame(
        row = c(-1L, 0L, 0L, 1L), col = c(0L, -1L, 1L, 0L)
      )
    }
    n_offsets <- nrow(offsets)
    source_row <- ((source_cells - 1L) %/% nc) + 1L
    source_col <- ((source_cells - 1L) %% nc) + 1L
    source_id <- rep(pgid, each = n_offsets)
    neighbor_row <- rep(source_row, each = n_offsets) +
      rep(offsets$row, times = length(source_cells))
    neighbor_col <- rep(source_col, each = n_offsets) +
      rep(offsets$col, times = length(source_cells))
    keep <- neighbor_row >= 1L & neighbor_row <= nr
    if (wrap_longitude) {
      neighbor_col <- ((neighbor_col - 1L) %% nc) + 1L
    } else {
      keep <- keep & neighbor_col >= 1L & neighbor_col <= nc
    }
    cells <- (neighbor_row - 1L) * nc + neighbor_col
    neighbor_id <- as.integer(unname(candidate_lookup[as.character(cells)]))
    keep <- keep & !is.na(neighbor_id) & neighbor_id %in% candidates
    out <- data.frame(
      pgid = source_id[keep], neighbor_pgid = neighbor_id[keep]
    )
    if (include_self) {
      self <- pgid[pgid %in% candidates]
      out <- rbind(
        out,
        data.frame(pgid = self, neighbor_pgid = self)
      )
    }
    out <- unique(out)
    out <- out[order(match(out$pgid, pgid), out$neighbor_pgid), , drop = FALSE]
    rownames(out) <- NULL
    return(out)
  }

  if (identical(method, "distance")) {
    if (is.null(distance)) {
      stop("`distance` is required when `method = \"distance\"`.", call. = FALSE)
    }
    validate_positive_number(distance, "distance", allow_zero = TRUE)
  } else {
    if (length(k) != 1L || !is.numeric(k) || is.na(k) || k < 1 || k %% 1 != 0) {
      stop("`k` must be one positive integer.", call. = FALSE)
    }
    k <- as.integer(k)
  }
  check_distance_workload(length(pgid), length(candidates))
  distances <- pg_distance_matrix(pgid, candidates, config)
  rows <- vector("list", length(pgid))
  for (i in seq_along(pgid)) {
    keep <- rep(TRUE, length(candidates))
    if (!include_self) keep <- candidates != pgid[i]
    indices <- which(keep)
    if (identical(method, "distance")) {
      indices <- indices[distances[i, indices] <= distance]
    } else if (length(indices)) {
      order_i <- order(distances[i, indices], candidates[indices])
      indices <- indices[utils::head(order_i, k)]
    }
    rows[[i]] <- data.frame(
      pgid = rep.int(pgid[i], length(indices)),
      neighbor_pgid = candidates[indices],
      distance_km = distances[i, indices]
    )
  }
  out <- do.call(rbind, rows)
  if (is.null(out)) return(empty_neighbor_table(TRUE))
  rownames(out) <- NULL
  out
}
