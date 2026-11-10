# priogridR function inventory

This inventory describes the functions in priogridR 0.6.0.9000. All exported
package functions begin with
`pg_`. The two exported S3 methods retain the names required by R's method
dispatch system.

## Public API

| Function | Purpose | Main result | Audit conclusion |
|---|---|---|---|
| `pg_create_indices()` | Create a matrix of cell identifiers using PRIO-GRID's south-west-to-north-east numbering while presenting the northern row first. | Integer matrix. | Keep. Dimension validation was added and the orientation is covered by tests. Renamed from `create_pg_indices()`. |
| `pg_id_from_coords()` | Assign coordinates to cells in a configurable grid after CRS transformation. | Integer vector. | Core foundation. Supports custom extents and projections through the configured blank grid. |
| `pg_coords_from_id()` | Return cell-centre coordinates in a requested CRS. | Data frame. | Core foundation and inverse of coordinate lookup for cell centres. |
| `pg_geometry()` | Create polygons or centre points for all or selected configured cells. | `sf` object. | Core foundation for mapping and spatial joins. |
| `pg_neighbors()` | Find first-order queen-contiguity neighbors for a cell, with optional longitude wrapping and no wrapping over the poles. | Integer vector of cell identifiers. | Keep. Edge, pole, antimeridian, and custom-dimension behavior are covered by tests. Renamed from `pgneighbors()`. |
| `pg_neighbor_table()` | Build reusable queen, rook, distance-band, or k-nearest-neighbor relationships. | Data frame of directed cell pairs, with distances where relevant. | Core spatial-context foundation. |
| `pg_weights()` | Add binary or inverse-distance weights to a neighbor table. | Weighted neighbor table. | Core spatial-context foundation with explicit row standardization. |
| `pg_spatial_lag()` | Calculate weighted neighboring-cell values within optional temporal groups. | Input data with an appended lag column. | Core spatial-context foundation; temporal isolation is tested. |
| `pg_distance()` | Calculate paired or all-combination great-circle distances between cell centres. | Data frame of cell pairs and kilometres. | Keep as a transparent distance primitive. |
| `pg_buffer_summary()` | Summarize cell values within a centre-to-centre distance radius. | Input data with an appended summary column. | Core convenience function with explicit time grouping and self inclusion. |
| `pg_nearest()` | Identify the nearest candidate cells to each source cell. | Ranked data frame with distances. | Keep as a deterministic nearest-cell helper. |
| `pg_validate_data()` | Check IDs, missing keys, duplicate panel observations, and optional completeness. | `pg_validation` object. | Core data-quality foundation. |
| `pg_complete_panel()` | Add absent cells or cell-time combinations without overwriting existing missing values. | Data frame. | Core panel foundation. |
| `pg_join()` | Join grid data with explicit relationship and unmatched-key checks. | Data frame. | Guards against accidental many-to-many expansion. |
| `pg_plot()` | Join values to configured cell polygons and produce a default map. | `ggplot` object. | Core visualization convenience function. |
| `pg_theme()` | Apply a minimal ggplot2 theme intended for PRIO-GRID maps and plots. | A ggplot2 theme object. | Keep as a small convenience function. It now has a usable default legend position. Renamed from `pgtheme()`. |
| `pg_paths()` | Construct standard raw, processed, and temporary project-data paths and optionally create them. | Named list of normalized paths. | Keep, but it is a general workflow helper rather than a spatial conversion function; reconsider if a narrower package scope is desired. |
| `pg_from_raster()` | Transform a `SpatRaster` or raster file into a configurable PRIO-GRID raster, table, or combined result. | Data frame, `SpatRaster`, or `pg_result`. | Keep. Uses the supported `priogrid` transformation API and validates variables, time, configuration, and output choices. |
| `pg_from_netcdf()` | Read a NetCDF source or `SpatRaster`, select a subdataset/layers, and convert it to PRIO-GRID. | Data frame, `SpatRaster`, or `pg_result`. | Keep. It reuses the raster conversion path, avoiding a separate transformation implementation. |
| `pg_from_points()` | Convert point-event data, coordinates, or point spatial objects to cell counts, presence, or value summaries. | Data frame, `SpatRaster`, or `pg_result`. | Keep. Point totals, required value columns, empty cells, grouping, and time mapping are handled explicitly. |
| `pg_from_vector()` | Convert point, line, or polygon vector data with geometry-appropriate aggregation rules. | Data frame, `SpatRaster`, or `pg_result`. | Keep. It is the central vector dispatcher. More fixtures for line and polygon edge cases are recommended before CRAN/JOSS submission. |
| `pg_from_table()` | Join geographically indexed tabular values to source polygons and transfer them to PRIO-GRID. | Data frame, `SpatRaster`, or `pg_result`. | Keep. It delegates geometry work to `pg_from_vector()`; more tests for duplicate and unmatched identifiers are recommended. |
| `pg_write_result()` | Write tables, rasters, or `pg_result` components to CSV, RDS, Parquet, TIFF, or VRT. | Output filename, invisibly. | Keep. It protects existing files unless overwrite is requested. Renamed from `write_pg_result()`. |

## Standard R methods

| Function | Purpose | Audit conclusion |
|---|---|---|
| `print.pg_result()` | Print a compact summary of a conversion result. | Keep. The name must follow R's `generic.class` S3 convention. |
| `as.data.frame.pg_result()` | Extract the tabular component of a conversion result. | Keep. The name must follow R's `generic.class` S3 convention. |
| `print.pg_validation()` | Print a compact validation status and issue table. | Keep. The name follows R's required S3 convention. |

## Internal conversion and aggregation functions

These are implementation details and are not exported.

| Function | Purpose |
|---|---|
| `aggregate_pg_points()` | Assign points to cells and summarize count, presence, sum, mean, minimum, or maximum. |
| `aggregate_pg_lines()` | Intersect lines with cells and summarize length, length density, feature count, or presence. |
| `aggregate_pg_polygons()` | Intersect polygons with cells and summarize area, coverage, counts, or value-based statistics. |
| `group_rows()` | Split row indices by one or more grouping columns. |
| `validate_geodesic_engine()` | Require the s2 engine for area or length calculations on longitude/latitude geometries. |
| `geometry_area_m2()` | Calculate geometry area in square metres. |
| `geometry_length_m()` | Calculate geometry length in metres. |
| `empty_pg_data()` | Construct an empty result with the expected columns and types. |
| `summarise_point_groups()` | Apply the requested point aggregation within grouped cells. |
| `fill_empty_pg_cells()` | Add meaningful zero values for unobserved cells in count, presence, and sum outputs. |
| `pg_data_to_raster()` | Convert cell-level tabular output into one or more PRIO-GRID raster layers. |
| `finalize_pg_output()` | Assemble the requested return type and optionally write it to disk. |

## Internal input and adapter functions

| Function | Purpose |
|---|---|
| `read_raster_input()` | Accept a `SpatRaster` or read one or more raster paths. |
| `read_vector_input()` | Accept `sf`/`SpatVector` data or read one vector path. |
| `as_point_sf()` | Convert point-compatible input, including coordinate columns, to `sf`. |
| `detect_geometry_type()` | Classify a homogeneous vector input as point, line, or polygon. |
| `pg_blank()` | Obtain the blank raster for a validated `priogrid` configuration. |
| `pg_grid_as_sf()` | Convert the configured blank grid to cell polygons with `pgid`. |
| `transform_raster_to_pg()` | Call `priogrid::robust_transformation()` through one package-local adapter. |
| `raster_to_pg_data()` | Convert a transformed raster into static or time-varying tabular PRIO-GRID data. |

## Internal time, result, writing, and validation functions

| Function | Purpose |
|---|---|
| `normalize_pg_time()` | Normalize layer dates, date strings, or years to `Date`. |
| `map_dates_to_pg_intervals()` | Map observation dates to configured PRIO-GRID interval end dates. |
| `add_measurement_date()` | Add a mapped measurement date to vector observations. |
| `new_pg_result()` | Construct and validate the package's combined result object. |
| `write_pg_table()` | Write a data frame in a supported table format. |
| `write_pg_raster()` | Write a `SpatRaster` with overwrite protection. |
| `validate_variable()` | Validate a requested output variable name. |
| `validate_choice()` | Validate a scalar character choice against allowed values. |
| `validate_columns()` | Report required columns that are absent from an input. |
| `validate_output_path()` | Validate a filename and prevent accidental replacement. |
| `validate_pg_config()` | Require a configuration created by `priogrid::pg_config()`. |
| `validate_grid_dimension()` | Validate a positive integer grid dimension. |
| `pg_cell_lookup()` | Derive configured cell IDs and raster-cell positions. |
| `validate_pg_id_column()` | Require numeric PRIO-GRID identifiers. |
| `recycle_coordinate_pair()` | Recycle scalar coordinates safely for vectorized lookup. |
| `unique_helper_name()` | Create collision-free temporary column names. |
| `infer_pg_join_columns()` | Infer conventional spatial and temporal join keys. |
| `check_join_keys()` | Validate join-column presence and completeness. |
| `validate_pgid_values()` | Validate cell identifiers against a configured grid. |
| `validate_flag()` | Validate one non-missing logical argument. |
| `validate_positive_number()` | Validate finite positive or non-negative scalar values. |
| `pg_distance_matrix()` | Calculate internal centre-to-centre distance matrices in kilometres. |
| `pg_pairwise_distances()` | Calculate element-wise cell-centre distances without constructing a Cartesian matrix. |
| `empty_neighbor_table()` | Construct a typed empty neighbor table. |
| `split_panel_rows()` | Split spatial operations into temporal groups. |
| `summarise_buffer_values()` | Apply the selected buffer statistic with explicit missing-value behavior. |
| `check_distance_workload()` | Guard against accidental all-global distance matrices and direct users toward chunked workflows. |

## Test-only helper

| Function | Purpose |
|---|---|
| `test_config()` | Create a small PRIO-GRID configuration so tests run quickly. |

## Recommended next decisions

1. Decide whether `pg_paths()` belongs in the long-term public scope; it is the
   only exported function not directly concerned with grids, conversion,
   output, or visualization.
2. Add reference fixtures for line and polygon aggregation, temporal boundary
   dates, duplicate table keys, missing geometries, and multi-layer NetCDF.
3. Decide whether compatibility wrappers for the four former names are needed.
   They were deliberately omitted here to enforce the requested clean API.
4. Before submission, replace the affiliation placeholder in `paper/paper.md`,
   update `cran-comments.md`, and run checks on released, old-release, and
   development R versions.
