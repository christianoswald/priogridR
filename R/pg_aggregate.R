#' Aggregate PRIO-GRID data by explicit groups
#'
#' Summarizes one or more numeric variables while keeping grouping columns
#' explicit. Optional weights are supported for means; weighted totals should
#' instead be constructed with [pg_area_weight()] so that extensive and
#' intensive variables cannot be confused.
#'
#' @param data A data frame.
#' @param values Names of numeric columns to summarize.
#' @param by Names of grouping columns.
#' @param fun Summary function: `"sum"`, `"mean"`, `"min"`, `"max"`,
#'   `"median"`, or `"sd"`.
#' @param weights Optional name of a non-negative numeric weight column. Weights
#'   may only be used with `fun = "mean"`.
#' @param na_rm Should missing values be removed? When `FALSE`, a missing value
#'   in a group produces a missing summary.
#' @param suffix Optional suffix appended to output value-column names.
#' @return A data frame with one row per unique combination of `by`.
#' @examples
#' x <- data.frame(
#'   region = c("a", "a", "b"),
#'   events = c(1, 2, 4),
#'   population = c(10, 20, 40)
#' )
#' pg_aggregate(x, c("events", "population"), by = "region", fun = "sum")
#' @export
pg_aggregate <- function(
  data,
  values,
  by,
  fun = c("sum", "mean", "min", "max", "median", "sd"),
  weights = NULL,
  na_rm = FALSE,
  suffix = NULL
) {
  if (!is.data.frame(data)) stop("`data` must be a data frame.", call. = FALSE)
  values <- validate_column_names(values, "values")
  by <- validate_column_names(by, "by")
  validate_columns(data, c(values, by, weights))
  if (length(intersect(values, by))) {
    stop("`values` and `by` must identify different columns.", call. = FALSE)
  }
  if (any(!vapply(data[values], is.numeric, logical(1)))) {
    stop("Every `values` column must be numeric.", call. = FALSE)
  }
  if (any(!stats::complete.cases(data[by]))) {
    stop("Grouping columns must not contain missing values.", call. = FALSE)
  }
  fun <- match.arg(fun)
  validate_flag(na_rm, "na_rm")
  if (!is.null(suffix) &&
      (!is.character(suffix) || length(suffix) != 1L || is.na(suffix))) {
    stop("`suffix` must be NULL or one character string.", call. = FALSE)
  }
  if (!is.null(weights)) {
    validate_variable(weights)
    if (fun != "mean") {
      stop("`weights` may only be used with `fun = \"mean\"`.", call. = FALSE)
    }
    if (!is.numeric(data[[weights]]) || any(data[[weights]] < 0, na.rm = TRUE)) {
      stop("`weights` must identify a non-negative numeric column.",
           call. = FALSE)
    }
  }
  groups <- cross_level_groups(data, by)
  output <- data[!duplicated(data[by]), by, drop = FALSE]
  key <- do.call(
    interaction,
    c(data[by], list(drop = TRUE, lex.order = TRUE, sep = "\r"))
  )
  output_key <- do.call(
    interaction,
    c(output[by], list(drop = TRUE, lex.order = TRUE, sep = "\r"))
  )
  result_names <- if (is.null(suffix)) values else paste0(values, suffix)
  if (any(result_names %in% by) || anyDuplicated(result_names)) {
    stop("Output column names conflict with grouping columns.", call. = FALSE)
  }
  for (i in seq_along(values)) {
    value <- values[i]
    summaries <- vapply(groups, function(rows) {
      x <- data[[value]][rows]
      if (!na_rm && anyNA(x)) return(NA_real_)
      if (is.null(weights)) {
        x <- x[!is.na(x)]
        if (!length(x)) return(NA_real_)
        return(switch(
          fun,
          sum = sum(x), mean = mean(x), min = min(x), max = max(x),
          median = stats::median(x),
          sd = if (length(x) < 2L) NA_real_ else stats::sd(x)
        ))
      }
      w <- data[[weights]][rows]
      if (!na_rm && anyNA(w)) return(NA_real_)
      keep <- !is.na(x) & !is.na(w) & w > 0
      if (!any(keep)) return(NA_real_)
      stats::weighted.mean(x[keep], w[keep])
    }, numeric(1))
    group_keys <- vapply(groups, function(rows) as.character(key[rows[1L]]), "")
    output[[result_names[i]]] <- summaries[match(as.character(output_key), group_keys)]
  }
  rownames(output) <- NULL
  output
}
