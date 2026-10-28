# Converting NetCDF data

``` r

library(priogridR)
```

[`pg_from_netcdf()`](https://christianoswald.github.io/priogridR/reference/pg_from_netcdf.md)
accepts a NetCDF path or an already opened
[`terra::SpatRaster`](https://rspatial.github.io/terra/reference/SpatRaster-class.html).
It can select a NetCDF subdataset, choose layers, recover raster time
metadata, replace sentinel values, and then use the same alignment
workflow as
[`pg_from_raster()`](https://christianoswald.github.io/priogridR/reference/pg_from_raster.md).

The underlying raster transformation requires a `priogrid` working
directory. Configure a persistent project location before running the
conversion examples:

``` r

priogrid::pg_set_rawfolder("data/priogrid")
```

The conversion chunks are not evaluated while the vignette is built
because the working directory is a persistent, user-specific setting.

## An in-memory example

Using a `SpatRaster` makes this example independent of platform-specific
NetCDF drivers while exercising the complete conversion path.

``` r

config <- priogrid::pg_config(
  nrow = 18,
  ncol = 36,
  temporal_resolution = "1 year",
  start_date = as.Date("2020-12-31"),
  end_date = as.Date("2021-12-31"),
  verbose = FALSE
)

precipitation <- terra::rast(
  nrows = 18,
  ncols = 36,
  nlyrs = 2,
  xmin = -180,
  xmax = 180,
  ymin = -90,
  ymax = 90,
  crs = "EPSG:4326"
)
terra::values(precipitation) <- cbind(
  rep(10, terra::ncell(precipitation)),
  rep(12, terra::ncell(precipitation))
)
```

Supply explicit dates when the object does not contain reliable time
metadata:

``` r

precipitation_pg <- pg_from_netcdf(
  x = precipitation,
  variable = "precipitation",
  aggregation = "mean",
  time = c(2020, 2021),
  config = config
)

head(precipitation_pg)
```

## Reading a NetCDF file

When a file contains one main variable, pass its path directly:

``` r

precipitation_pg <- pg_from_netcdf(
  x = "data/raw/precipitation.nc",
  variable = "precipitation",
  aggregation = "mean",
  config = config
)
```

For files with multiple subdatasets, identify the required one with
`source_variable`:

``` r

temperature_pg <- pg_from_netcdf(
  x = "data/raw/climate.nc",
  source_variable = "temperature",
  variable = "temperature",
  aggregation = "mean",
  layer = 1:12,
  config = config
)
```

Inspect available subdatasets with
[`terra::sds()`](https://rspatial.github.io/terra/reference/sds.html) or
the file metadata before choosing `source_variable`.

## Time, layers, and missing values

If valid time metadata are present, the function uses them
automatically. Otherwise, supply one `time` value per selected layer.
The `layer` argument can select layers by position or name before time
validation.

Use `na_values` for encoded missing values:

``` r

precipitation_pg <- pg_from_netcdf(
  x = "data/raw/precipitation.nc",
  variable = "precipitation",
  aggregation = "mean",
  na_values = c(-9999, 9.96921e+36),
  config = config
)
```

Choose aggregation and disaggregation rules according to whether the
variable is continuous, cumulative, or categorical. See
[`vignette("pg_from_raster", package = "priogridR")`](https://christianoswald.github.io/priogridR/articles/pg_from_raster.md)
for detailed guidance.
