# Grid identifiers and neighborhoods

``` r

library(priogridR)
```

PRIO-GRID cell identifiers increase from west to east and then from
south to north. The utility functions in this vignette expose that
indexing convention and make local neighborhood operations explicit.

## Identifier matrices

[`pg_create_indices()`](https://christianoswald.github.io/priogridR/reference/pg_create_indices.md)
creates a matrix with north at the top, as grids are normally displayed,
even though numbering starts in the south-west.

``` r

indices <- pg_create_indices(nrow = 3, ncol = 4)
indices
#>      [,1] [,2] [,3] [,4]
#> [1,]    9   10   11   12
#> [2,]    5    6    7    8
#> [3,]    1    2    3    4
```

The south-western cell is therefore in the bottom-left matrix position.

``` r

indices[3, 1]
#> [1] 1
indices[1, 4]
#> [1] 12
```

## First-order neighbors

[`pg_neighbors()`](https://christianoswald.github.io/priogridR/reference/pg_neighbors.md)
returns queen-contiguity neighbors: cells sharing an edge or a corner
with the selected cell.

``` r

pg_neighbors(6, nrow = 3, ncol = 4)
#> [1]  9 10 11  5  7  1  2  3
```

Longitude wraps across the antimeridian by default. Latitude does not
wrap across either pole.

``` r

pg_neighbors(1, nrow = 3, ncol = 4)
#> [1] 8 5 6 4 2
pg_neighbors(1, nrow = 3, ncol = 4, wrap_longitude = FALSE)
#> [1] 5 6 2
```

Set `wrap_longitude = FALSE` for regional grids whose eastern and
western edges should not be treated as adjacent.

## Connect IDs to locations

For configured grids,
[`pg_coords_from_id()`](https://christianoswald.github.io/priogridR/reference/pg_coords_from_id.md)
and
[`pg_geometry()`](https://christianoswald.github.io/priogridR/reference/pg_geometry.md)
translate these abstract identifiers into centre coordinates or spatial
features.

``` r

config <- priogrid::pg_config(nrow = 18, ncol = 36, verbose = FALSE)

pg_coords_from_id(1:3, config = config)
#>   pgid xcoord ycoord
#> 1    1   -175    -85
#> 2    2   -165    -85
#> 3    3   -155    -85
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

See
[`vignette("grid-foundations", package = "priogridR")`](https://christianoswald.github.io/priogridR/articles/grid-foundations.md)
for coordinate assignment, panel validation, completion, safe joins, and
mapping. See
[`vignette("spatial-context", package = "priogridR")`](https://christianoswald.github.io/priogridR/articles/spatial-context.md)
for reusable neighbor tables, spatial weights and lags, distance
calculations, nearest cells, and buffer summaries.
