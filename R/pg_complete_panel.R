#' Complete a PRIO-GRID panel
#'
#' Adds absent cells or cell-time combinations to a data frame. Existing rows
#' and existing missing values are preserved; `fill` is applied only to rows
#' introduced by this function.
#'
#' @param data A data frame containing PRIO-GRID data.
#' @param pg_id Name of the cell-ID column.
#' @param time Optional name of the temporal identifier column.
#' @param cells Optional cell IDs to include. The configured grid is used by
#'   default.
#' @param times Optional time values to include. Observed non-missing values
#'   are used by default.
#' @param fill Optional named list of values used for newly created rows.
#' @param config A PRIO-GRID configuration object.
#' @return A data frame containing a complete grid or grid-time panel.
#' @examples
#' config <- priogrid::pg_config(nrow = 2, ncol = 3)
#' x <- data.frame(pgid = c(1, 3), events = c(2, 1))
#' pg_complete_panel(x, fill = list(events = 0), config = config)
#' @export
pg_complete_panel <- function(
  data,
  pg_id = "pgid",
  time = NULL,
  cells = NULL,
  times = NULL,
  fill = NULL,
  config = priogrid::pg_current_config()
) {
  if (!is.data.frame(data)) {
    stop("`data` must be a data frame.", call. = FALSE)
  }
  validate_columns(data, c(pg_id, time))
  lookup <- pg_cell_lookup(config)
  validate_pg_id_column(data[[pg_id]], pg_id)
  if (anyNA(data[[pg_id]]) || any(data[[pg_id]] %% 1 != 0) ||
      any(!data[[pg_id]] %in% lookup$pgid)) {
    stop("`data` contains unknown, missing, or invalid cell IDs.",
         call. = FALSE)
  }
  if (is.null(cells)) {
    cells <- lookup$pgid
  }
  validate_pg_id_column(cells, "cells")
  if (anyNA(cells) || any(cells %% 1 != 0) || any(!cells %in% lookup$pgid) ||
      anyDuplicated(cells)) {
    stop("`cells` must contain unique valid cell IDs.", call. = FALSE)
  }
  if (is.null(time) && !is.null(times)) {
    stop("`times` can only be used when `time` names a column.", call. = FALSE)
  }
  if (!is.null(time)) {
    if (is.null(times)) {
      times <- unique(data[[time]][!is.na(data[[time]])])
    }
    if (!length(times) || anyNA(times) || anyDuplicated(times)) {
      stop("`times` must contain unique, non-missing values.", call. = FALSE)
    }
    observed_times <- unique(data[[time]][!is.na(data[[time]])])
    if (any(!observed_times %in% times)) {
      stop("`times` excludes time values present in `data`.", call. = FALSE)
    }
  }
  if (!is.null(fill) && (!is.list(fill) || is.null(names(fill)) ||
                         any(!nzchar(names(fill))))) {
    stop("`fill` must be a named list.", call. = FALSE)
  }
  keys <- c(pg_id, time)
  if (!is.null(fill) && any(names(fill) %in% keys)) {
    stop("`fill` cannot replace panel-key columns.", call. = FALSE)
  }
  if (any(!stats::complete.cases(data[keys]))) {
    stop("Panel keys must not contain missing values.", call. = FALSE)
  }
  if (anyDuplicated(data[keys])) {
    stop("`data` contains duplicate panel keys.", call. = FALSE)
  }
  if (any(!data[[pg_id]] %in% cells)) {
    stop("`cells` excludes cell IDs present in `data`.", call. = FALSE)
  }
  if (is.null(time)) {
    skeleton <- data.frame(value = as.integer(cells))
    names(skeleton) <- pg_id
  } else {
    skeleton <- data.frame(
      rep(as.integer(cells), times = length(times)),
      rep(times, each = length(cells)),
      check.names = FALSE
    )
    names(skeleton) <- c(pg_id, time)
  }
  order_name <- unique_helper_name(data, ".pg_order")
  present_name <- unique_helper_name(data, ".pg_present")
  skeleton[[order_name]] <- seq_len(nrow(skeleton))
  data[[present_name]] <- TRUE
  output <- merge(skeleton, data, by = keys, all.x = TRUE, sort = FALSE)
  output <- output[order(output[[order_name]]), , drop = FALSE]
  introduced <- is.na(output[[present_name]])
  if (!is.null(fill)) {
    unknown <- setdiff(names(fill), names(output))
    if (length(unknown)) {
      stop("Unknown `fill` columns: ", paste(unknown, collapse = ", "), ".",
           call. = FALSE)
    }
    for (column in names(fill)) {
      value <- fill[[column]]
      if (length(value) != 1L) {
        stop("Each `fill` value must have length one.", call. = FALSE)
      }
      output[[column]][introduced] <- value
    }
  }
  output[[order_name]] <- NULL
  output[[present_name]] <- NULL
  rownames(output) <- NULL
  output
}
