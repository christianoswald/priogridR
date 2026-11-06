pg_cell_lookup <- function(config = priogrid::pg_current_config()) {
  validate_pg_config(config)
  blank <- pg_blank(config)
  ids <- terra::values(blank, mat = FALSE)
  if (is.matrix(ids)) {
    ids <- ids[, 1L]
  }
  keep <- !is.na(ids)
  ids <- ids[keep]
  cells <- seq_len(terra::ncell(blank))[keep]
  if (!is.numeric(ids) || any(ids %% 1 != 0) || anyDuplicated(ids)) {
    stop("The configured PRIO-GRID does not contain unique integer cell IDs.",
         call. = FALSE)
  }
  data.frame(pgid = as.integer(ids), cell = as.integer(cells))
}

validate_pg_id_column <- function(x, argument = "pgid") {
  if (!is.numeric(x)) {
    stop("`", argument, "` must contain numeric PRIO-GRID cell IDs.",
         call. = FALSE)
  }
  invisible(x)
}

recycle_coordinate_pair <- function(x, y) {
  size <- max(length(x), length(y))
  if (!length(x) || !length(y) ||
      (!length(x) %in% c(1L, size)) || (!length(y) %in% c(1L, size))) {
    stop("Coordinate vectors must have equal lengths or length one.",
         call. = FALSE)
  }
  list(x = rep(x, length.out = size), y = rep(y, length.out = size))
}

unique_helper_name <- function(x, prefix) {
  candidate <- prefix
  while (candidate %in% names(x)) {
    candidate <- paste0(candidate, "_")
  }
  candidate
}

infer_pg_join_columns <- function(x, y) {
  common <- intersect(names(x), names(y))
  id <- intersect(c("pgid", "gid"), common)
  if (!length(id)) {
    stop("Could not infer a common `pgid` or `gid` column; supply `by` explicitly.",
         call. = FALSE)
  }
  temporal <- intersect(c("date", "year", "month", "time"), common)
  by <- c(id[1L], temporal)
  by <- by[!is.na(by)]
  by
}

check_join_keys <- function(x, by, argument) {
  validate_columns(x, by)
  missing_key <- Reduce(`|`, lapply(x[by], is.na))
  if (any(missing_key)) {
    stop("`", argument, "` contains missing values in its join columns.",
         call. = FALSE)
  }
  invisible(x)
}
