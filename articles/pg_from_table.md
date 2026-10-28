# Converting geographically indexed tables

``` r

library(priogridR)
```

[`pg_from_table()`](https://christianoswald.github.io/priogridR/reference/pg_from_table.md)
is designed for values stored in a table and indexed by geographic units
such as countries, districts, or administrative regions. It joins the
table to matching polygons and transfers the values to PRIO-GRID.

## Example geography and table

``` r

make_rectangle <- function(xmin, xmax, ymin, ymax) {
  sf::st_polygon(list(matrix(
    c(
      xmin, ymin,
      xmax, ymin,
      xmax, ymax,
      xmin, ymax,
      xmin, ymin
    ),
    ncol = 2,
    byrow = TRUE
  )))
}

districts <- sf::st_sf(
  district_id = c("A", "B"),
  geometry = sf::st_sfc(
    make_rectangle(5, 15, 45, 55),
    make_rectangle(15, 25, 45, 55),
    crs = 4326
  )
)

population <- data.frame(
  district_id = c("A", "B"),
  population_total = c(100000, 150000)
)

config <- priogrid::pg_config(
  nrow = 18,
  ncol = 36,
  start_date = as.Date("2020-12-31"),
  end_date = as.Date("2021-12-31"),
  verbose = FALSE
)
```

`source_id` identifies rows in the table, while `geography_id`
identifies the matching polygons.

``` r

population_pg <- pg_from_table(
  x = population,
  variable = "population",
  value = "population_total",
  geography = districts,
  source_id = "district_id",
  geography_id = "district_id",
  aggregation = "area_weighted_sum",
  config = config
)

head(population_pg)
#>   pgid population
#> 1  487   26308.96
#> 2  488   65772.40
#> 3  489   39463.44
#> 4  523   23691.04
#> 5  524   59227.60
#> 6  525   35536.56
```

## Choosing a transfer rule

Three rules are available:

- `area_weighted_sum` allocates a source-unit total in proportion to
  polygon overlap with each cell. This is appropriate for totals such as
  population when uniform spatial distribution is an acceptable
  assumption.
- `area_weighted_mean` weights source values by their overlap area in
  each target cell. This is suitable for rates or continuous attributes.
- `constant` assigns the source value without proportional allocation
  and is appropriate when the attribute is understood to apply
  throughout the source polygon.

These rules encode different assumptions. Area weighting does not
account for within-polygon population distribution, land use, or other
spatial heterogeneity unless that information is supplied separately.

## Repeated observations and time

Use `time_column` when the table contains observations for multiple
dates. Each date is mapped to an interval in the supplied configuration.

``` r

population_by_year <- data.frame(
  district_id = rep(c("A", "B"), 2),
  observation_date = as.Date(c(
    "2020-12-31", "2020-12-31", "2021-12-31", "2021-12-31"
  )),
  population_total = c(100000, 150000, 102000, 153000)
)

population_time <- pg_from_table(
  x = population_by_year,
  variable = "population",
  value = "population_total",
  geography = districts,
  source_id = "district_id",
  geography_id = "district_id",
  time_column = "observation_date",
  aggregation = "area_weighted_sum",
  config = config
)
```

Before conversion, check for duplicate table keys, unmatched
identifiers, and invalid polygon geometries. Only identifiers present in
both inputs are retained by the join.

See
[`vignette("pg_from_vector", package = "priogridR")`](https://christianoswald.github.io/priogridR/articles/pg_from_vector.md)
for direct polygon conversion and additional aggregation rules.
