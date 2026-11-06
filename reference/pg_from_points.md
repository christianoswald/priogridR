# Convert point or event data to PRIO-GRID

Convert point or event data to PRIO-GRID

## Usage

``` r
pg_from_points(
  x,
  variable,
  longitude = NULL,
  latitude = NULL,
  value = NULL,
  aggregation = c("count", "presence", "sum", "mean", "min", "max"),
  time = NULL,
  time_column = NULL,
  group_columns = NULL,
  input_crs = 4326,
  keep_empty = FALSE,
  return = c("data", "raster", "result"),
  config = priogrid::pg_current_config(),
  filename = NULL,
  overwrite = FALSE
)
```

## Arguments

- x:

  A data frame, `sf` object, `SpatVector`, or vector-file path.

- variable:

  Name of the resulting variable.

- longitude, latitude:

  Coordinate-column names for tabular input.

- value:

  Optional source value column.

- aggregation:

  Point aggregation rule.

- time:

  Optional static observation date or year.

- time_column:

  Optional observation-date column.

- group_columns:

  Optional additional grouping columns.

- input_crs:

  CRS of tabular coordinates.

- keep_empty:

  Complete unobserved cells with zero when meaningful?

- return:

  One of `"data"`, `"raster"`, or `"result"`.

- config:

  A PRIO-GRID configuration object.

- filename:

  Optional output filename.

- overwrite:

  Replace an existing output file?

## Value

A data frame, `SpatRaster`, or `pg_result`.

## Examples

``` r
events <- data.frame(
  longitude = c(10, 10.1, 20),
  latitude = c(50, 50.1, 60)
)
config <- priogrid::pg_config(nrow = 18, ncol = 36, verbose = FALSE)
pg_from_points(
  events,
  variable = "event_count",
  longitude = "longitude",
  latitude = "latitude",
  aggregation = "count",
  config = config
)
#>   pgid event_count
#> 1  488           1
#> 2  524           1
#> 3  525           1
```
