# priogridR

`priogridR` provides a consistent interface for working with PRIO-GRID
data. It combines grid utilities with general converters that transfer
raster, vector, point-event, NetCDF, and geographically indexed tabular
data to a configurable PRIO-GRID. It also supports coordinate lookup,
geometry creation, panel validation and completion, safe joins, and
rapid mapping.

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
- [`pg_id_from_coords()`](https://christianoswald.github.io/priogridR/reference/pg_id_from_coords.md)
  and
  [`pg_coords_from_id()`](https://christianoswald.github.io/priogridR/reference/pg_coords_from_id.md)
  convert between locations and cell identifiers.
- [`pg_geometry()`](https://christianoswald.github.io/priogridR/reference/pg_geometry.md)
  creates cell polygons or centre points.
- [`pg_neighbors()`](https://christianoswald.github.io/priogridR/reference/pg_neighbors.md)
  returns first-order neighboring cells.
- [`pg_validate_data()`](https://christianoswald.github.io/priogridR/reference/pg_validate_data.md)
  checks cell and panel structure.
- [`pg_complete_panel()`](https://christianoswald.github.io/priogridR/reference/pg_complete_panel.md)
  creates complete cell or cell-time panels.
- [`pg_join()`](https://christianoswald.github.io/priogridR/reference/pg_join.md)
  performs relationship-checked joins.
- [`pg_plot()`](https://christianoswald.github.io/priogridR/reference/pg_plot.md)
  maps cell-level variables.
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
```

``` R
##      [,1] [,2] [,3]
## [1,]    7    8    9
## [2,]    4    5    6
## [3,]    1    2    3
```

``` r

pg_neighbors(5, nrow = 3, ncol = 3)
```

``` R
## [1] 7 8 9 4 6 1 2 3
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
for an introduction and a guide to choosing a converter. The package
website also provides a focused article for every `pg_from_*()`
function.

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

The bundled `priogrid` data object contains PRIO-GRID cell identifiers,
coordinates, and geometries derived from the PRIO-GRID dataset and is
made available under the [Open Data Commons Attribution License (ODC-By)
1.0](https://opendatacommons.org/licenses/by/1-0/). Other data accessed,
converted, or analyzed with `priogridR` remain subject to their original
providers’ licenses, documentation, citation requirements, and terms of
use.

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
