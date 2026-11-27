pg_reconcile_common_variable <- function(x, y, column, conflict) {
  left <- x[[paste0(column, ".x")]]
  right <- x[[paste0(column, ".y")]]
  both <- !is.na(left) & !is.na(right)
  equal <- if (is.numeric(left) && is.numeric(right)) isTRUE(all.equal(left[both], right[both])) else identical(left[both], right[both])
  if (any(both) && !equal && conflict == "error") {
    stop("Conflicting values for variable `", column, "`.", call. = FALSE)
  }
  value <- if (conflict == "last") right else left
  fill <- is.na(value)
  value[fill] <- if (conflict == "last") left[fill] else right[fill]
  x[[column]] <- value
  x[[paste0(column, ".x")]] <- NULL
  x[[paste0(column, ".y")]] <- NULL
  x
}

#' Bind compatible PRIO-GRID datasets
#'
#' Combines datasets by rows or variables after conservative grid, key, and
#' temporal compatibility checks.
#'
#' @param ... Two or more data frames or `pg_result` objects.
#' @param along Bind rows or variables.
#' @param id Cell identifier column.
#' @param time Optional temporal column.
#' @param conflict Handling of duplicate keys or conflicting shared variables.
#' @param config PRIO-GRID configuration used for compatibility checks.
#' @return A data frame with combination metadata attached.
#' @examples
#' config <- priogrid::pg_config(nrow = 2, ncol = 3, verbose = FALSE)
#' x <- data.frame(pgid = 1:3, value = 1:3)
#' y <- data.frame(pgid = 4:6, value = 4:6)
#' pg_bind(x, y, config = config)
#' @export
pg_bind <- function(..., along = c("rows", "variables"), id = "pgid",
                    time = NULL, conflict = c("error", "first", "last"),
                    config = priogrid::pg_current_config()) {
  along <- match.arg(along); conflict <- match.arg(conflict)
  objects <- list(...)
  if (length(objects) < 2L) stop("Supply at least two objects.", call. = FALSE)
  data <- lapply(objects, pg_data_component)
  invisible(pg_assert_compatible(..., check = c("grid", "crs", "time"),
                                 config = config, id = id, time = time))
  keys <- c(id, time)
  lapply(data, pg_key_frame, id = id, time = time)

  if (along == "rows") {
    columns <- unique(unlist(lapply(data, names), use.names = FALSE))
    for (column in columns) {
      present <- which(vapply(data, function(z) column %in% names(z), logical(1)))
      classes <- unique(vapply(data[present], function(z) paste(class(z[[column]]), collapse = "/"), character(1)))
      if (length(classes) > 1L) stop("Column `", column, "` has incompatible classes.", call. = FALSE)
      if (all(vapply(data[present], function(z) is.factor(z[[column]]), logical(1)))) {
        levels_all <- unique(unlist(lapply(data[present], function(z) levels(z[[column]]))))
        data[present] <- lapply(data[present], function(z) {
          z[[column]] <- factor(z[[column]], levels = levels_all, ordered = is.ordered(z[[column]])); z
        })
      }
      template <- data[[present[[1L]]]][[column]]
      for (i in setdiff(seq_along(data), present)) data[[i]][[column]] <- pg_typed_na(template, nrow(data[[i]]))
    }
    data <- lapply(data, function(z) z[columns])
    out <- do.call(rbind, data); rownames(out) <- NULL
    duplicated_key <- duplicated(out[keys]) | duplicated(out[keys], fromLast = TRUE)
    if (any(duplicated_key)) {
      if (conflict == "error") stop("Duplicate keys created while binding rows.", call. = FALSE)
      keep <- if (conflict == "first") !duplicated(out[keys]) else !duplicated(out[keys], fromLast = TRUE)
      out <- out[keep, , drop = FALSE]
    }
  } else {
    out <- data[[1L]]
    for (i in seq_along(data)[-1L]) {
      common <- setdiff(intersect(names(out), names(data[[i]])), keys)
      out <- pg_join(out, data[[i]], by = keys, join = "full",
                     relationship = "one-to-one", unmatched = "keep")
      for (column in common) out <- pg_reconcile_common_variable(out, data[[i]], column, conflict)
    }
  }
  attr(out, "pg_metadata") <- list(
    source_type = "bind", aggregation = NULL,
    provenance = list(operation = paste0("bind_", along), n_inputs = length(objects))
  )
  out
}

