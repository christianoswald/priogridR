test_that("pg_aggregate summarizes groups and supports weighted means", {
  x <- data.frame(
    region = c("a", "a", "b"),
    value = c(1, 3, 8),
    weight = c(1, 3, 1)
  )

  totals <- pg_aggregate(x, "value", "region", fun = "sum")
  averages <- pg_aggregate(
    x, "value", "region", fun = "mean", weights = "weight"
  )

  expect_equal(totals$value, c(4, 8))
  expect_equal(averages$value, c(2.5, 8))
  expect_error(
    pg_aggregate(x, "value", "region", fun = "sum", weights = "weight"),
    "only be used"
  )
})

test_that("pg_aggregate makes missing-value handling explicit", {
  x <- data.frame(region = "a", value = c(1, NA_real_))
  strict <- pg_aggregate(x, "value", "region", fun = "sum")
  removed <- pg_aggregate(x, "value", "region", fun = "sum", na_rm = TRUE)

  expect_true(is.na(strict$value))
  expect_equal(removed$value, 1)
})

test_that("pg_crosswalk reports exact overlap diagnostics", {
  config <- test_config()
  target <- pg_geometry(342:344, config = config)
  target$region <- c("a", "a", "b")

  crosswalk <- pg_crosswalk(
    target, "region", pgid = 342:344, config = config
  )

  expect_equal(nrow(crosswalk), 3L)
  expect_equal(crosswalk$cell_fraction, rep(1, 3), tolerance = 1e-6)
  expect_equal(
    aggregate(target_fraction ~ region, crosswalk, sum)$target_fraction,
    c(1, 1), tolerance = 1e-6
  )
  expect_true(all(crosswalk$overlap_area_km2 > 0))
  expect_equal(
    crosswalk$allocation_area_km2, crosswalk$overlap_area_km2,
    tolerance = 1e-6
  )
})

test_that("pg_crosswalk supports largest and centroid assignments", {
  config <- test_config()
  target <- pg_geometry(342:344, config = config)
  target$region <- c("a", "a", "b")

  largest <- pg_crosswalk(
    target, "region", pgid = 342:344, assignment = "largest", config = config
  )
  centroid <- pg_crosswalk(
    target, "region", pgid = 342:344, assignment = "centroid", config = config
  )

  expect_equal(largest$region, c("a", "a", "b"))
  expect_equal(centroid$region, c("a", "a", "b"))
  expect_equal(centroid$cell_fraction, rep(1, 3))
})

test_that("pg_crosswalk handles unmatched and empty target geometries", {
  config <- test_config()
  target <- pg_geometry(342, config = config)
  target$region <- "a"
  unmatched <- pg_crosswalk(
    target, "region", pgid = 342:343, keep_unmatched = TRUE, config = config
  )

  expect_equal(unmatched$pgid, 342:343)
  expect_true(is.na(unmatched$region[2]))
  expect_equal(unmatched$cell_fraction[2], 0)

  empty <- target
  sf::st_geometry(empty) <- sf::st_sfc(sf::st_polygon(), crs = sf::st_crs(target))
  expect_error(
    pg_crosswalk(empty, "region", pgid = 342, config = config),
    "empty geometries"
  )
})

test_that("pg_crosswalk rejects overlapping fractional targets", {
  config <- test_config()
  target <- pg_geometry(342, config = config)
  target <- rbind(target, target)
  target$region <- c("a", "b")

  expect_error(
    pg_crosswalk(target, "region", pgid = 342, config = config),
    "double count"
  )
})

test_that("pg_area_weight preserves extensive totals", {
  crosswalk <- data.frame(
    pgid = c(1L, 1L, 2L),
    region = c("a", "b", "b"),
    overlap_area_km2 = c(5, 5, 10),
    cell_fraction = c(0.5, 0.5, 1),
    target_fraction = c(1, 1 / 3, 2 / 3)
  )
  x <- data.frame(pgid = 1:2, population = c(10, 20))

  output <- pg_area_weight(
    x, crosswalk, "population", "region", "extensive"
  )

  expect_equal(output$population, c(5, 25))
  expect_equal(sum(output$population), sum(x$population))
  expect_equal(output$population_coverage, c(1, 1))
})

test_that("pg_area_weight area-averages intensive variables", {
  crosswalk <- data.frame(
    pgid = 1:2,
    region = "a",
    overlap_area_km2 = c(1, 3),
    cell_fraction = c(1, 1),
    target_fraction = c(0.25, 0.75)
  )
  x <- data.frame(pgid = 1:2, rate = c(2, 6))

  output <- pg_area_weight(x, crosswalk, "rate", "region", "intensive")
  expect_equal(output$rate, 5)
})

test_that("pg_area_weight reports incomplete coverage", {
  crosswalk <- data.frame(
    pgid = 1:2,
    region = "a",
    overlap_area_km2 = c(1, 1),
    cell_fraction = c(1, 1),
    target_fraction = c(0.5, 0.5)
  )
  x <- data.frame(pgid = 1:2, value = c(10, NA_real_))

  strict <- pg_area_weight(x, crosswalk, "value", "region", "extensive")
  relaxed <- pg_area_weight(
    x, crosswalk, "value", "region", "extensive", na_rm = TRUE
  )

  expect_true(is.na(strict$value))
  expect_equal(strict$value_coverage, 0.5)
  expect_equal(relaxed$value, 10)
  expect_equal(relaxed$value_coverage, 0.5)
})

test_that("pg_to_country aggregates supplied boundary definitions", {
  config <- test_config()
  countries <- pg_geometry(342:344, config = config)
  countries$country <- c("a", "a", "b")
  x <- data.frame(pgid = 342:344, population = c(10, 20, 30))

  output <- pg_to_country(
    x, countries, "country", "population", "extensive", config = config
  )

  expect_equal(output$country, c("a", "b"))
  expect_equal(output$population, c(30, 30), tolerance = 1e-6)
})

test_that("pg_change_resolution transfers extensive and intensive values", {
  source <- test_config()
  target <- priogrid::pg_config(nrow = 9, ncol = 18)
  ids <- c(342L, 343L, 378L, 379L)
  coordinates <- pg_coords_from_id(ids, config = source)
  x <- data.frame(
    pgid = ids,
    population = rep(10, 4),
    rate = ifelse(coordinates$xcoord < 0, 2, 4)
  )

  output <- pg_change_resolution(
    x, c("population", "rate"), source, target,
    variable_type = c(population = "extensive", rate = "intensive")
  )

  expect_true(nrow(output) >= 2L)
  expect_equal(sum(output$population), 40, tolerance = 1e-6)
  expect_equal(sort(unique(output$rate)), c(2, 4), tolerance = 1e-6)
})

test_that("pg_compare_resolutions returns cell and summary diagnostics", {
  reference <- data.frame(pgid = 1:3, value = c(1, 2, 3))
  candidate <- data.frame(pgid = 1:3, value = c(1, 3, 2))

  cells <- pg_compare_resolutions(
    reference, candidate, "value", detail = "cells"
  )
  summary <- pg_compare_resolutions(reference, candidate, "value")

  expect_equal(cells$value_difference, c(0, 1, -1))
  expect_equal(summary$n_matched, 3)
  expect_equal(summary$mean_difference, 0)
  expect_equal(summary$rmse, sqrt(2 / 3))
  expect_equal(summary$reference_coverage, 1)
})

test_that("cross-level functions reject ambiguous inputs", {
  expect_error(
    pg_aggregate(data.frame(group = "a", value = "x"), "value", "group"),
    "must be numeric"
  )
  crosswalk <- data.frame(
    pgid = c(1L, 1L), region = c("a", "a"),
    overlap_area_km2 = 1, cell_fraction = 1
  )
  expect_error(
    pg_area_weight(
      data.frame(pgid = 1L, value = 1), crosswalk,
      "value", "region", "extensive"
    ),
    "duplicate cell-target"
  )
  expect_error(
    pg_compare_resolutions(
      data.frame(pgid = c(1, 1), value = 1:2),
      data.frame(pgid = 1, value = 1), "value"
    ),
    "uniquely identify"
  )
})
