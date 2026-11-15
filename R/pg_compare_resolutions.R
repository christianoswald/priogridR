#' Compare values represented on a common grid
#'
#' Compares reference and candidate data after both have been represented on
#' the same cell and optional panel keys. Cell detail exposes signed, absolute,
#' and relative differences; summary detail reports matching coverage, bias,
#' mean absolute error, root mean squared error, and correlation.
#'
#' @param reference,candidate Data frames represented on the same grid.
#' @param values Names of numeric columns present in both inputs.
#' @param by Key columns used to align observations.
#' @param detail Return `"summary"` diagnostics or `"cells"` differences.
#' @param suffix Two suffixes identifying reference and candidate values in
#'   cell-level output.
#' @return A data frame of summary metrics or aligned cell-level differences.
#' @examples
#' reference <- data.frame(pgid = 1:3, value = c(1, 2, 3))
#' candidate <- data.frame(pgid = 1:3, value = c(1, 2.5, 2.5))
#' pg_compare_resolutions(reference, candidate, "value")
#' pg_compare_resolutions(reference, candidate, "value", detail = "cells")
#' @export
pg_compare_resolutions <- function(
  reference,
  candidate,
  values,
  by = "pgid",
  detail = c("summary", "cells"),
  suffix = c("_reference", "_candidate")
) {
  if (!is.data.frame(reference) || !is.data.frame(candidate)) {
    stop("`reference` and `candidate` must be data frames.", call. = FALSE)
  }
  values <- validate_column_names(values, "values")
  by <- validate_column_names(by, "by")
  if (length(intersect(values, by))) {
    stop("`values` and `by` must identify different columns.", call. = FALSE)
  }
  validate_columns(reference, c(by, values))
  validate_columns(candidate, c(by, values))
  if (any(!vapply(reference[values], is.numeric, logical(1))) ||
      any(!vapply(candidate[values], is.numeric, logical(1)))) {
    stop("Every compared value column must be numeric.", call. = FALSE)
  }
  if (any(!stats::complete.cases(reference[by])) ||
      any(!stats::complete.cases(candidate[by]))) {
    stop("Comparison keys must not contain missing values.", call. = FALSE)
  }
  if (anyDuplicated(reference[by]) || anyDuplicated(candidate[by])) {
    stop("Comparison keys must uniquely identify rows in both inputs.",
         call. = FALSE)
  }
  if (!is.character(suffix) || length(suffix) != 2L || anyNA(suffix) ||
      suffix[1L] == suffix[2L]) {
    stop("`suffix` must contain two different character strings.",
         call. = FALSE)
  }
  detail <- match.arg(detail)
  merged <- merge(
    reference[c(by, values)], candidate[c(by, values)],
    by = by, all = TRUE, sort = FALSE, suffixes = suffix
  )
  if (detail == "cells") {
    output <- merged[by]
    for (value in values) {
      reference_name <- paste0(value, suffix[1L])
      candidate_name <- paste0(value, suffix[2L])
      difference <- merged[[candidate_name]] - merged[[reference_name]]
      relative <- difference / merged[[reference_name]]
      relative[!is.na(merged[[reference_name]]) &
                 merged[[reference_name]] == 0] <- NA_real_
      output[[reference_name]] <- merged[[reference_name]]
      output[[candidate_name]] <- merged[[candidate_name]]
      output[[paste0(value, "_difference")]] <- difference
      output[[paste0(value, "_absolute_difference")]] <- abs(difference)
      output[[paste0(value, "_relative_difference")]] <- relative
    }
    rownames(output) <- NULL
    return(output)
  }
  output <- lapply(values, function(value) {
    x <- merged[[paste0(value, suffix[1L])]]
    y <- merged[[paste0(value, suffix[2L])]]
    matched <- stats::complete.cases(x, y)
    difference <- y[matched] - x[matched]
    data.frame(
      variable = value,
      n_reference = sum(!is.na(x)),
      n_candidate = sum(!is.na(y)),
      n_matched = sum(matched),
      reference_coverage = if (sum(!is.na(x))) {
        sum(matched) / sum(!is.na(x))
      } else NA_real_,
      candidate_coverage = if (sum(!is.na(y))) {
        sum(matched) / sum(!is.na(y))
      } else NA_real_,
      mean_difference = if (length(difference)) mean(difference) else NA_real_,
      mean_absolute_difference = if (length(difference)) {
        mean(abs(difference))
      } else NA_real_,
      rmse = if (length(difference)) sqrt(mean(difference^2)) else NA_real_,
      correlation = safe_correlation(x, y),
      stringsAsFactors = FALSE
    )
  })
  output <- do.call(rbind, output)
  rownames(output) <- NULL
  output
}
