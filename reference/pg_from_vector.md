# Convert vector data to PRIO-GRID

Convert vector data to PRIO-GRID

## Usage

``` r
pg_from_vector(
  x,
  variable,
  value = NULL,
  aggregation,
  geometry = c("auto", "point", "line", "polygon"),
  time = NULL,
  time_column = NULL,
  group_columns = NULL,
  keep_empty = FALSE,
  return = c("data", "raster", "result"),
  config = priogrid::pg_current_config(),
  filename = NULL,
  overwrite = FALSE
)
```

## Arguments

- x:

  An `sf` object, `SpatVector`, or vector-file path.

- variable:

  Name of the resulting variable.

- value:

  Optional source value column.

- aggregation:

  Geometry-specific aggregation rule.

- geometry:

  Geometry type, or `"auto"`.

- time:

  Optional static observation date or year. It must fall within the
  configured temporal intervals.

- time_column:

  Optional observation-date column. All dates must be non-missing and
  fall within the configured temporal intervals.

- group_columns:

  Optional additional grouping columns.

- keep_empty:

  For points, complete structurally unobserved cells with zero when the
  aggregation has a meaningful zero. Observed groups whose source values
  are all missing remain missing.

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
events <- sf::st_as_sf(
  data.frame(longitude = c(10, 20), latitude = c(50, 60)),
  coords = c("longitude", "latitude"), crs = 4326
)
config <- priogrid::pg_config(nrow = 18, ncol = 36, verbose = FALSE)
pg_from_vector(
  events,
  variable = "event_count",
  aggregation = "count",
  config = config
)
#>   pgid event_count
#> 1  488           1
#> 2  525           1
```
