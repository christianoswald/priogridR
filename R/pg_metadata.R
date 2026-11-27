#' Inspect PRIO-GRID metadata
#'
#' Returns standardized spatial, temporal, variable, and provenance metadata
#' without inventing information that is unavailable from the object.
#'
#' @param x A `pg_result`, data frame, `SpatRaster`, or `pg_config` object.
#' @param config Optional PRIO-GRID configuration used to describe a data frame
#'   or to supplement an object that does not retain configuration metadata.
#' @param id Cell identifier column for data-frame inputs.
#' @param time Optional temporal column. A unique conventional temporal column
#'   is detected when omitted.
#' @return A structured `pg_metadata` list.
#' @examples
#' config <- priogrid::pg_config(nrow = 2, ncol = 3, verbose = FALSE)
#' x <- data.frame(pgid = 1:6, value = seq_len(6))
#' pg_metadata(x, config = config)
#' @export
pg_metadata <- function(x, config = NULL, id = "pgid", time = NULL) {
  stored <- NULL
  object_class <- class(x)[[1L]]
  if (inherits(x, "pg_result")) {
    stored <- x$metadata
    if (is.null(config)) config <- stored$config
    data <- x$data
    raster <- x$raster
  } else if (inherits(x, "SpatRaster")) {
    data <- NULL
    raster <- x
  } else if (inherits(x, "pg_config")) {
    config <- x
    data <- NULL
    raster <- NULL
  } else if (is.data.frame(x)) {
    stored <- attr(x, "pg_metadata", exact = TRUE)
    data <- x
    raster <- NULL
  } else {
    stop("`x` must be a data frame, `pg_result`, `SpatRaster`, or `pg_config`.", call. = FALSE)
  }
  if (!is.null(data)) {
    validate_columns(data, id)
    if (is.null(time)) time <- pg_detect_time_column(data)
    if (!is.null(time)) validate_columns(data, time)
  }
  grid <- pg_grid_metadata(config)
  if (is.null(grid) && !is.null(raster)) {
    extent <- as.vector(terra::ext(raster))
    names(extent) <- c("xmin", "xmax", "ymin", "ymax")
    grid <- list(
      nrow = terra::nrow(raster), ncol = terra::ncol(raster),
      n_cells = terra::ncell(raster),
      resolution = stats::setNames(terra::res(raster), c("x", "y")),
      extent = extent, crs = terra::crs(raster, proj = TRUE)
    )
  }
  time_info <- if (!is.null(data)) {
    pg_time_metadata(data, time)
  } else if (!is.null(raster)) {
    raster_time <- terra::time(raster)
    if (length(raster_time) && !all(is.na(raster_time))) {
      pg_time_metadata(data.frame(.time = raster_time), ".time")
    } else {
      pg_time_metadata(data.frame())
    }
  } else {
    pg_time_metadata(data.frame())
  }
  variables <- if (!is.null(data)) setdiff(names(data), c(id, time)) else if (!is.null(raster)) names(raster) else character()
  out <- list(
    schema_version = 1L,
    object_class = object_class,
    grid = grid,
    time = time_info,
    keys = list(id = if (!is.null(data)) id else NULL, time = time),
    variables = variables,
    variable = stored$variable %||% NULL,
    source_type = stored$source_type %||% NULL,
    aggregation = stored$aggregation %||% NULL,
    provenance = stored$provenance %||% NULL,
    package = list(name = "priogridR", version = as.character(utils::packageVersion("priogridR")))
  )
  structure(out, class = "pg_metadata")
}

#' @rdname pg_metadata
#' @param ... Additional arguments, currently unused.
#' @export
print.pg_metadata <- function(x, ...) {
  cat("<pg_metadata>\n")
  cat("  Object: ", x$object_class, "\n", sep = "")
  if (!is.null(x$grid)) cat("  Grid: ", x$grid$nrow, " x ", x$grid$ncol, " (", x$grid$n_cells, " cells)\n", sep = "")
  if (length(x$variables)) cat("  Variables: ", paste(x$variables, collapse = ", "), "\n", sep = "")
  if (!is.null(x$time$column)) cat("  Time: ", x$time$column, " (", x$time$n_periods, " periods)\n", sep = "")
  invisible(x)
}

