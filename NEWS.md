# priogridR 0.3.0.9000

## Breaking changes

* Standardized the public API on the `pg_` prefix and snake case.
* Renamed `create_pg_indices()` to `pg_create_indices()`.
* Renamed `pgneighbors()` to `pg_neighbors()`.
* Renamed `pgtheme()` to `pg_theme()`.
* Renamed `write_pg_result()` to `pg_write_result()`.

## New functionality

* Added converters for raster, vector, point-event, NetCDF, and geographically
  indexed tabular data.
* Added configurable temporal aggregation through PRIO-GRID configuration
  objects.
* Added structured conversion results and output helpers.
* Added tests, vignettes, continuous integration, and publication scaffolding.

## Improvements

* Corrected polar behavior in neighborhood lookup while retaining optional
  longitudinal wrapping.
* Added validation for grid dimensions and function arguments.
* Added metric/geodesic handling for polygon areas and line lengths.
* Improved documentation and package organization for eventual CRAN and JOSS
  submission.

