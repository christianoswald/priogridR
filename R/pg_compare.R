#' Compare PRIO-GRID datasets
#'
#' Compares configuration, keys, missingness, types, and selected values while
#' keeping absent keys distinct from observed missing values.
#'
#' @param x,y Data frames or `pg_result` objects.
#' @param id Cell identifier column.
#' @param time Optional temporal column.
#' @param variables Variables to compare. Common non-key columns are used by
#'   default.
#' @param tolerance Numeric equality tolerance.
#' @param config_x,config_y Optional configurations for the two objects.
#' @return A `pg_comparison` object.
#' @examples
#' config <- priogrid::pg_config(nrow = 2, ncol = 3, verbose = FALSE)
#' x <- data.frame(pgid = 1:3, value = 1:3)
#' y <- data.frame(pgid = 2:4, value = c(2, 3, 5))
#' pg_compare(x, y, config_x = config, config_y = config)
#' @export
pg_compare <- function(x, y, id = "pgid", time = NULL, variables = NULL,
                       tolerance = sqrt(.Machine$double.eps),
                       config_x = NULL, config_y = NULL) {
  if (!is.numeric(tolerance) || length(tolerance) != 1L || is.na(tolerance) || tolerance < 0) {
    stop("`tolerance` must be one non-negative number.", call. = FALSE)
  }
  a <- pg_data_component(x); b <- pg_data_component(y)
  keys <- c(id, time)
  pg_key_frame(a, id, time); pg_key_frame(b, id, time)
  if (anyDuplicated(a[keys]) || anyDuplicated(b[keys])) stop("Inputs must have unique comparison keys.", call. = FALSE)
  if (is.null(variables)) variables <- intersect(setdiff(names(a), keys), setdiff(names(b), keys))
  variables <- pg_selected_variables(a, variables, id, time)
  validate_columns(b, variables)
  compatibility_error <- NULL
  compatibility <- tryCatch({
    if (!is.null(config_x) && !is.null(config_y) && !identical(pg_grid_metadata(config_x), pg_grid_metadata(config_y))) {
      stop("Grid definitions differ.", call. = FALSE)
    }
    pg_assert_compatible(x, y, check = c("time", "keys"), config = config_x %||% config_y,
                         id = id, time = time)
    TRUE
  }, error = function(e) { compatibility_error <<- conditionMessage(e); FALSE })
  key_a <- pg_key_string(a[keys]); key_b <- pg_key_string(b[keys])
  key_summary <- data.frame(
    shared = length(intersect(key_a, key_b)),
    x_only = length(setdiff(key_a, key_b)), y_only = length(setdiff(key_b, key_a))
  )
  merged <- merge(a[c(keys, variables)], b[c(keys, variables)], by = keys,
                  all = FALSE, suffixes = c(".x", ".y"), sort = FALSE)
  variable_summary <- do.call(rbind, lapply(variables, function(variable) {
    left <- merged[[paste0(variable, ".x")]]; right <- merged[[paste0(variable, ".y")]]
    paired_missing <- is.na(left) & is.na(right)
    one_missing <- xor(is.na(left), is.na(right))
    comparable <- !is.na(left) & !is.na(right)
    equal <- rep(FALSE, length(left))
    if (is.numeric(left) && is.numeric(right)) equal[comparable] <- abs(left[comparable] - right[comparable]) <= tolerance
    else equal[comparable] <- left[comparable] == right[comparable]
    differences <- if (is.numeric(left) && is.numeric(right) && any(comparable)) left[comparable] - right[comparable] else numeric()
    data.frame(
      variable = variable, class_x = class(left)[[1L]], class_y = class(right)[[1L]],
      n_shared_keys = length(left), n_equal = sum(equal), n_unequal = sum(comparable & !equal),
      n_paired_missing = sum(paired_missing), n_one_sided_missing = sum(one_missing),
      mean_difference = if (length(differences)) mean(differences) else NA_real_,
      max_abs_difference = if (length(differences)) max(abs(differences)) else NA_real_,
      stringsAsFactors = FALSE
    )
  }))
  if (is.null(variable_summary)) {
    variable_summary <- data.frame(
      variable = character(), class_x = character(), class_y = character(),
      n_shared_keys = integer(), n_equal = integer(), n_unequal = integer(),
      n_paired_missing = integer(), n_one_sided_missing = integer(),
      mean_difference = numeric(), max_abs_difference = numeric()
    )
  }
  structure(list(
    compatible = compatibility, compatibility_error = compatibility_error,
    keys = key_summary,
    missingness_x = if (length(variables)) pg_missingness(a, variables, id, time) else data.frame(),
    missingness_y = if (length(variables)) pg_missingness(b, variables, id, time) else data.frame(),
    variables = variable_summary,
    metadata_x = pg_metadata(x, config_x, id, time),
    metadata_y = pg_metadata(y, config_y, id, time)
  ), class = "pg_comparison")
}

#' @rdname pg_compare
#' @param ... Additional arguments, currently unused.
#' @export
print.pg_comparison <- function(x, ...) {
  cat("<pg_comparison>\n")
  cat("  Compatible: ", if (x$compatible) "yes" else "no", "\n", sep = "")
  cat("  Keys: ", x$keys$shared, " shared; ", x$keys$x_only, " x-only; ", x$keys$y_only, " y-only\n", sep = "")
  cat("  Variables compared: ", nrow(x$variables), "\n", sep = "")
  invisible(x)
}

