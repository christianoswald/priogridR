#' Create PRIO-GRID geometries
#'
#' Creates polygon or centre-point geometries for all or selected cells in a
#' configured PRIO-GRID.
#'
#' @param pgid Optional vector of cell IDs. If `NULL`, all configured cells are
#'   returned.
#' @param geometry Return cell `"polygon"` geometries or centre `"point"`
#'   geometries.
#' @param crs Optional output coordinate reference system. By default the grid
#'   CRS is retained.
#' @param config A PRIO-GRID configuration object.
#' @return An `sf` object with one row per requested cell.
#' @examples
#' config <- priogrid::pg_config(nrow = 18, ncol = 36)
#' pg_geometry(1:3, geometry = "point", config = config)
#' @export
pg_geometry <- function(
  pgid = NULL,
  geometry = c("polygon", "point"),
  crs = NULL,
  config = priogrid::pg_current_config()
) {
  geometry <- match.arg(geometry)
  lookup <- pg_cell_lookup(config)
  if (is.null(pgid)) {
    pgid <- lookup$pgid
  } else {
    validate_pg_id_column(pgid)
    if (anyNA(pgid) || any(pgid %% 1 != 0) || any(!pgid %in% lookup$pgid)) {
      stop("`pgid` contains unknown or invalid PRIO-GRID cell IDs.",
           call. = FALSE)
    }
    if (anyDuplicated(pgid)) {
      stop("`pgid` must not contain duplicate cell IDs.", call. = FALSE)
    }
    pgid <- as.integer(pgid)
  }
  blank <- pg_blank(config)
  cells <- lookup$cell[match(pgid, lookup$pgid)]
  if (identical(geometry, "polygon")) {
    grid <- sf::st_as_sf(terra::as.polygons(blank, values = TRUE, na.rm = TRUE))
    names(grid)[1L] <- "pgid"
    grid <- grid[match(pgid, grid$pgid), c("pgid", attr(grid, "sf_column"))]
  } else {
    xy <- terra::xyFromCell(blank, cells)
    grid <- sf::st_as_sf(
      data.frame(pgid = pgid, x = xy[, 1L], y = xy[, 2L]),
      coords = c("x", "y"), crs = terra::crs(blank, proj = TRUE)
    )
  }
  grid$pgid <- as.integer(grid$pgid)
  if (!is.null(crs)) {
    grid <- sf::st_transform(grid, sf::st_crs(crs))
  }
  grid
}
