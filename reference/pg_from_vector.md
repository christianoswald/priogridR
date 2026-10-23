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

  Optional static observation date or year.

- time_column:

  Optional observation-date column.

- group_columns:

  Optional additional grouping columns.

- keep_empty:

  For points, complete unobserved cells with zero when the aggregation
  has a meaningful zero.

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
