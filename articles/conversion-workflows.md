# Choosing a PRIO-GRID conversion workflow

`priogridR` provides one conversion function for each common source-data
format. All converters use a
[`priogrid::pg_config()`](http://prio-data.github.io/priogrid/reference/pg_config.md)
object as the source of truth for the target grid and temporal
resolution.

## Choose a converter

| Source data | Function | Typical task |
|----|----|----|
| Point events or coordinate columns | [`pg_from_points()`](https://christianoswald.github.io/priogridR/reference/pg_from_points.md) | Count events or summarize their values by cell and period |
| Raster layers | [`pg_from_raster()`](https://christianoswald.github.io/priogridR/reference/pg_from_raster.md) | Align continuous or categorical raster values to PRIO-GRID |
| Point, line, or polygon geometry | [`pg_from_vector()`](https://christianoswald.github.io/priogridR/reference/pg_from_vector.md) | Calculate counts, lengths, areas, coverage, or weighted values |
| NetCDF variables | [`pg_from_netcdf()`](https://christianoswald.github.io/priogridR/reference/pg_from_netcdf.md) | Select variables and layers before raster conversion |
| Values indexed by geographic units | [`pg_from_table()`](https://christianoswald.github.io/priogridR/reference/pg_from_table.md) | Join a table to polygons and transfer the values to cells |

The detailed guides are available through:

``` r

vignette("pg_from_points", package = "priogridR")
vignette("pg_from_raster", package = "priogridR")
vignette("pg_from_vector", package = "priogridR")
vignette("pg_from_netcdf", package = "priogridR")
vignette("pg_from_table", package = "priogridR")
```

## A shared configuration

A small configuration is useful for examples and exploratory work:

``` r

config <- priogrid::pg_config(
  nrow = 18,
  ncol = 36,
  temporal_resolution = "1 year",
  start_date = as.Date("2020-12-31"),
  end_date = as.Date("2022-12-31"),
  verbose = FALSE
)
```

Use the default
[`priogrid::pg_current_config()`](http://prio-data.github.io/priogrid/reference/pg_current_config.md)
when the official global half-degree grid is required.

## Common return types

Every converter accepts a `return` argument:

- `return = "data"` returns a cell-level data frame;
- `return = "raster"` returns a
  [`terra::SpatRaster`](https://rspatial.github.io/terra/reference/SpatRaster-class.html);
  and
- `return = "result"` returns a `pg_result` containing data, raster, and
  conversion metadata.

The default is `"data"`. Use
[`pg_write_result()`](https://christianoswald.github.io/priogridR/reference/pg_write_result.md)
to save tabular or raster outputs, or pass `filename` directly to a
converter.

## General advice

Check the coordinate reference system before conversion, distinguish
missing values from meaningful zeros, and choose an aggregation rule
that matches the meaning of the source variable. In particular, totals
generally require a different transfer rule from rates, proportions, or
categories.
