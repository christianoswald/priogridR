# Create PRIO-GRID geometries

Creates polygon or centre-point geometries for all or selected cells in
a configured PRIO-GRID.

## Usage

``` r
pg_geometry(
  pgid = NULL,
  geometry = c("polygon", "point"),
  crs = NULL,
  config = priogrid::pg_current_config()
)
```

## Arguments

- pgid:

  Optional vector of cell IDs. If `NULL`, all configured cells are
  returned.

- geometry:

  Return cell `"polygon"` geometries or centre `"point"` geometries.

- crs:

  Optional output coordinate reference system. By default the grid CRS
  is retained.

- config:

  A PRIO-GRID configuration object.

## Value

An `sf` object with one row per requested cell.

## Examples

``` r
config <- priogrid::pg_config(nrow = 18, ncol = 36)
pg_geometry(1:3, geometry = "point", config = config)
#> Simple feature collection with 3 features and 1 field
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: -175 ymin: -85 xmax: -155 ymax: -85
#> Geodetic CRS:  +proj=longlat +datum=WGS84 +no_defs
#>   pgid         geometry
#> 1    1 POINT (-175 -85)
#> 2    2 POINT (-165 -85)
#> 3    3 POINT (-155 -85)
```
