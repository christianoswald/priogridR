# Converting point and event data

``` r

library(priogridR)
```

[`pg_from_points()`](https://christianoswald.github.io/priogridR/reference/pg_from_points.md)
converts coordinate tables, `sf` objects, `SpatVector` objects, and
point-vector files to cell-level data. Use it for event counts, presence
indicators, or summaries of a numeric value.

## Example data and grid

``` r

events <- data.frame(
  longitude = c(10.1, 10.4, 20.2, 20.4),
  latitude = c(50.1, 50.4, 60.2, 60.4),
  event_date = as.Date(c(
    "2020-03-01", "2020-07-15", "2021-02-01", "2021-09-10"
  )),
  fatalities = c(2, 3, 1, 4),
  event_type = c("A", "A", "B", "B")
)

config <- priogrid::pg_config(
  nrow = 18,
  ncol = 36,
  temporal_resolution = "1 year",
  start_date = as.Date("2020-12-31"),
  end_date = as.Date("2021-12-31"),
  verbose = FALSE
)
```

## Count events

Specify coordinate columns when `x` is a data frame. Coordinates are
assumed to use EPSG:4326 unless `input_crs` says otherwise.

``` r

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
#> 1  524       2020-12-31           2
#> 2  561       2021-12-31           2
```

## Aggregate values

The `sum`, `mean`, `min`, and `max` rules require a `value` column.

``` r

fatality_totals <- pg_from_points(
  x = events,
  variable = "fatalities",
  longitude = "longitude",
  latitude = "latitude",
  value = "fatalities",
  aggregation = "sum",
  time_column = "event_date",
  config = config
)

fatality_totals
#>   pgid measurement_date fatalities
#> 1  524       2020-12-31          5
#> 2  561       2021-12-31          5
```

## Groups and empty cells

Use `group_columns` to retain separate summaries, for example by event
type. Grouped results support `return = "data"` only.

``` r

counts_by_type <- pg_from_points(
  x = events,
  variable = "event_count",
  longitude = "longitude",
  latitude = "latitude",
  aggregation = "count",
  group_columns = "event_type",
  config = config
)
```

With `keep_empty = TRUE`, unobserved cells receive zero only for
`count`, `presence`, and `sum`. Missing means, minima, and maxima remain
missing because zero would have a different substantive meaning.

## Spatial inputs and output

If `x` is already an `sf` or `SpatVector` point object, omit
`longitude`, `latitude`, and `input_crs`. Set `return = "result"` when
both tabular and raster representations plus metadata are useful.

``` r

result <- pg_from_points(
  events,
  variable = "event_count",
  longitude = "longitude",
  latitude = "latitude",
  aggregation = "count",
  return = "result",
  config = config
)

pg_write_result(result, "event_counts.csv")
```

See
[`vignette("pg_from_vector", package = "priogridR")`](https://christianoswald.github.io/priogridR/articles/pg_from_vector.md)
for mixed vector workflows involving lines or polygons.
