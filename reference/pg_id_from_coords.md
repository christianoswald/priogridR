# Convert coordinates to PRIO-GRID cell IDs

Assigns coordinates to cells in a configured PRIO-GRID. Coordinates are
transformed to the grid projection before cell lookup.

## Usage

``` r
pg_id_from_coords(
  longitude,
  latitude,
  crs = 4326,
  outside = c("NA", "error"),
  config = priogrid::pg_current_config()
)
```

## Arguments

- longitude, latitude:

  Numeric coordinate vectors. Vectors must have equal lengths, or one
  may have length one.

- crs:

  Coordinate reference system of the supplied coordinates. Any value
  accepted by
  [`sf::st_crs()`](https://r-spatial.github.io/sf/reference/st_crs.html)
  may be used.

- outside:

  How coordinates outside the configured grid should be handled: return
  `NA` or raise an error.

- config:

  A PRIO-GRID configuration object.

## Value

An integer vector of PRIO-GRID cell IDs.

## Examples

``` r
config <- priogrid::pg_config(nrow = 18, ncol = 36)
pg_id_from_coords(0, 0, config = config)
#> [1] 307
```
