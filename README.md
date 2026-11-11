
<!-- README.md is generated from README.Rmd. Edit README.Rmd, not README.md. -->

# priogridR

<!-- badges: start -->

[![R-CMD-check](https://github.com/christianoswald/priogridR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/christianoswald/priogridR/actions/workflows/R-CMD-check.yaml)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![License: GPL
v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](LICENSE.md)
[![Codecov test
coverage](https://codecov.io/gh/christianoswald/priogridR/branch/main/graph/badge.svg)](https://app.codecov.io/gh/christianoswald/priogridR)
<!-- badges: end -->

`priogridR` provides a consistent interface for working with PRIO-GRID
data. It combines grid utilities with general converters that transfer
raster, vector, point-event, NetCDF, and geographically indexed tabular
data to a configurable PRIO-GRID. It also supports coordinate lookup,
geometry creation, spatial neighborhoods, weights, spatial and temporal
lags, rolling summaries, temporal changes, event timing, distances and
buffer summaries, panel validation and completion, safe joins, and rapid
mapping.

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

- `pg_from_raster()` converts raster layers.
- `pg_from_vector()` converts point, line, or polygon features.
- `pg_from_points()` is a convenience wrapper for event or coordinate
  data.
- `pg_from_netcdf()` converts NetCDF variables and layers.
- `pg_from_table()` transfers geographically indexed tabular data.
- `pg_create_indices()` creates PRIO-GRID identifier matrices.
- `pg_id_from_coords()` and `pg_coords_from_id()` convert between
  locations and cell identifiers.
- `pg_geometry()` creates cell polygons or centre points.
- `pg_neighbors()` returns first-order neighboring cells.
- `pg_neighbor_table()` creates reusable contiguity, distance-band, or
  nearest-neighbor relationships.
- `pg_weights()` constructs binary or inverse-distance spatial weights.
- `pg_spatial_lag()` calculates weighted neighboring-cell values.
- `pg_temporal_lag()` and `pg_temporal_lead()` shift observations within
  cells.
- `pg_temporal_change()` calculates differences, percentage changes, or
  log differences.
- `pg_rolling_summary()` calculates explicitly aligned within-cell
  windows.
- `pg_time_since()` measures periods or days since the latest event.
- `pg_distance()`, `pg_buffer_summary()`, and `pg_nearest()` support
  common spatial-context workflows.
- `pg_validate_data()` checks cell and panel structure.
- `pg_complete_panel()` creates complete cell or cell-time panels.
- `pg_join()` performs relationship-checked joins.
- `pg_plot()` maps cell-level variables.
- `pg_paths()` constructs reproducible project paths.
- `pg_theme()` supplies a map-oriented ggplot2 theme.
- `pg_write_result()` writes conversion outputs.

## Example

``` r
library(priogridR)

pg_create_indices(nrow = 3, ncol = 3)
```

    ##      [,1] [,2] [,3]
    ## [1,]    7    8    9
    ## [2,]    4    5    6
    ## [3,]    1    2    3

``` r
pg_neighbors(5, nrow = 3, ncol = 3)
```

    ## [1] 7 8 9 4 6 1 2 3

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

See `vignette("getting-started", package = "priogridR")` and
`vignette("conversion-workflows", package = "priogridR")` for an
introduction and a guide to choosing a converter. The package website
also provides a focused article for every `pg_from_*()` function.

## Package direction

Future convenience functions will build on the same principles:
reproducible inputs, explicit spatial and temporal configurations,
transparent transformations, and outputs that fit ordinary R workflows.
The aim is to reduce recurring data-management and spatial-processing
work for PRIO-GRID users while keeping aggregation rules, missing-data
decisions, neighborhood definitions, and other analytical choices
visible and under the researcher’s control.

Development will continue to complement the official
[`priogrid`](https://prio-data.github.io/priogrid/) package rather than
duplicate its data-access, configuration, metadata, and citation
infrastructure.

## AI-assisted development

This package has been developed with assistance from OpenAI’s ChatGPT
and Codex. AI tools have been used to support code drafting and
refactoring, test development, documentation, troubleshooting,
literature review, and discussion of package design.

All substantive design decisions, review of generated material, package
testing, and responsibility for the correctness and maintenance of
`priogridR` remain with the package author. AI-assisted contributions
are reviewed and validated through the package’s test suite, examples,
vignettes, continuous-integration workflows, and `R CMD check` before
release.

## Scope and attribution

`priogridR` is an independent community package. It is not affiliated
with or endorsed by the Peace Research Institute Oslo (PRIO) or the
developers of the official `priogrid` package.

`priogridR` does not redistribute official PRIO-GRID variables. Grid
definitions, official variables, and metadata remain available through
the official [`priogrid`](https://prio-data.github.io/priogrid/)
package. Data accessed, converted, or analyzed with `priogridR` remain
subject to their original providers’ licenses, documentation, citation
requirements, and terms of use.

Users should cite the original PRIO-GRID publication and all underlying
data sources relevant to their analyses. The citation and licensing
information provided by the official `priogrid` package remains
authoritative for official PRIO-GRID variables and source datasets.

## Contributing

Bug reports, feature requests, documentation improvements, and code
contributions are welcome. See `CONTRIBUTING.md` and
`CODE_OF_CONDUCT.md`.

## License

`priogridR` is licensed under GPL (\>= 3).
