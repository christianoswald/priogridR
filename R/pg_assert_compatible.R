#' Assert compatibility of PRIO-GRID objects
#'
#' Checks all requested compatibility dimensions and reports detected problems
#' together rather than stopping at the first mismatch.
#'
#' @param ... Two or more data frames, `pg_result` objects, rasters, or
#'   configurations.
#' @param check Compatibility dimensions to check.
#' @param config Optional configuration applied to objects lacking retained
#'   grid metadata.
#' @param id Cell identifier column for data frames.
#' @param time Optional temporal column.
#' @return A compatibility report, invisibly. Incompatible inputs raise an error.
#' @examples
#' config <- priogrid::pg_config(nrow = 2, ncol = 3, verbose = FALSE)
#' x <- data.frame(pgid = 1:3, value = 1:3)
#' y <- data.frame(pgid = 4:6, value = 4:6)
#' pg_assert_compatible(x, y, config = config)
#' @export
pg_assert_compatible <- function(...,
                                 check = c("grid", "crs", "time", "keys"),
                                 config = NULL, id = "pgid", time = NULL) {
  objects <- list(...)
  if (length(objects) < 2L) stop("Supply at least two objects.", call. = FALSE)
  allowed <- c("grid", "crs", "time", "keys")
  if (!length(check) || any(!check %in% allowed) || anyDuplicated(check)) {
    stop("`check` must contain unique values from: grid, crs, time, keys.", call. = FALSE)
  }
  metadata <- lapply(objects, pg_metadata, config = config, id = id, time = time)
  problems <- character()
  reference <- metadata[[1L]]
  for (i in seq_along(metadata)[-1L]) {
    current <- metadata[[i]]
    label <- paste0("object 1 and object ", i)
    if ("grid" %in% check) {
      if (is.null(reference$grid) || is.null(current$grid)) {
        problems <- c(problems, paste0("Grid compatibility cannot be established for ", label, "."))
      } else {
        fields <- c("nrow", "ncol", "n_cells", "resolution", "extent")
        if (!identical(reference$grid[fields], current$grid[fields])) {
          problems <- c(problems, paste0("Grid definitions differ between ", label, "."))
        }
      }
    }
    if ("crs" %in% check && !is.null(reference$grid) && !is.null(current$grid) &&
        !identical(reference$grid$crs, current$grid$crs)) {
      problems <- c(problems, paste0("Coordinate reference systems differ between ", label, "."))
    }
    if ("time" %in% check) {
      a <- reference$time; b <- current$time
      if (!identical(is.null(a$column), is.null(b$column))) {
        problems <- c(problems, paste0("One of ", label, " is temporal and the other is static."))
      } else if (!is.null(a$column) && (!identical(a$class, b$class) ||
                                        (!is.null(a$spacing) && !is.null(b$spacing) && !isTRUE(all.equal(a$spacing, b$spacing))))) {
        problems <- c(problems, paste0("Temporal classes or spacing differ between ", label, "."))
      }
    }
    if ("keys" %in% check && all(vapply(objects[c(1L, i)], function(z) is.data.frame(z) || inherits(z, "pg_result"), logical(1)))) {
      a <- pg_data_component(objects[[1L]]); b <- pg_data_component(objects[[i]])
      validate_columns(a, c(id, time)); validate_columns(b, c(id, time))
      for (column in c(id, time)) {
        if (!identical(class(a[[column]]), class(b[[column]]))) {
          problems <- c(problems, paste0("Key column `", column, "` has different classes between ", label, "."))
        }
      }
      if (anyDuplicated(a[c(id, time)]) || anyDuplicated(b[c(id, time)])) {
        problems <- c(problems, paste0("Duplicate keys prevent compatibility between ", label, "."))
      }
    }
  }
  report <- structure(list(compatible = !length(problems), checks = check,
                           problems = unique(problems), metadata = metadata),
                      class = "pg_compatibility")
  if (length(problems)) {
    stop("PRIO-GRID objects are not compatible:\n- ", paste(unique(problems), collapse = "\n- "), call. = FALSE)
  }
  invisible(report)
}

