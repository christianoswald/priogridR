pg_data_component <- function(x) {
  if (inherits(x, "pg_result")) {
    if (is.null(x$data)) stop("The `pg_result` has no tabular component.", call. = FALSE)
    return(x$data)
  }
  if (!is.data.frame(x)) stop("`x` must be a data frame or `pg_result`.", call. = FALSE)
  x
}

pg_grid_metadata <- function(config) {
  if (is.null(config)) return(NULL)
  validate_pg_config(config)
  blank <- pg_blank(config)
  extent <- as.vector(terra::ext(blank))
  names(extent) <- c("xmin", "xmax", "ymin", "ymax")
  list(
    nrow = terra::nrow(blank),
    ncol = terra::ncol(blank),
    n_cells = nrow(pg_cell_lookup(config)),
    resolution = stats::setNames(terra::res(blank), c("x", "y")),
    extent = extent,
    crs = terra::crs(blank, proj = TRUE)
  )
}

pg_detect_time_column <- function(x) {
  candidates <- intersect(c("measurement_date", "date", "yearmonth", "year", "month", "time"), names(x))
  if (length(candidates) == 1L) candidates else NULL
}

pg_time_metadata <- function(x, time = NULL) {
  if (is.null(time) || !time %in% names(x)) {
    return(list(column = NULL, class = NULL, minimum = NULL, maximum = NULL,
                n_periods = 0L, spacing = NULL))
  }
  value <- x[[time]]
  observed <- sort(unique(value[!is.na(value)]))
  spacing <- NULL
  if (length(observed) > 1L && (is.numeric(observed) || inherits(observed, c("Date", "POSIXt")))) {
    differences <- as.numeric(diff(observed))
    if (length(unique(differences)) == 1L) spacing <- differences[[1L]]
  }
  list(
    column = time,
    class = class(value)[[1L]],
    minimum = if (length(observed)) observed[[1L]] else NULL,
    maximum = if (length(observed)) observed[[length(observed)]] else NULL,
    n_periods = length(observed),
    spacing = spacing
  )
}

pg_typed_na <- function(x, n) {
  if (inherits(x, "Date")) return(as.Date(rep(NA_real_, n), origin = "1970-01-01"))
  if (inherits(x, "POSIXct")) return(as.POSIXct(rep(NA_real_, n), origin = "1970-01-01", tz = attr(x, "tzone") %||% "UTC"))
  if (is.factor(x)) return(factor(rep(NA_character_, n), levels = levels(x), ordered = is.ordered(x)))
  if (is.integer(x)) return(rep(NA_integer_, n))
  if (is.double(x)) return(rep(NA_real_, n))
  if (is.logical(x)) return(rep(NA, n))
  if (is.character(x)) return(rep(NA_character_, n))
  rep(NA, n)
}

`%||%` <- function(x, y) if (is.null(x)) y else x

pg_key_frame <- function(x, id, time = NULL) {
  validate_columns(x, c(id, time))
  keys <- c(id, time)
  if (any(!stats::complete.cases(x[keys]))) stop("Key columns contain missing values.", call. = FALSE)
  x[keys]
}

pg_key_string <- function(x) {
  if (!ncol(x)) return(rep("", nrow(x)))
  do.call(paste, c(lapply(x, function(z) {
    if (inherits(z, "Date")) format(z, "%Y-%m-%d") else as.character(z)
  }), sep = "\r"))
}

pg_selected_variables <- function(x, variables, id = "pgid", time = NULL,
                                  group_columns = NULL) {
  if (is.null(variables)) variables <- setdiff(names(x), c(id, time, group_columns))
  if (!is.character(variables) || anyNA(variables) || any(!nzchar(variables)) || anyDuplicated(variables)) {
    stop("`variables` must contain unique, non-missing column names.", call. = FALSE)
  }
  validate_columns(x, variables)
  variables
}

