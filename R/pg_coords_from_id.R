#' Convert PRIO-GRID cell IDs to centre coordinates
#'
#' Returns the centre coordinates of cells in a configured PRIO-GRID.
#'
#' @param pgid Numeric vector of PRIO-GRID cell IDs.
#' @param crs Coordinate reference system for the returned coordinates. Any
#'   value accepted by [sf::st_crs()] may be used.
#' @param invalid How unknown or missing IDs should be handled: raise an error
#'   or return missing coordinates.
#' @param config A PRIO-GRID configuration object.
#' @return A data frame with `pgid`, `xcoord`, and `ycoord`.
#' @examples
#' config <- priogrid::pg_config(nrow = 18, ncol = 36)
#' pg_coords_from_id(1:3, config = config)
#' @export
pg_coords_from_id <- function(
  pgid,
  crs = 4326,
  invalid = c("error", "NA"),
  config = priogrid::pg_current_config()
) {
  invalid <- match.arg(invalid)
  validate_pg_id_column(pgid)
  lookup <- pg_cell_lookup(config)
  positions <- match(pgid, lookup$pgid)
  bad <- which(is.na(positions) | is.na(pgid) | pgid %% 1 != 0)
  if (length(bad) && identical(invalid, "error")) {
    stop("Unknown or invalid PRIO-GRID IDs at positions: ",
         paste(bad, collapse = ", "), ".", call. = FALSE)
  }
  blank <- pg_blank(config)
  output <- data.frame(
    pgid = as.integer(pgid),
    xcoord = NA_real_,
    ycoord = NA_real_
  )
  good <- which(!is.na(positions) & !is.na(pgid) & pgid %% 1 == 0)
  if (length(good)) {
    xy <- terra::xyFromCell(blank, lookup$cell[positions[good]])
    points <- sf::st_as_sf(
      data.frame(row = good, x = xy[, 1L], y = xy[, 2L]),
      coords = c("x", "y"), crs = terra::crs(blank, proj = TRUE)
    )
    points <- sf::st_transform(points, sf::st_crs(crs))
    xy <- sf::st_coordinates(points)
    output$xcoord[good] <- xy[, 1L]
    output$ycoord[good] <- xy[, 2L]
  }
  output
}
