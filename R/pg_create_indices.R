#' Create a matrix of PRIO-GRID identifiers
#'
#' Creates a matrix using the PRIO-GRID numbering convention. Row one is the
#' northernmost row, while identifiers begin in the south-western cell.
#'
#' @param nrow The number of rows in the grid.
#' @param ncol The number of columns in the grid.
#' @return An `nrow` by `ncol` integer matrix.
#' @examples
#' pgrid <- pg_create_indices(3, 3)
#' stopifnot(pgrid[1, 1] == 7L)
#' stopifnot(pgrid[3, 1] == 1L)
#' stopifnot(pgrid[3, 3] == 3L)
#' stopifnot(pgrid[1, 3] == 9L)
#' @export
pg_create_indices <- function(nrow, ncol) {
  if (length(nrow) != 1L || !is.numeric(nrow) || is.na(nrow) ||
      nrow <= 0 || nrow %% 1 != 0) {
    stop("`nrow` must be one positive integer.", call. = FALSE)
  }
  if (length(ncol) != 1L || !is.numeric(ncol) || is.na(ncol) ||
      ncol <= 0 || ncol %% 1 != 0) {
    stop("`ncol` must be one positive integer.", call. = FALSE)
  }
  nrow <- as.integer(nrow)
  ncol <- as.integer(ncol)
  # To create PRIO-GRID, swap ncol and nrow, load index in reverse order, and
  # rotate 90 degrees once.
  rotate <- function(x) t(apply(x, 2, rev))
  rotate(matrix(rev(seq_len(ncol * nrow)), nrow = ncol, ncol = nrow))
}
