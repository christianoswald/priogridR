# Build a PRIO-GRID neighbor table

Creates a reusable directed table of neighboring PRIO-GRID cells using
queen or rook contiguity, a distance band, or k-nearest neighbors.

## Usage

``` r
pg_neighbor_table(
  pgid = NULL,
  candidates = NULL,
  method = c("queen", "rook", "distance", "knn"),
  distance = NULL,
  k = 1L,
  include_self = FALSE,
  wrap_longitude = TRUE,
  config = priogrid::pg_current_config()
)
```

## Arguments

- pgid:

  Source cell IDs. `NULL` uses all configured cells.

- candidates:

  Candidate neighbor cell IDs. `NULL` uses all configured cells.

- method:

  Neighborhood definition: queen contiguity, rook contiguity, a distance
  band, or k-nearest neighbors.

- distance:

  Maximum great-circle distance in kilometres. Required for
  `method = "distance"`.

- k:

  Number of neighbors for `method = "knn"`.

- include_self:

  Should a cell be allowed to neighbor itself?

- wrap_longitude:

  Should contiguity wrap across the antimeridian?

- config:

  A PRIO-GRID configuration object.

## Value

A data frame with `pgid` and `neighbor_pgid`. Distance and k-nearest
tables also contain `distance_km`.

## Examples

``` r
config <- priogrid::pg_config(nrow = 18, ncol = 36)
pg_neighbor_table(20, method = "rook", config = config)
#>   pgid neighbor_pgid
#> 1   20            19
#> 2   20            21
#> 3   20            56
pg_neighbor_table(1:3, candidates = 1:6, method = "knn", k = 2,
                  config = config)
#>   pgid neighbor_pgid distance_km
#> 1    1             2    96.79089
#> 2    1             3   192.85065
#> 3    2             3    96.79089
#> 4    2             1    96.79089
#> 5    3             2    96.79089
#> 6    3             4    96.79089
```
