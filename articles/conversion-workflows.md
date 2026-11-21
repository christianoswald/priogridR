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

## Missing values and structural zeros

`priogridR` distinguishes a cell with no source observations from an
observed group whose source values are all missing. With
`keep_empty = TRUE`, an unobserved cell receives zero for point counts,
presence indicators, and sums, because zero is meaningful for those
aggregations. An observed group containing only missing source values
remains `NA`; it is not silently converted to zero.

Rows with missing values in an explicit `group_columns` variable are
retained as a missing-value group. This prevents observations from
disappearing during aggregation, but users should normally clean or
explain missing group labels before analysis.

## Temporal and geometry validation

Dates supplied through `time` or `time_column` must fall within the
intervals defined by the selected `pg_config`. Values outside that range
produce an error instead of an undated output row. Vector inputs must
have a declared CRS and non-empty, valid geometries. Repair invalid
polygons explicitly—for example with
[`sf::st_make_valid()`](https://r-spatial.github.io/sf/reference/valid.html)—so
that the analytical transformation remains visible in the research
workflow.
