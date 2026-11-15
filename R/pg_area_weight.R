#' Transfer cell values to polygons with explicit area weights
#'
#' Extensive values are allocated by the share of each source cell overlapping
#' a target and then summed. Intensive values are averaged with allocation area
#' as the weight. Coverage columns report the share of relevant weight
#' represented by non-missing observations.
#'
#' @param data A data frame containing cell-level values.
#' @param crosswalk A crosswalk created by [pg_crosswalk()].
#' @param values Names of numeric value columns.
#' @param target_id Name of the target identifier column in `crosswalk`.
#' @param variable_type `"extensive"` or `"intensive"`. Supply one value for
#'   all variables or a named vector with one type per value.
#' @param pgid Name of the cell-ID column in `data`.
#' @param time Optional temporal key column.
#' @param group Optional additional grouping columns.
#' @param na_rm Should missing source values be ignored?
#' @return A data frame with target keys, transferred values, and a
#'   `<value>_coverage` diagnostic for every value.
#' @examples
#' crosswalk <- data.frame(
#'   pgid = c(1L, 2L), region = "a",
#'   overlap_area_km2 = c(1, 1), cell_fraction = c(1, 0.5),
#'   target_fraction = c(0.5, 0.5)
#' )
#' x <- data.frame(pgid = 1:2, population = c(10, 20))
#' pg_area_weight(x, crosswalk, "population", "region", "extensive")
#' @export
pg_area_weight <- function(
  data,
  crosswalk,
  values,
  target_id,
  variable_type,
  pgid = "pgid",
  time = NULL,
  group = NULL,
  na_rm = FALSE
) {
  if (!is.data.frame(data) || !is.data.frame(crosswalk)) {
    stop("`data` and `crosswalk` must be data frames.", call. = FALSE)
  }
  values <- validate_column_names(values, "values")
  groups <- validate_column_names(group, "group", allow_null = TRUE)
  validate_variable(pgid)
  if (!is.null(time)) validate_variable(time)
  validate_variable(target_id)
  validate_columns(data, c(pgid, time, groups, values))
  validate_columns(crosswalk, c(
    "pgid", target_id, "overlap_area_km2", "cell_fraction"
  ))
  if (target_id %in% c(pgid, time, groups, values)) {
    stop("`target_id` must differ from source keys and value columns.",
         call. = FALSE)
  }
  if (any(!vapply(data[values], is.numeric, logical(1)))) {
    stop("Every `values` column must be numeric.", call. = FALSE)
  }
  types <- validate_variable_types(values, variable_type)
  validate_flag(na_rm, "na_rm")
  keys <- c(pgid, time, groups)
  if (anyDuplicated(keys)) {
    stop("`pgid`, `time`, and `group` must identify distinct columns.",
         call. = FALSE)
  }
  if (any(!stats::complete.cases(data[keys]))) {
    stop("Source keys must not contain missing values.", call. = FALSE)
  }
  if (anyDuplicated(data[keys])) {
    stop("`data` contains duplicate source keys.", call. = FALSE)
  }
  area_column <- if ("allocation_area_km2" %in% names(crosswalk)) {
    "allocation_area_km2"
  } else {
    "overlap_area_km2"
  }
  usable <- !is.na(crosswalk[[target_id]]) &
    is.finite(crosswalk$cell_fraction) & crosswalk$cell_fraction >= 0 &
    is.finite(crosswalk[[area_column]]) & crosswalk[[area_column]] >= 0
  crosswalk <- crosswalk[usable, , drop = FALSE]
  if (!nrow(crosswalk)) {
    stop("`crosswalk` contains no usable target assignments.", call. = FALSE)
  }
  if (anyDuplicated(crosswalk[c("pgid", target_id)])) {
    stop("`crosswalk` contains duplicate cell-target pairs.", call. = FALSE)
  }
  allocated <- tapply(crosswalk$cell_fraction, crosswalk$pgid, sum)
  if (any(allocated > 1 + 1e-7)) {
    stop("`crosswalk` would allocate more than one complete cell total.",
         call. = FALSE)
  }
  panel_keys <- c(time, groups)
  if (length(panel_keys)) {
    panels <- unique(data[panel_keys])
    expanded <- merge(crosswalk, panels, by = NULL, sort = FALSE)
  } else {
    expanded <- crosswalk
  }
  names(expanded)[names(expanded) == "pgid"] <- pgid
  joined <- merge(
    expanded,
    data[c(keys, values)],
    by = keys,
    all.x = TRUE,
    sort = FALSE
  )
  output_keys <- c(target_id, panel_keys)
  result <- unique(joined[output_keys])
  result <- result[do.call(order, result[output_keys]), , drop = FALSE]
  joined_groups <- cross_level_groups(joined, output_keys)
  group_key <- do.call(
    interaction,
    c(joined[output_keys], list(drop = TRUE, lex.order = TRUE, sep = "\r"))
  )
  result_key <- do.call(
    interaction,
    c(result[output_keys], list(drop = TRUE, lex.order = TRUE, sep = "\r"))
  )
  group_labels <- vapply(
    joined_groups, function(rows) as.character(group_key[rows[1L]]), ""
  )
  for (value in values) {
    weight_column <- if (types[[value]] == "extensive") {
      "cell_fraction"
    } else {
      area_column
    }
    summaries <- lapply(joined_groups, function(rows) {
      summarise_weighted_value(
        joined[[value]][rows], joined[[weight_column]][rows],
        types[[value]], na_rm
      )
    })
    estimates <- vapply(summaries, `[[`, numeric(1), "value")
    coverage <- vapply(summaries, `[[`, numeric(1), "coverage")
    position <- match(as.character(result_key), group_labels)
    result[[value]] <- estimates[position]
    result[[paste0(value, "_coverage")]] <- coverage[position]
  }
  rownames(result) <- NULL
  result
}
