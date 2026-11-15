# Package index

## Convert data to PRIO-GRID

- [`pg_from_netcdf()`](https://christianoswald.github.io/priogridR/reference/pg_from_netcdf.md)
  : Convert NetCDF data to PRIO-GRID
- [`pg_from_points()`](https://christianoswald.github.io/priogridR/reference/pg_from_points.md)
  : Convert point or event data to PRIO-GRID
- [`pg_from_raster()`](https://christianoswald.github.io/priogridR/reference/pg_from_raster.md)
  : Convert raster data to PRIO-GRID
- [`pg_from_table()`](https://christianoswald.github.io/priogridR/reference/pg_from_table.md)
  : Transfer geographically indexed table data to PRIO-GRID
- [`pg_from_vector()`](https://christianoswald.github.io/priogridR/reference/pg_from_vector.md)
  : Convert vector data to PRIO-GRID

## Grid utilities

- [`pg_create_indices()`](https://christianoswald.github.io/priogridR/reference/pg_create_indices.md)
  : Create a matrix of PRIO-GRID identifiers
- [`pg_id_from_coords()`](https://christianoswald.github.io/priogridR/reference/pg_id_from_coords.md)
  : Convert coordinates to PRIO-GRID cell IDs
- [`pg_coords_from_id()`](https://christianoswald.github.io/priogridR/reference/pg_coords_from_id.md)
  : Convert PRIO-GRID cell IDs to centre coordinates
- [`pg_geometry()`](https://christianoswald.github.io/priogridR/reference/pg_geometry.md)
  : Create PRIO-GRID geometries
- [`pg_neighbors()`](https://christianoswald.github.io/priogridR/reference/pg_neighbors.md)
  : Find first-order PRIO-GRID neighbors
- [`pg_neighbor_table()`](https://christianoswald.github.io/priogridR/reference/pg_neighbor_table.md)
  : Build a PRIO-GRID neighbor table
- [`pg_weights()`](https://christianoswald.github.io/priogridR/reference/pg_weights.md)
  : Create spatial weights
- [`pg_spatial_lag()`](https://christianoswald.github.io/priogridR/reference/pg_spatial_lag.md)
  : Calculate a spatial lag
- [`pg_distance()`](https://christianoswald.github.io/priogridR/reference/pg_distance.md)
  : Calculate distances between PRIO-GRID cells
- [`pg_buffer_summary()`](https://christianoswald.github.io/priogridR/reference/pg_buffer_summary.md)
  : Summarize values around PRIO-GRID cells
- [`pg_nearest()`](https://christianoswald.github.io/priogridR/reference/pg_nearest.md)
  : Find nearest PRIO-GRID cells

## Data foundations

- [`pg_validate_data()`](https://christianoswald.github.io/priogridR/reference/pg_validate_data.md)
  [`print(`*`<pg_validation>`*`)`](https://christianoswald.github.io/priogridR/reference/pg_validate_data.md)
  : Validate PRIO-GRID data
- [`pg_complete_panel()`](https://christianoswald.github.io/priogridR/reference/pg_complete_panel.md)
  : Complete a PRIO-GRID panel
- [`pg_join()`](https://christianoswald.github.io/priogridR/reference/pg_join.md)
  : Safely join PRIO-GRID data

## Temporal utilities

- [`pg_temporal_lag()`](https://christianoswald.github.io/priogridR/reference/pg_temporal_lag.md)
  : Lag values within PRIO-GRID cells
- [`pg_temporal_lead()`](https://christianoswald.github.io/priogridR/reference/pg_temporal_lead.md)
  : Lead values within PRIO-GRID cells
- [`pg_temporal_change()`](https://christianoswald.github.io/priogridR/reference/pg_temporal_change.md)
  : Calculate within-cell temporal change
- [`pg_rolling_summary()`](https://christianoswald.github.io/priogridR/reference/pg_rolling_summary.md)
  : Calculate rolling summaries within PRIO-GRID cells
- [`pg_time_since()`](https://christianoswald.github.io/priogridR/reference/pg_time_since.md)
  : Calculate time since the most recent within-cell event

## Aggregation and cross-level workflows

- [`pg_aggregate()`](https://christianoswald.github.io/priogridR/reference/pg_aggregate.md)
  : Aggregate PRIO-GRID data by explicit groups
- [`pg_crosswalk()`](https://christianoswald.github.io/priogridR/reference/pg_crosswalk.md)
  : Construct a crosswalk from PRIO-GRID cells to polygons
- [`pg_area_weight()`](https://christianoswald.github.io/priogridR/reference/pg_area_weight.md)
  : Transfer cell values to polygons with explicit area weights
- [`pg_to_country()`](https://christianoswald.github.io/priogridR/reference/pg_to_country.md)
  : Aggregate PRIO-GRID values to supplied country boundaries
- [`pg_change_resolution()`](https://christianoswald.github.io/priogridR/reference/pg_change_resolution.md)
  : Transfer PRIO-GRID values between configured resolutions
- [`pg_compare_resolutions()`](https://christianoswald.github.io/priogridR/reference/pg_compare_resolutions.md)
  : Compare values represented on a common grid

## Visualization and workflow

- [`pg_plot()`](https://christianoswald.github.io/priogridR/reference/pg_plot.md)
  : Plot PRIO-GRID data
- [`pg_paths()`](https://christianoswald.github.io/priogridR/reference/pg_paths.md)
  : Construct standard project data paths
- [`pg_theme()`](https://christianoswald.github.io/priogridR/reference/pg_theme.md)
  : A theme for plotting PRIO-GRID data

## Results and output

- [`pg_write_result()`](https://christianoswald.github.io/priogridR/reference/pg_write_result.md)
  : Write a PRIO-GRID conversion result
- [`print(`*`<pg_result>`*`)`](https://christianoswald.github.io/priogridR/reference/print.pg_result.md)
  : Print a PRIO-GRID conversion result
- [`as.data.frame(`*`<pg_result>`*`)`](https://christianoswald.github.io/priogridR/reference/as.data.frame.pg_result.md)
  : Convert a PRIO-GRID result to a data frame
