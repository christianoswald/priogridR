#' @title create_pg_indices
#' @description Create matrix with index numbering conventions as for PRIO-GRID. Taken from https://github.com/prio-data/priogrid/blob/master/R/pgfunctions.R.
#'
#' @param nrow The number of rows in the grid.
#' @param ncol The number of columns in the grid.
#' @return A ncol*nrow matrix with integer indices.
#' @examples
#' pgrid <- create_pg_indices(3, 3)
#' assertthat::are_equal(pgrid[1,1], (ncol*nrow)-ncol+1)
#' assertthat::are_equal(pgrid[nrow, 1], 1)
#' assertthat::are_equal(pgrid[nrow, ncol], ncol)
#' assertthat::are_equal(pgrid[1, ncol], (ncol*nrow))
create_pg_indices <- function(nrow, ncol){
  # To create PRIO-GRID, swap ncol and nrow, load index in reverse order, and
  # rotate 90 degrees once.
  rotate <- function(x) t(apply(x, 2, rev))
  pg <- rotate(matrix(rev(1:(ncol*nrow)), nrow=ncol, ncol=nrow))

  return(pg)
}
