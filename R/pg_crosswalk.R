#' Construct a crosswalk from PRIO-GRID cells to polygons
#'
#' Intersects configured cell polygons with a target polygon system. Fractional
#' assignment retains every positive-area overlap; largest-overlap and centroid
#' assignment return at most one target per cell.
#'
#' @param target An `sf` object containing polygon targets.
#' @param target_id Name of the target identifier column.
#' @param pgid Optional cell IDs. By default every configured cell is used.
#' @param assignment One of `"fractional"`, `"largest"`, or `"centroid"`.
#' @param keep_unmatched Include cells without a target match?
#' @param missing_geometry Drop empty target geometries or raise an error.
#' @param config A PRIO-GRID configuration object.
#' @return A data frame containing `pgid`, the target identifier, overlap and
#'   allocation areas in square kilometres, and fractions of the source cell
#'   and target polygon. Allocation area equals overlap area for fractional
#'   assignment and the whole cell area for discrete assignments.
#' @examples
#' config <- priogrid::pg_config(nrow = 18, ncol = 36)
#' target <- pg_geometry(342:344, config = config)
#' target$region <- c("a", "a", "b")
#' pg_crosswalk(target, "region", pgid = 342:344, config = config)
#' @export
pg_crosswalk <- function(
  target,
  target_id,
  pgid = NULL,
  assignment = c("fractional", "largest", "centroid"),
  keep_unmatched = FALSE,
  missing_geometry = c("error", "drop"),
  config = priogrid::pg_current_config()
) {
  assignment <- match.arg(assignment)
  missing_geometry <- match.arg(missing_geometry)
  validate_flag(keep_unmatched, "keep_unmatched")
  target <- prepare_target_geometry(target, target_id, missing_geometry)
  source <- pg_geometry(pgid, geometry = "polygon", config = config)
  source_ids <- source$pgid
  if (assignment == "centroid") {
    points <- pg_geometry(source_ids, geometry = "point", config = config)
    target <- sf::st_transform(target, sf::st_crs(points))
    matches <- sf::st_intersects(points, target)
    if (any(lengths(matches) > 1L)) {
      stop("Centres intersect multiple targets; use an overlap assignment.",
           call. = FALSE)
    }
    keep <- lengths(matches) == 1L
    if (!keep_unmatched) points <- points[keep, , drop = FALSE]
    match_index <- rep(NA_integer_, nrow(points))
    source_rows <- if (keep_unmatched) seq_along(matches) else which(keep)
    matched <- lengths(matches[source_rows]) == 1L
    match_index[matched] <- vapply(
      matches[source_rows][matched], `[`, integer(1), 1L
    )
    output <- data.frame(pgid = as.integer(points$pgid))
    output[[target_id]] <- target[[target_id]][match_index]
    output$overlap_area_km2 <- NA_real_
    source_area <- geometry_area_m2(source) / 1e6
    names(source_area) <- as.character(source$pgid)
    output$allocation_area_km2 <- ifelse(
      is.na(match_index), 0, source_area[as.character(output$pgid)]
    )
    output$cell_fraction <- ifelse(is.na(match_index), 0, 1)
    output$target_fraction <- NA_real_
    return(output)
  }
  target_area <- sf::st_transform(target, sf::st_crs(source))
  source_area <- source
  source_sizes <- geometry_area_m2(source_area) / 1e6
  target_sizes <- geometry_area_m2(target_area) / 1e6
  names(source_sizes) <- as.character(source_area$pgid)
  names(target_sizes) <- as.character(target_area[[target_id]])
  intersections <- suppressWarnings(sf::st_intersection(
    source_area[, "pgid"], target_area[, target_id]
  ))
  if (nrow(intersections)) {
    areas <- geometry_area_m2(intersections) / 1e6
    positive <- is.finite(areas) & areas > 0
    intersections <- intersections[positive, , drop = FALSE]
    areas <- areas[positive]
    output <- sf::st_drop_geometry(intersections)
    output$pgid <- as.integer(output$pgid)
    output$overlap_area_km2 <- areas
    output$allocation_area_km2 <- areas
    output$cell_fraction <- areas /
      source_sizes[as.character(output$pgid)]
    output$target_fraction <- areas /
      target_sizes[as.character(output[[target_id]])]
    output <- output[c(
      "pgid", target_id, "overlap_area_km2", "allocation_area_km2",
      "cell_fraction", "target_fraction"
    )]
  } else {
    output <- data.frame(
      pgid = integer(), overlap_area_km2 = numeric(),
      allocation_area_km2 = numeric(), cell_fraction = numeric(),
      target_fraction = numeric()
    )
    output[[target_id]] <- target[[target_id]][integer()]
    output <- output[c(
      "pgid", target_id, "overlap_area_km2", "allocation_area_km2",
      "cell_fraction", "target_fraction"
    )]
  }
  if (assignment == "largest" && nrow(output)) {
    split_rows <- split(seq_len(nrow(output)), output$pgid)
    selected <- vapply(split_rows, function(rows) {
      rows[which.max(output$overlap_area_km2[rows])]
    }, integer(1))
    output <- output[selected, , drop = FALSE]
    output$cell_fraction <- 1
    output$allocation_area_km2 <-
      source_sizes[as.character(output$pgid)]
  }
  if (assignment == "fractional" && nrow(output)) {
    allocated <- tapply(output$cell_fraction, output$pgid, sum)
    if (any(allocated > 1 + 1e-7)) {
      stop(
        paste0(
          "Target polygons overlap within one or more cells, which would ",
          "double count fractional allocations."
        ),
        call. = FALSE
      )
    }
  }
  if (keep_unmatched) {
    output <- add_unmatched_crosswalk_rows(output, source_ids, target_id)
  }
  output <- output[order(output$pgid, -output$overlap_area_km2,
                         na.last = TRUE), , drop = FALSE]
  rownames(output) <- NULL
  output
}
