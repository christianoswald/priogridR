#' Convert coordinates to PRIO-GRID cell IDs
#'
#' Assigns coordinates to cells in a configured PRIO-GRID. Coordinates are
#' transformed to the grid projection before cell lookup.
#'
#' @param longitude,latitude Numeric coordinate vectors. Vectors must have
#'   equal lengths, or one may have length one.
#' @param crs Coordinate reference system of the supplied coordinates. Any
#'   value accepted by [sf::st_crs()] may be used.
#' @param outside How coordinates outside the configured grid should be
#'   handled: return `NA` or raise an error.
#' @param config A PRIO-GRID configuration object.
#' @return An integer vector of PRIO-GRID cell IDs.
#' @examples
#' config <- priogrid::pg_config(nrow = 18, ncol = 36)
#' pg_id_from_coords(0, 0, config = config)
#' @export
pg_id_from_coords <- function(
  longitude,
  latitude,
  crs = 4326,
  outside = c("NA", "error"),
  config = priogrid::pg_current_config()
) {
  outside <- match.arg(outside)
  coordinates <- recycle_coordinate_pair(longitude, latitude)
  longitude <- coordinates$x
  latitude <- coordinates$y
  if (!is.numeric(longitude) || !is.numeric(latitude)) {
    stop("`longitude` and `latitude` must be numeric.", call. = FALSE)
  }
  invalid <- is.na(longitude) | is.na(latitude) |
    !is.finite(longitude) | !is.finite(latitude)
  blank <- pg_blank(config)
  result <- rep.int(NA_integer_, length(longitude))
  usable <- which(!invalid)
  if (length(usable)) {
    points <- sf::st_as_sf(
      data.frame(x = longitude[usable], y = latitude[usable]),
      coords = c("x", "y"), crs = crs
    )
    grid_crs <- sf::st_crs(terra::crs(blank, proj = TRUE))
    if (is.na(grid_crs)) {
      stop("The configured PRIO-GRID has no coordinate reference system.",
           call. = FALSE)
    }
    points <- sf::st_transform(points, grid_crs)
    cells <- terra::cellFromXY(blank, sf::st_coordinates(points))
    lookup <- pg_cell_lookup(config)
    result[usable] <- lookup$pgid[match(cells, lookup$cell)]
  }
  outside_rows <- which(is.na(result))
  if (length(outside_rows) && identical(outside, "error")) {
    stop(
      "Coordinates outside the configured grid or otherwise invalid at positions: ",
      paste(outside_rows, collapse = ", "), ".", call. = FALSE
    )
  }
  result
}
