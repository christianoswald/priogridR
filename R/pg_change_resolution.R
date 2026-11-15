#' Transfer PRIO-GRID values between configured resolutions
#'
#' Uses exact cell intersections to allocate extensive totals or area-average
#' intensive values from one configured grid to another. This function does
#' not infer whether a variable is extensive or intensive.
#'
#' @param data A data frame containing values on `from_config`.
#' @param values Names of numeric value columns.
#' @param from_config Configuration describing the source grid.
#' @param to_config Configuration describing the target grid.
#' @param variable_type `"extensive"` or `"intensive"`, either once for all
#'   variables or as a named vector.
#' @param pgid Name of the source cell-ID column.
#' @param time Optional temporal key column.
#' @param group Optional additional grouping columns.
#' @param na_rm Should missing source values be ignored?
#' @param return_crosswalk Return only the converted data or a list containing
#'   both `data` and the generated `crosswalk`?
#' @return A data frame on the target grid, or a list when
#'   `return_crosswalk = TRUE`.
#' @examples
#' source <- priogrid::pg_config(nrow = 18, ncol = 36)
#' target <- priogrid::pg_config(nrow = 9, ncol = 18)
#' x <- data.frame(pgid = c(342, 343, 378, 379), population = rep(10, 4))
#' pg_change_resolution(
#'   x, "population", source, target, "extensive"
#' )
#' @export
pg_change_resolution <- function(
  data,
  values,
  from_config,
  to_config,
  variable_type,
  pgid = "pgid",
  time = NULL,
  group = NULL,
  na_rm = FALSE,
  return_crosswalk = FALSE
) {
  validate_pg_config(from_config)
  validate_pg_config(to_config)
  validate_flag(return_crosswalk, "return_crosswalk")
  validate_variable(pgid)
  if (!is.null(time)) validate_variable(time)
  validate_columns(data, pgid)
  source_ids <- unique(data[[pgid]])
  target <- pg_geometry(config = to_config)
  target$target_pgid <- target$pgid
  target$pgid <- NULL
  crosswalk <- pg_crosswalk(
    target, "target_pgid", pgid = source_ids,
    assignment = "fractional", config = from_config
  )
  output <- pg_area_weight(
    data, crosswalk, values, "target_pgid", variable_type,
    pgid = pgid, time = time, group = group, na_rm = na_rm
  )
  names(output)[names(output) == "target_pgid"] <- pgid
  output[[pgid]] <- as.integer(output[[pgid]])
  output <- output[c(pgid, time, group, setdiff(names(output), c(pgid, time, group)))]
  if (return_crosswalk) {
    return(list(data = output, crosswalk = crosswalk))
  }
  output
}
