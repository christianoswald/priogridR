# Convert PRIO-GRID cell IDs to centre coordinates

Returns the centre coordinates of cells in a configured PRIO-GRID.

## Usage

``` r
pg_coords_from_id(
  pgid,
  crs = 4326,
  invalid = c("error", "NA"),
  config = priogrid::pg_current_config()
)
```

## Arguments

- pgid:

  Numeric vector of PRIO-GRID cell IDs.

- crs:

  Coordinate reference system for the returned coordinates. Any value
  accepted by
  [`sf::st_crs()`](https://r-spatial.github.io/sf/reference/st_crs.html)
  may be used.

- invalid:

  How unknown or missing IDs should be handled: raise an error or return
  missing coordinates.

- config:

  A PRIO-GRID configuration object.

## Value

A data frame with `pgid`, `xcoord`, and `ycoord`.

## Examples

``` r
config <- priogrid::pg_config(nrow = 18, ncol = 36)
pg_coords_from_id(1:3, config = config)
#>   pgid xcoord ycoord
#> 1    1   -175    -85
#> 2    2   -165    -85
#> 3    3   -155    -85
```
