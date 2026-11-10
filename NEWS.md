# priogridR 0.6.0.9000

## Development infrastructure

* Started the development cycle following the 0.6.0 release.
* Expanded offline tests for raster, NetCDF, vector, and geographically
  indexed table conversion, including geometry, temporal, return-type, and
  validation cases.
* Standardized GitHub Actions on `actions/checkout@v6` and narrowed read-only
  workflow permissions.

## Breaking changes

* Removed the unused bundled `priogrid` data object. Use `pg_geometry()` for
  configured cell polygons or centre points and the official `priogrid`
  package for official PRIO-GRID data and metadata.

## Documentation

* Expanded the JOSS paper draft with state-of-the-field, software-design,
  research-impact, and AI-usage-disclosure sections.

# priogridR 0.6.0

## New functionality

* Added `pg_neighbor_table()` for reusable queen, rook, distance-band, and
  k-nearest-neighbor definitions.
* Added `pg_weights()` for binary and inverse-distance spatial weights with
  optional row standardization.
* Added `pg_spatial_lag()` for cell-level and cell-period spatial lags without
  leakage across temporal groups.
* Added `pg_distance()` and `pg_nearest()` for cell-centre distance and nearest
  neighbor workflows.
* Added `pg_buffer_summary()` for cell-level summaries within explicitly
  defined distance buffers.

## Documentation and quality

* Added a spatial-context vignette with end-to-end examples.
* Added tests for contiguity, antimeridian behavior, candidate restrictions,
  distance calculations, weight construction, temporal isolation, missing
  values, buffer summaries, and input validation.
* Linked the README license badge to the bundled license to avoid dependence
  on an external license page during URL checks.

# priogridR 0.5.1

## Documentation

* Added executable reference examples for the point, vector, and table
  converters, project paths, and result writing.
* Added guarded interactive examples for raster and NetCDF conversion, whose
  execution requires a configured `priogrid` working directory.
* Added focused vignettes for grid identifiers and neighborhoods, and for
  structured results, output, project paths, and visualization.
* Ensured that every public function has a reference example and that every
  public function group has focused vignette coverage.

# priogridR 0.5.0

## New functionality

* Added `pg_id_from_coords()` and `pg_coords_from_id()` for converting between
  coordinates and configured PRIO-GRID cell identifiers.
* Added `pg_geometry()` for creating polygon or centre-point geometries.
* Added `pg_validate_data()` for checking identifiers, panel keys, duplicates,
  and completeness.
* Added `pg_complete_panel()` for explicitly completing cells and cell-time
  combinations.
* Added `pg_join()` for relationship-checked joins that guard against accidental
  many-to-many expansion.
* Added `pg_plot()` for quickly mapping cell-level variables.

## Improvements

* Added a grid-foundations vignette and comprehensive tests for the new API.
* Extended the function inventory and pkgdown reference organization.

# priogridR 0.4.1

## Improvements

* Made the raster and NetCDF vignettes portable across local, GitHub Actions,
  and CRAN build environments by avoiding changes to persistent `priogrid`
  configuration during rendering.

# priogridR 0.4.0

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
* Added focused workflow vignettes for every `pg_from_*()` converter.

## Improvements

* Corrected polar behavior in neighborhood lookup while retaining optional
  longitudinal wrapping.
* Added validation for grid dimensions and function arguments.
* Added metric/geodesic handling for polygon areas and line lengths.
* Made raster and NetCDF vignettes self-contained by using temporary
  PRIO-GRID working directories during rendering.
* Improved documentation and package organization for eventual CRAN and JOSS
  submission.

