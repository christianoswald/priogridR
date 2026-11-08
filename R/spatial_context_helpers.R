validate_pgid_values <- function(x, argument, config) {
  validate_pg_id_column(x, argument)
  lookup <- pg_cell_lookup(config)
  if (anyNA(x) || any(x %% 1 != 0) || any(!x %in% lookup$pgid)) {
    stop("`", argument, "` contains unknown or invalid PRIO-GRID cell IDs.",
         call. = FALSE)
  }
  as.integer(x)
}

validate_flag <- function(x, argument) {
  if (length(x) != 1L || !is.logical(x) || is.na(x)) {
    stop("`", argument, "` must be TRUE or FALSE.", call. = FALSE)
  }
  invisible(x)
}

validate_positive_number <- function(x, argument, allow_zero = FALSE) {
  lower_ok <- if (allow_zero) x >= 0 else x > 0
  if (length(x) != 1L || !is.numeric(x) || is.na(x) || !is.finite(x) ||
      !lower_ok) {
    qualifier <- if (allow_zero) "non-negative" else "positive"
    stop("`", argument, "` must be one finite ", qualifier, " number.",
         call. = FALSE)
  }
  invisible(x)
}

pg_distance_matrix <- function(from, to, config) {
  from_points <- pg_geometry(from, geometry = "point", crs = 4326,
                             config = config)
  to_points <- pg_geometry(to, geometry = "point", crs = 4326,
                           config = config)
  matrix(
    as.numeric(sf::st_distance(from_points, to_points)) / 1000,
    nrow = length(from), ncol = length(to)
  )
}

pg_pairwise_distances <- function(from, to, config) {
  unique_from <- unique(from)
  unique_to <- unique(to)
  from_points <- pg_geometry(unique_from, geometry = "point", crs = 4326,
                             config = config)
  to_points <- pg_geometry(unique_to, geometry = "point", crs = 4326,
                           config = config)
  from_geometry <- sf::st_geometry(from_points)[match(from, unique_from)]
  to_geometry <- sf::st_geometry(to_points)[match(to, unique_to)]
  as.numeric(sf::st_distance(from_geometry, to_geometry, by_element = TRUE)) / 1000
}

empty_neighbor_table <- function(with_distance = FALSE) {
  out <- data.frame(pgid = integer(), neighbor_pgid = integer())
  if (with_distance) {
    out$distance_km <- numeric()
  }
  out
}

split_panel_rows <- function(data, time) {
  if (is.null(time)) {
    return(list(`__all__` = seq_len(nrow(data))))
  }
  split(seq_len(nrow(data)), interaction(data[time], drop = TRUE, lex.order = TRUE))
}

summarise_buffer_values <- function(x, statistic, na_rm) {
  if (!length(x)) {
    return(if (statistic %in% c("count", "sum")) 0 else NA_real_)
  }
  if (identical(statistic, "count")) {
    return(sum(!is.na(x)))
  }
  if (!isTRUE(na_rm) && anyNA(x)) {
    return(NA_real_)
  }
  x <- x[!is.na(x)]
  if (!length(x)) {
    return(if (identical(statistic, "sum")) 0 else NA_real_)
  }
  switch(
    statistic,
    sum = sum(x),
    mean = mean(x),
    min = min(x),
    max = max(x)
  )
}

check_distance_workload <- function(n_from, n_to) {
  pairs <- as.double(n_from) * as.double(n_to)
  if (pairs > 1e7) {
    stop(
      "The requested distance calculation exceeds 10 million cell pairs. ",
      "Restrict the source or candidate cells and process larger jobs in chunks.",
      call. = FALSE
    )
  }
  invisible(pairs)
}
