#' Safely join PRIO-GRID data
#'
#' Joins two data frames after checking key completeness and the expected key
#' relationship. This prevents accidental many-to-many expansion.
#'
#' @param x,y Data frames to join.
#' @param by Character vector of join columns. If `NULL`, conventional
#'   PRIO-GRID and temporal column names are inferred.
#' @param join One of `"left"`, `"inner"`, or `"full"`.
#' @param relationship Expected key relationship between `x` and `y`.
#' @param unmatched Keep unmatched rows where the join permits them, or raise
#'   an error when either input has unmatched keys.
#' @param suffix Suffixes for overlapping non-key column names.
#' @return A joined data frame.
#' @examples
#' x <- data.frame(pgid = 1:3, outcome = c(0, 1, 0))
#' y <- data.frame(pgid = 1:3, exposure = c(2, 4, 1))
#' pg_join(x, y)
#' @export
pg_join <- function(
  x,
  y,
  by = NULL,
  join = c("left", "inner", "full"),
  relationship = c("many-to-one", "one-to-one", "one-to-many", "many-to-many"),
  unmatched = c("keep", "error"),
  suffix = c(".x", ".y")
) {
  if (!is.data.frame(x) || !is.data.frame(y)) {
    stop("`x` and `y` must be data frames.", call. = FALSE)
  }
  join <- match.arg(join)
  relationship <- match.arg(relationship)
  unmatched <- match.arg(unmatched)
  if (is.null(by)) {
    by <- infer_pg_join_columns(x, y)
  }
  if (!is.character(by) || !length(by) || anyNA(by) || any(!nzchar(by)) ||
      anyDuplicated(by)) {
    stop("`by` must contain unique column names.", call. = FALSE)
  }
  if (!is.character(suffix) || length(suffix) != 2L || anyNA(suffix)) {
    stop("`suffix` must contain two character strings.", call. = FALSE)
  }
  check_join_keys(x, by, "x")
  check_join_keys(y, by, "y")
  duplicate_x <- anyDuplicated(x[by]) > 0L
  duplicate_y <- anyDuplicated(y[by]) > 0L
  invalid_relationship <- switch(
    relationship,
    "one-to-one" = duplicate_x || duplicate_y,
    "many-to-one" = duplicate_y,
    "one-to-many" = duplicate_x,
    "many-to-many" = FALSE
  )
  if (invalid_relationship) {
    stop("The join keys do not satisfy the `", relationship,
         "` relationship.", call. = FALSE)
  }
  x_key <- unique(x[by])
  y_key <- unique(y[by])
  x_marker <- unique_helper_name(y_key, ".pg_x_match")
  y_marker <- unique_helper_name(x_key, ".pg_y_match")
  x_check <- x_key
  y_check <- y_key
  x_check[[x_marker]] <- TRUE
  y_check[[y_marker]] <- TRUE
  key_check <- merge(x_check, y_check, by = by, all = TRUE, sort = FALSE)
  unmatched_x <- sum(is.na(key_check[[y_marker]]))
  unmatched_y <- sum(is.na(key_check[[x_marker]]))
  if (identical(unmatched, "error") && (unmatched_x || unmatched_y)) {
    stop("Unmatched keys detected (`x`: ", unmatched_x, ", `y`: ",
         unmatched_y, ").", call. = FALSE)
  }
  x_order <- unique_helper_name(c(x, y), ".pg_x_order")
  y_order <- unique_helper_name(c(x, y), ".pg_y_order")
  x[[x_order]] <- seq_len(nrow(x))
  y[[y_order]] <- seq_len(nrow(y))
  output <- merge(
    x, y, by = by,
    all.x = join %in% c("left", "full"),
    all.y = identical(join, "full"),
    sort = FALSE, suffixes = suffix
  )
  output <- output[order(is.na(output[[x_order]]), output[[x_order]],
                         output[[y_order]], na.last = TRUE), , drop = FALSE]
  output[[x_order]] <- NULL
  output[[y_order]] <- NULL
  rownames(output) <- NULL
  output
}
