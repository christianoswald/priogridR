#' Summarize observed missing values
#'
#' Missingness is calculated only among rows present in `x`; structurally
#' absent cell-periods are handled by [pg_coverage()].
#'
#' @param x A data frame or `pg_result` with a tabular component.
#' @param variables Columns to summarize. By default, all non-key and
#'   non-grouping columns are used.
#' @param id Cell identifier column.
#' @param time Optional temporal column.
#' @param group_columns Optional grouping columns.
#' @param by Summary dimension: variable, cell, time, or group.
#' @return A data frame with observed, missing, non-missing, and missing-share
#'   columns.
#' @examples
#' x <- data.frame(pgid = 1:3, value = c(1, NA, 3))
#' pg_missingness(x)
#' @export
pg_missingness <- function(x, variables = NULL, id = "pgid", time = NULL,
                           group_columns = NULL,
                           by = c("variable", "cell", "time", "group")) {
  by <- match.arg(by)
  data <- pg_data_component(x)
  validate_columns(data, c(id, time, group_columns))
  variables <- pg_selected_variables(data, variables, id, time, group_columns)
  if (!length(variables)) stop("No variables are available to summarize.", call. = FALSE)
  if (by == "cell") group <- id else if (by == "time") {
    if (is.null(time)) stop("`time` is required for `by = \"time\"`.", call. = FALSE)
    group <- time
  } else if (by == "group") {
    if (!length(group_columns)) stop("`group_columns` is required for `by = \"group\"`.", call. = FALSE)
    group <- group_columns
  } else group <- NULL

  if (!nrow(data)) {
    if (by == "variable") {
      return(data.frame(
        variable = variables, n_observed = 0L, n_missing = 0L,
        n_non_missing = 0L, missing_share = NA_real_,
        stringsAsFactors = FALSE
      ))
    }
    out <- data[0, group, drop = FALSE]
    out$variable <- character()
    out$n_observed <- integer(); out$n_missing <- integer()
    out$n_non_missing <- integer(); out$missing_share <- numeric()
    return(out)
  }

  long <- do.call(rbind, lapply(variables, function(variable) {
    result <- data[group]
    result$variable <- variable
    result$.missing <- is.na(data[[variable]])
    result
  }))
  rownames(long) <- NULL
  keys <- c(group, if (by == "variable" || !length(group)) "variable" else "variable")
  if (!nrow(long)) {
    out <- unique(long[keys])
    out$n_observed <- integer(nrow(out)); out$n_missing <- integer(nrow(out))
  } else {
    split_key <- do.call(interaction, c(long[keys], list(drop = TRUE, lex.order = TRUE)))
    parts <- split(seq_len(nrow(long)), split_key)
    out <- do.call(rbind, lapply(parts, function(i) {
      row <- long[i[[1L]], keys, drop = FALSE]
      row$n_observed <- length(i)
      row$n_missing <- sum(long$.missing[i])
      row
    }))
  }
  if (!nrow(out) && by == "variable") {
    out <- data.frame(variable = variables, n_observed = 0L, n_missing = 0L)
  }
  out$n_non_missing <- out$n_observed - out$n_missing
  out$missing_share <- ifelse(out$n_observed == 0L, NA_real_, out$n_missing / out$n_observed)
  rownames(out) <- NULL
  out
}

