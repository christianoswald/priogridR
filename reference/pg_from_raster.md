# Convert raster data to PRIO-GRID

Convert raster data to PRIO-GRID

## Usage

``` r
pg_from_raster(
  x,
  variable,
  aggregation,
  time = NULL,
  layer = NULL,
  na_values = NULL,
  disagg_method = c("near", "bilinear", "cubic"),
  return = c("data", "raster", "result"),
  config = priogrid::pg_current_config(),
  filename = NULL,
  overwrite = FALSE,
  ...
)
```

## Arguments

- x:

  A `SpatRaster` or one or more raster-file paths.

- variable:

  Name of the resulting variable.

- aggregation:

  Spatial aggregation passed as `agg_fun` to
  [`priogrid::robust_transformation()`](http://prio-data.github.io/priogrid/reference/robust_transformation.md).

- time:

  Optional date or year for each raster layer.

- layer:

  Optional layer selection passed to `[[`.

- na_values:

  Optional source values to replace with `NA`.

- disagg_method:

  Disaggregation method.

- return:

  One of `"data"`, `"raster"`, or `"result"`.

- config:

  A PRIO-GRID configuration object.

- filename:

  Optional output filename.

- overwrite:

  Replace an existing output file?

- ...:

  Additional arguments passed to
  [`priogrid::robust_transformation()`](http://prio-data.github.io/priogrid/reference/robust_transformation.md).

## Value

A data frame, `SpatRaster`, or `pg_result`.
