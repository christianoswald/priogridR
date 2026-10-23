#' Find first-order PRIO-GRID neighbors
#'
#' Returns queen-contiguity neighbors: cells sharing either an edge or a
#' corner with the requested cell. Longitude wraps across the antimeridian by
#' default; latitude never wraps across the poles.
#'
#' @param x One PRIO-GRID cell identifier.
#' @param nrow Number of grid rows.
#' @param ncol Number of grid columns.
#' @param wrap_longitude Should the western and eastern edges be adjacent?
#' @return An integer vector containing neighboring cell identifiers. Interior
#'   cells have eight neighbors and cells in the northern or southern row have
#'   five when `wrap_longitude = TRUE`.
#' @examples
#' pg_neighbors(234209)
#' pg_neighbors(1, nrow = 3, ncol = 3)
#' @export
pg_neighbors <- function(
  x,
  nrow = 360L,
  ncol = 720L,
  wrap_longitude = TRUE
) {
  validate_grid_dimension(nrow, "nrow")
  validate_grid_dimension(ncol, "ncol")
  nrow <- as.integer(nrow)
  ncol <- as.integer(ncol)
  maximum <- nrow * ncol
  if (length(x) != 1L || !is.numeric(x) || is.na(x) ||
      x %% 1 != 0 || x < 1 || x > maximum) {
    stop(
      "`x` must be one integer between 1 and ", maximum, ".",
      call. = FALSE
    )
  }
  if (length(wrap_longitude) != 1L || !is.logical(wrap_longitude) ||
      is.na(wrap_longitude)) {
    stop("`wrap_longitude` must be TRUE or FALSE.", call. = FALSE)
  }
  x <- as.integer(x)
  source_row <- ((x - 1L) %/% ncol) + 1L
  source_col <- ((x - 1L) %% ncol) + 1L
  row_offset <- c(1L, 1L, 1L, 0L, 0L, -1L, -1L, -1L)
  col_offset <- c(-1L, 0L, 1L, -1L, 1L, -1L, 0L, 1L)
  neighbor_row <- source_row + row_offset
  neighbor_col <- source_col + col_offset
  keep <- neighbor_row >= 1L & neighbor_row <= nrow
  if (isTRUE(wrap_longitude)) {
    neighbor_col <- ((neighbor_col - 1L) %% ncol) + 1L
  } else {
    keep <- keep & neighbor_col >= 1L & neighbor_col <= ncol
  }
  result <- (neighbor_row[keep] - 1L) * ncol + neighbor_col[keep]
  unique(as.integer(result[result != x]))
}

validate_grid_dimension <- function(x, argument) {
  if (length(x) != 1L || !is.numeric(x) || is.na(x) ||
      x <= 0 || x %% 1 != 0) {
    stop("`", argument, "` must be one positive integer.", call. = FALSE)
  }
  invisible(x)
}
