validate_column_names <- function(x, argument, allow_null = FALSE) {
  if (allow_null && (is.null(x) || identical(x, character()))) {
    return(character())
  }
  if (!is.character(x) || !length(x) || anyNA(x) || any(!nzchar(x)) ||
      anyDuplicated(x)) {
    stop("`", argument, "` must contain unique column names.", call. = FALSE)
  }
  x
}

validate_variable_types <- function(values, variable_type) {
  allowed <- c("extensive", "intensive")
  if (!is.character(variable_type) || !length(variable_type) ||
      anyNA(variable_type)) {
    stop("`variable_type` must contain \"extensive\" or \"intensive\".",
         call. = FALSE)
  }
  if (length(variable_type) == 1L) {
    variable_type <- rep(variable_type, length(values))
    names(variable_type) <- values
  } else {
    if (is.null(names(variable_type)) || anyDuplicated(names(variable_type)) ||
        any(!values %in% names(variable_type))) {
      stop("A multi-value `variable_type` must be named for every `value`.",
           call. = FALSE)
    }
    variable_type <- variable_type[values]
  }
  if (any(!variable_type %in% allowed)) {
    stop("`variable_type` must contain only \"extensive\" or \"intensive\".",
         call. = FALSE)
  }
  variable_type
}

prepare_target_geometry <- function(target, target_id, missing_geometry) {
  if (!inherits(target, "sf")) {
    stop("`target` must be an sf object.", call. = FALSE)
  }
  validate_variable(target_id)
  validate_columns(target, target_id)
  if (anyNA(target[[target_id]])) {
    stop("`target_id` must not contain missing values.", call. = FALSE)
  }
  if (is.na(sf::st_crs(target))) {
    stop("`target` must have a coordinate reference system.", call. = FALSE)
  }
  empty <- sf::st_is_empty(target)
  if (any(empty)) {
    if (missing_geometry == "error") {
      stop("`target` contains empty geometries.", call. = FALSE)
    }
    target <- target[!empty, , drop = FALSE]
  }
  if (!nrow(target)) {
    stop("`target` contains no usable geometries.", call. = FALSE)
  }
  geometry_type <- as.character(sf::st_geometry_type(target))
  if (any(!geometry_type %in% c("POLYGON", "MULTIPOLYGON"))) {
    stop("`target` must contain only polygon geometries.", call. = FALSE)
  }
  valid <- sf::st_is_valid(target)
  if (any(!valid | is.na(valid))) {
    stop("`target` contains invalid geometries; repair them before use.",
         call. = FALSE)
  }
  ids <- unique(target[[target_id]])
  if (length(ids) == nrow(target)) {
    return(target[, c(target_id, attr(target, "sf_column"))])
  }
  geometries <- lapply(ids, function(id) {
    rows <- which(target[[target_id]] == id)
    sf::st_union(sf::st_geometry(target)[rows])[[1L]]
  })
  output <- data.frame(ids, check.names = FALSE)
  names(output) <- target_id
  sf::st_sf(
    output,
    geometry = sf::st_sfc(geometries, crs = sf::st_crs(target))
  )
}

add_unmatched_crosswalk_rows <- function(output, source_ids, target_id) {
  missing_ids <- setdiff(source_ids, output$pgid)
  if (!length(missing_ids)) return(output)
  extra <- output[rep(NA_integer_, length(missing_ids)), , drop = FALSE]
  extra$pgid <- as.integer(missing_ids)
  extra$overlap_area_km2 <- 0
  extra$allocation_area_km2 <- 0
  extra$cell_fraction <- 0
  extra$target_fraction <- NA_real_
  rbind(output, extra)
}

summarise_weighted_value <- function(x, weights, type, na_rm) {
  positive <- !is.na(weights) & weights > 0
  if (!any(positive)) return(c(value = NA_real_, coverage = 0))
  observed <- positive & !is.na(x)
  coverage <- sum(weights[observed]) / sum(weights[positive])
  if (!na_rm && any(positive & is.na(x))) {
    return(c(value = NA_real_, coverage = coverage))
  }
  if (!any(observed)) return(c(value = NA_real_, coverage = coverage))
  value <- if (type == "extensive") {
    sum(x[observed] * weights[observed])
  } else {
    stats::weighted.mean(x[observed], weights[observed])
  }
  c(value = value, coverage = coverage)
}

cross_level_groups <- function(data, columns) {
  if (!length(columns)) return(list(seq_len(nrow(data))))
  key <- do.call(
    interaction,
    c(data[columns], list(drop = TRUE, lex.order = TRUE, sep = "\r"))
  )
  unname(split(seq_len(nrow(data)), key, drop = TRUE))
}

safe_correlation <- function(x, y) {
  keep <- stats::complete.cases(x, y)
  if (sum(keep) < 2L || stats::sd(x[keep]) == 0 || stats::sd(y[keep]) == 0) {
    return(NA_real_)
  }
  stats::cor(x[keep], y[keep])
}
