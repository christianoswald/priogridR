#' Aggregate PRIO-GRID values to supplied country boundaries
#'
#' Builds a reproducible cell-to-country crosswalk from user-supplied country
#' polygons and transfers values using explicit extensive or intensive
#' semantics. Supplying boundaries keeps the territorial definition and date
#' under the researcher's control. A single boundary definition is used per
#' call; historical panels with changing borders should be processed by
#' boundary vintage and then combined explicitly.
#'
#' @param data A data frame containing cell-level values.
#' @param countries An `sf` object containing country polygons.
#' @param country_id Name of the country identifier column.
#' @param values Names of numeric value columns.
#' @param variable_type `"extensive"` or `"intensive"`, either once for all
#'   variables or as a named vector.
#' @param pgid Name of the cell-ID column in `data`.
#' @param time Optional temporal key column.
#' @param group Optional additional grouping columns.
#' @param assignment Cell assignment method passed to [pg_crosswalk()].
#' @param na_rm Should missing source values be ignored?
#' @param return_crosswalk Return only the aggregated data or a list containing
#'   both `data` and the generated `crosswalk`?
#' @param config A PRIO-GRID configuration object.
#' @return A data frame, or a list when `return_crosswalk = TRUE`.
#' @examples
#' config <- priogrid::pg_config(nrow = 18, ncol = 36)
#' countries <- pg_geometry(342:344, config = config)
#' countries$country <- c("a", "a", "b")
#' x <- data.frame(pgid = 342:344, population = c(10, 20, 30))
#' pg_to_country(
#'   x, countries, "country", "population", "extensive",
#'   config = config
#' )
#' @export
pg_to_country <- function(
  data,
  countries,
  country_id,
  values,
  variable_type,
  pgid = "pgid",
  time = NULL,
  group = NULL,
  assignment = c("fractional", "largest", "centroid"),
  na_rm = FALSE,
  return_crosswalk = FALSE,
  config = priogrid::pg_current_config()
) {
  assignment <- match.arg(assignment)
  validate_flag(return_crosswalk, "return_crosswalk")
  validate_variable(pgid)
  if (!is.null(time)) validate_variable(time)
  validate_columns(data, pgid)
  ids <- unique(data[[pgid]])
  crosswalk <- pg_crosswalk(
    countries, country_id, pgid = ids, assignment = assignment,
    keep_unmatched = FALSE, config = config
  )
  output <- pg_area_weight(
    data, crosswalk, values, country_id, variable_type,
    pgid = pgid, time = time, group = group, na_rm = na_rm
  )
  if (return_crosswalk) {
    return(list(data = output, crosswalk = crosswalk))
  }
  output
}
