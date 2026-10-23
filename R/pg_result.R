new_pg_result <- function(data = NULL, raster = NULL, metadata = list()) {
  if (!is.null(data) && !is.data.frame(data)) {
    stop("`data` must be a data frame or `NULL`.", call. = FALSE)
  }
  if (!is.null(raster) && !inherits(raster, "SpatRaster")) {
    stop("`raster` must be a terra SpatRaster or `NULL`.", call. = FALSE)
  }
  if (!is.list(metadata)) {
    stop("`metadata` must be a list.", call. = FALSE)
  }
  structure(
    list(data = data, raster = raster, metadata = metadata),
    class = "pg_result"
  )
}

#' Print a PRIO-GRID conversion result
#'
#' @param x A `pg_result` object.
#' @param ... Unused.
#' @return `x`, invisibly.
#' @export
print.pg_result <- function(x, ...) {
  cat("<pg_result>\n")
  if (!is.null(x$data)) {
    cat("  Rows: ", format(nrow(x$data), big.mark = ","), "\n", sep = "")
  }
  if (!is.null(x$raster)) {
    cat("  Raster layers: ", terra::nlyr(x$raster), "\n", sep = "")
  }
  if (!is.null(x$metadata$variable)) {
    cat("  Variable: ", x$metadata$variable, "\n", sep = "")
  }
  invisible(x)
}

#' Convert a PRIO-GRID result to a data frame
#'
#' @param x A `pg_result` object.
#' @param row.names,optional,... Passed to [as.data.frame()].
#' @return The tabular component of `x`.
#' @export
as.data.frame.pg_result <- function(x, row.names = NULL, optional = FALSE, ...) {
  if (is.null(x$data)) {
    stop("The result does not contain tabular data.", call. = FALSE)
  }
  as.data.frame(x$data, row.names = row.names, optional = optional, ...)
}

