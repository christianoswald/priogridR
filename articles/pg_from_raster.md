# Converting raster data

``` r

library(priogridR)
```

[`pg_from_raster()`](https://christianoswald.github.io/priogridR/reference/pg_from_raster.md)
accepts a
[`terra::SpatRaster`](https://rspatial.github.io/terra/reference/SpatRaster-class.html)
or one or more raster-file paths. It aligns the source to a configured
PRIO-GRID and can return a raster, a cell-level table, or both.

Raster transformation uses the working directory managed by `priogrid`.
In a real project, configure a persistent location once with, for
example, the following code before running the conversion examples:

``` r

priogrid::pg_set_rawfolder("data/priogrid")
```

The conversion chunks are not evaluated while the vignette is built
because the working directory is a persistent, user-specific setting.

## A small raster example

``` r

config <- priogrid::pg_config(
  nrow = 18,
  ncol = 36,
  start_date = as.Date("2020-12-31"),
  end_date = as.Date("2021-12-31"),
  verbose = FALSE
)

temperature <- terra::rast(
  nrows = 18,
  ncols = 36,
  xmin = -180,
  xmax = 180,
  ymin = -90,
  ymax = 90,
  crs = "EPSG:4326"
)
terra::values(temperature) <- seq_len(terra::ncell(temperature)) / 10
```

Convert the raster and request tabular output:

``` r

temperature_pg <- pg_from_raster(
  x = temperature,
  variable = "temperature",
  aggregation = "mean",
  return = "data",
  config = config
)

head(temperature_pg)
```

## Choosing an aggregation rule

Available rules are `sum`, `mean`, `min`, `max`, `median`, and `modal`.
Choose the rule based on the variable’s meaning:

- use `mean` for continuous surfaces such as temperature;
- use `sum` for quantities that should accumulate across source cells;
- use `modal` for categorical rasters; and
- use minima, maxima, or medians only when those summaries answer the
  research question.

When the source raster is coarser than the target grid, `disagg_method`
controls interpolation. Nearest-neighbor interpolation is appropriate
for categories, while bilinear or cubic interpolation may suit
continuous data.

## Multiple layers and time

Multi-layer rasters require one date or year per layer unless dates are
handled by
[`pg_from_netcdf()`](https://christianoswald.github.io/priogridR/reference/pg_from_netcdf.md).

``` r

temperature_series <- c(temperature, temperature + 1)

temperature_time <- pg_from_raster(
  x = temperature_series,
  variable = "temperature",
  aggregation = "mean",
  time = c(2020, 2021),
  config = config
)

head(temperature_time)
```

Use `layer` to select a subset before conversion and `na_values` to
translate source sentinel values, such as `-9999`, to `NA`.

## Return and write results

``` r

result <- pg_from_raster(
  x = temperature,
  variable = "temperature",
  aggregation = "mean",
  return = "result",
  config = config
)

result
```

``` r

pg_write_result(result, "temperature.csv")
pg_write_result(result, "temperature.tif")
```

For NetCDF variables and automatic layer-time extraction, see
[`vignette("pg_from_netcdf", package = "priogridR")`](https://christianoswald.github.io/priogridR/articles/pg_from_netcdf.md).
