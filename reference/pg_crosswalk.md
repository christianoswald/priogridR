# Construct a crosswalk from PRIO-GRID cells to polygons

Intersects configured cell polygons with a target polygon system.
Fractional assignment retains every positive-area overlap;
largest-overlap and centroid assignment return at most one target per
cell.

## Usage

``` r
pg_crosswalk(
  target,
  target_id,
  pgid = NULL,
  assignment = c("fractional", "largest", "centroid"),
  keep_unmatched = FALSE,
  missing_geometry = c("error", "drop"),
  config = priogrid::pg_current_config()
)
```

## Arguments

- target:

  An `sf` object containing polygon targets.

- target_id:

  Name of the target identifier column.

- pgid:

  Optional cell IDs. By default every configured cell is used.

- assignment:

  One of `"fractional"`, `"largest"`, or `"centroid"`.

- keep_unmatched:

  Include cells without a target match?

- missing_geometry:

  Drop empty target geometries or raise an error.

- config:

  A PRIO-GRID configuration object.

## Value

A data frame containing `pgid`, the target identifier, overlap and
allocation areas in square kilometres, and fractions of the source cell
and target polygon. Allocation area equals overlap area for fractional
assignment and the whole cell area for discrete assignments.

## Examples

``` r
config <- priogrid::pg_config(nrow = 18, ncol = 36)
target <- pg_geometry(342:344, config = config)
target$region <- c("a", "a", "b")
pg_crosswalk(target, "region", pgid = 342:344, config = config)
#>   pgid region overlap_area_km2 allocation_area_km2 cell_fraction
#> 1  342      a          1233205             1233205             1
#> 2  343      a          1233205             1233205             1
#> 3  344      b          1233205             1233205             1
#>   target_fraction
#> 1             0.5
#> 2             0.5
#> 3             1.0
```
