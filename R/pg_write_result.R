write_pg_table <- function(x, filename, overwrite = FALSE) {
  validate_output_path(filename, overwrite)
  dir.create(dirname(filename), recursive = TRUE, showWarnings = FALSE)
  extension <- tolower(tools::file_ext(filename))
  switch(
    extension,
    csv = utils::write.csv(x, filename, row.names = FALSE),
    rds = saveRDS(x, filename),
    parquet = {
      if (!requireNamespace("arrow", quietly = TRUE)) {
        stop("Writing Parquet files requires the `arrow` package.", call. = FALSE)
      }
      arrow::write_parquet(x, filename)
    },
    stop("Unsupported table extension: .", extension, call. = FALSE)
  )
  invisible(filename)
}

write_pg_raster <- function(x, filename, overwrite = FALSE) {
  validate_output_path(filename, overwrite)
  dir.create(dirname(filename), recursive = TRUE, showWarnings = FALSE)
  terra::writeRaster(x, filename = filename, overwrite = overwrite)
  invisible(filename)
}

#' Write a PRIO-GRID conversion result
#'
#' @param x A `pg_result`, `SpatRaster`, or data frame.
#' @param filename Output path. Supported extensions are `.csv`, `.rds`,
#'   `.parquet`, `.tif`, `.tiff`, and `.vrt`.
#' @param overwrite Replace an existing file?
#' @return `filename`, invisibly.
#' @examples
#' output <- tempfile(fileext = ".csv")
#' pg_write_result(data.frame(pgid = 1:3, value = c(2, 4, 1)), output)
#' utils::read.csv(output)
#' unlink(output)
#' @export
pg_write_result <- function(x, filename, overwrite = FALSE) {
  extension <- tolower(tools::file_ext(filename))
  if (inherits(x, "pg_result")) {
    if (extension %in% c("tif", "tiff", "vrt")) {
      if (is.null(x$raster)) {
        stop("The result does not contain raster data.", call. = FALSE)
      }
      return(write_pg_raster(x$raster, filename, overwrite))
    }
    if (extension %in% c("csv", "rds", "parquet")) {
      if (is.null(x$data)) {
        stop("The result does not contain tabular data.", call. = FALSE)
      }
      return(write_pg_table(x$data, filename, overwrite))
    }
    stop("Unsupported file extension: .", extension, call. = FALSE)
  }
  if (inherits(x, "SpatRaster")) {
    return(write_pg_raster(x, filename, overwrite))
  }
  if (is.data.frame(x)) {
    return(write_pg_table(x, filename, overwrite))
  }
  stop("`x` must be a `pg_result`, SpatRaster, or data frame.", call. = FALSE)
}
