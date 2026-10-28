# Converting vector data

``` r

library(priogridR)
```

[`pg_from_vector()`](https://christianoswald.github.io/priogridR/reference/pg_from_vector.md)
converts homogeneous point, line, or polygon data supplied as `sf`,
`SpatVector`, or a vector-file path. Geometry type is detected by
default, and the available aggregation rules depend on that type.

## Configuration

``` r

config <- priogrid::pg_config(
  nrow = 18,
  ncol = 36,
  start_date = as.Date("2020-12-31"),
  end_date = as.Date("2021-12-31"),
  verbose = FALSE
)
```

## Points

Point geometries support counts, presence indicators, sums, means,
minima, and maxima. For coordinate tables,
[`pg_from_points()`](https://christianoswald.github.io/priogridR/reference/pg_from_points.md)
is usually more convenient.

``` r

points <- sf::st_as_sf(
  data.frame(value = c(2, 3, 5), x = c(10, 10.5, 20), y = c(50, 50.5, 60)),
  coords = c("x", "y"),
  crs = 4326
)

point_totals <- pg_from_vector(
  x = points,
  variable = "point_total",
  value = "value",
  aggregation = "sum",
  config = config
)
```

## Lines

Line geometries support total length in metres, length density, distinct
feature counts, and presence.

``` r

roads <- sf::st_sf(
  road_id = 1:2,
  geometry = sf::st_sfc(
    sf::st_linestring(matrix(c(8, 48, 14, 52), ncol = 2, byrow = TRUE)),
    sf::st_linestring(matrix(c(18, 58, 23, 62), ncol = 2, byrow = TRUE)),
    crs = 4326
  )
)

road_length <- pg_from_vector(
  x = roads,
  variable = "road_length_m",
  aggregation = "length",
  config = config
)

head(road_length)
#>   pgid road_length_m
#> 1  487     217419.95
#> 2  488      90616.64
#> 3  524     534502.68
#> 4  525      35523.43
#> 5  561     263563.13
```

## Polygons

Polygon rules include area, cell coverage, feature count, presence,
ordinary value summaries, area-weighted means, and area-weighted
allocation of totals.

``` r

region <- sf::st_polygon(list(matrix(
  c(5, 45, 15, 45, 15, 55, 5, 55, 5, 45),
  ncol = 2,
  byrow = TRUE
)))
regions <- sf::st_sf(value = 100, geometry = sf::st_sfc(region, crs = 4326))

coverage <- pg_from_vector(
  x = regions,
  variable = "region_coverage",
  aggregation = "coverage",
  config = config
)

head(coverage)
#>   pgid region_coverage
#> 1  487       0.2390021
#> 2  488       0.2390021
#> 3  523       0.2656660
#> 4  524       0.2656660
```

Use `weighted_mean` when overlap areas should weight a rate or
continuous attribute. Use `weighted_sum` to allocate a source polygon
total in proportion to overlap with each cell.

## Groups, dates, and output

`time` assigns one date or year to every feature, while `time_column`
maps a feature-level date column to configured intervals.
`group_columns` retains separate summaries but limits output to
`return = "data"`.

Area and length calculations on longitude/latitude geometries require
the s2 engine. The package stops with an informative error rather than
silently using planar degree-based measurements.

See
[`vignette("pg_from_table", package = "priogridR")`](https://christianoswald.github.io/priogridR/articles/pg_from_table.md)
when values are stored in a separate table indexed by polygon
identifiers.
