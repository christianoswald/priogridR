# Convert NetCDF data to PRIO-GRID

Convert NetCDF data to PRIO-GRID

## Usage

``` r
pg_from_netcdf(
  x,
  variable,
  source_variable = NULL,
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

  A NetCDF path or `SpatRaster` opened from NetCDF.

- variable:

  Name of the resulting variable.

- source_variable:

  Optional NetCDF subdataset name.

- aggregation:

  Spatial raster aggregation rule.

- time:

  Optional explicit layer dates or years.

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

## Examples

``` r
if (FALSE) { # \dontrun{
priogrid::pg_set_rawfolder(file.path(tempdir(), "priogrid-example"))
climate <- terra::rast(
  nrows = 18, ncols = 36, nlyrs = 2,
  xmin = -180, xmax = 180, ymin = -90, ymax = 90,
  crs = "EPSG:4326", vals = 1:(648 * 2)
)
config <- priogrid::pg_config(
  nrow = 18, ncol = 36,
  start_date = as.Date("2020-12-31"),
  end_date = as.Date("2021-12-31"),
  temporal_resolution = "1 year",
  verbose = FALSE
)
pg_from_netcdf(
  climate,
  variable = "temperature",
  aggregation = "mean",
  time = 2020:2021,
  config = config
)
} # }
```
