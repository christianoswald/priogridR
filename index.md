# priogridR

`priogridR` provides a consistent interface for working with PRIO-GRID
data. It combines grid utilities with general converters that transfer
raster, vector, point-event, NetCDF, and geographically indexed tabular
data to a configurable PRIO-GRID.

The package builds on the official
[`priogrid`](https://prio-data.github.io/priogrid/) package for grid
definitions and raster transformations.

## Installation

The package is under active development and is not yet available from
CRAN. Install the development version from GitHub with:

``` r

# install.packages("pak")
pak::pak("christianoswald/priogridR")
```

## Public interface

All user-facing functions begin with `pg_` and use snake case:

- [`pg_from_raster()`](https://christianoswald.github.io/priogridR/reference/pg_from_raster.md)
  converts raster layers.
- [`pg_from_vector()`](https://christianoswald.github.io/priogridR/reference/pg_from_vector.md)
  converts point, line, or polygon features.
- [`pg_from_points()`](https://christianoswald.github.io/priogridR/reference/pg_from_points.md)
  is a convenience wrapper for event or coordinate data.
- [`pg_from_netcdf()`](https://christianoswald.github.io/priogridR/reference/pg_from_netcdf.md)
  converts NetCDF variables and layers.
- [`pg_from_table()`](https://christianoswald.github.io/priogridR/reference/pg_from_table.md)
  transfers geographically indexed tabular data.
- [`pg_create_indices()`](https://christianoswald.github.io/priogridR/reference/pg_create_indices.md)
  creates PRIO-GRID identifier matrices.
- [`pg_neighbors()`](https://christianoswald.github.io/priogridR/reference/pg_neighbors.md)
  returns first-order neighboring cells.
- [`pg_paths()`](https://christianoswald.github.io/priogridR/reference/pg_paths.md)
  constructs reproducible project paths.
- [`pg_theme()`](https://christianoswald.github.io/priogridR/reference/pg_theme.md)
  supplies a map-oriented ggplot2 theme.
- [`pg_write_result()`](https://christianoswald.github.io/priogridR/reference/pg_write_result.md)
  writes conversion outputs.

## Example

``` r

library(priogridR)

pg_create_indices(nrow = 3, ncol = 3)
pg_neighbors(5, nrow = 3, ncol = 3)
```

Point-event data can be aggregated using the temporal and spatial
settings in a PRIO-GRID configuration:

``` r

events <- data.frame(
  longitude = c(10, 10.1, 20),
  latitude = c(50, 50.1, 60),
  event_date = as.Date(c("2020-01-01", "2020-03-01", "2021-06-01"))
)

config <- priogrid::pg_config(
  temporal_resolution = "1 year",
  start_date = as.Date("2020-12-31"),
  end_date = as.Date("2021-12-31")
)

event_counts <- pg_from_points(
  x = events,
  variable = "event_count",
  longitude = "longitude",
  latitude = "latitude",
  aggregation = "count",
  time_column = "event_date",
  config = config
)
```

See
[`vignette("getting-started", package = "priogridR")`](https://christianoswald.github.io/priogridR/articles/getting-started.md)
and
[`vignette("conversion-workflows", package = "priogridR")`](https://christianoswald.github.io/priogridR/articles/conversion-workflows.md)
for additional examples.

## Contributing

Bug reports, feature requests, documentation improvements, and code
contributions are welcome. See `CONTRIBUTING.md` and
`CODE_OF_CONDUCT.md`.

## License

`priogridR` is licensed under GPL (\>= 3).
