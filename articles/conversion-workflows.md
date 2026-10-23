# Converting data to PRIO-GRID

``` r

library(priogridR)
```

All conversion functions use a
[`priogrid::pg_config()`](http://prio-data.github.io/priogrid/reference/pg_config.md)
object as the source of truth for spatial and temporal resolution.

``` r

config <- priogrid::pg_config(
  nrow = 18,
  ncol = 36,
  temporal_resolution = "1 year",
  start_date = as.Date("2020-12-31"),
  end_date = as.Date("2021-12-31"),
  verbose = FALSE
)
```

## Point-event data

For data frames, specify the coordinate columns. Observation dates are
mapped to the intervals defined by `config`.

``` r

events <- data.frame(
  longitude = c(10, 10.1, 20),
  latitude = c(50, 50.1, 60),
  event_date = as.Date(c("2020-01-01", "2020-03-01", "2021-06-01")),
  fatalities = c(2, 3, 1)
)

event_counts <- pg_from_points(
  x = events,
  variable = "event_count",
  longitude = "longitude",
  latitude = "latitude",
  aggregation = "count",
  time_column = "event_date",
  config = config
)

event_counts
#>   pgid measurement_date event_count
#> 1  488       2020-12-31           1
#> 2  524       2020-12-31           1
#> 3  525       2021-12-31           1
```

To aggregate a value column, provide `value` and an appropriate rule:

``` r

fatalities <- pg_from_points(
  x = events,
  variable = "fatalities",
  longitude = "longitude",
  latitude = "latitude",
  value = "fatalities",
  aggregation = "sum",
  time_column = "event_date",
  config = config
)
```

## Raster data

[`pg_from_raster()`](https://christianoswald.github.io/priogridR/reference/pg_from_raster.md)
accepts a
[`terra::SpatRaster`](https://rspatial.github.io/terra/reference/SpatRaster-class.html)
or raster-file paths. Use `aggregation` to describe how finer cells
should be combined and `disagg_method` when the source is coarser than
the target grid.

``` r

elevation <- pg_from_raster(
  x = "data/raw/elevation.tif",
  variable = "elevation",
  aggregation = "mean",
  return = "result",
  config = config
)
```

## General vector data

[`pg_from_vector()`](https://christianoswald.github.io/priogridR/reference/pg_from_vector.md)
detects point, line, and polygon geometry automatically. Available
aggregation rules depend on the geometry type. Examples include point
counts, line length, polygon coverage, area-weighted means, and
area-weighted allocation of totals.

``` r

road_length <- pg_from_vector(
  x = "data/raw/roads.gpkg",
  variable = "road_length_m",
  aggregation = "length",
  geometry = "line",
  config = config
)

forest_share <- pg_from_vector(
  x = "data/raw/forest.gpkg",
  variable = "forest_share",
  aggregation = "area_share",
  geometry = "polygon",
  config = config
)
```

## NetCDF data

[`pg_from_netcdf()`](https://christianoswald.github.io/priogridR/reference/pg_from_netcdf.md)
reads a NetCDF file or accepts an already-opened `SpatRaster`. Layer
time is taken from the raster when available or supplied explicitly
through `time`.

``` r

precipitation <- pg_from_netcdf(
  x = "data/raw/precipitation.nc",
  source_variable = "precip",
  variable = "precipitation",
  aggregation = "mean",
  config = config
)
```

## Geographically indexed tables

[`pg_from_table()`](https://christianoswald.github.io/priogridR/reference/pg_from_table.md)
joins a table to polygon geography before transferring the values. Use
`area_weighted_sum` to allocate a source-region total among cells; use
`constant` when every intersecting cell should inherit the same value.

``` r

population <- pg_from_table(
  x = population_table,
  variable = "population",
  value = "population_total",
  geography = districts,
  source_id = "district_id",
  geography_id = "district_id",
  aggregation = "area_weighted_sum",
  config = config
)
```

## Missing values and structural zeros

For point data, `keep_empty = TRUE` completes unobserved cells only for
aggregations with an interpretable zero: `count`, `presence`, and `sum`.
It does not replace missing means, minima, or maxima with zero.

## Writing results

``` r

pg_write_result(event_counts, "data/processed/event_counts.csv")
pg_write_result(elevation, "data/processed/elevation.tif")
```
