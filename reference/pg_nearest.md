# Find nearest PRIO-GRID cells

Finds the nearest candidate cell centres for one or more source cells.

## Usage

``` r
pg_nearest(
  from,
  candidates,
  n = 1L,
  include_self = FALSE,
  config = priogrid::pg_current_config()
)
```

## Arguments

- from:

  Source cell IDs.

- candidates:

  Candidate destination cell IDs.

- n:

  Number of nearest candidates to return per source cell.

- include_self:

  Should a source cell be eligible as its own nearest cell?

- config:

  A PRIO-GRID configuration object.

## Value

A data frame with source and nearest cell IDs, distance in kilometres,
and rank.

## Examples

``` r
config <- priogrid::pg_config(nrow = 18, ncol = 36)
pg_nearest(1:2, candidates = 1:6, n = 2, config = config)
#>   from_pgid nearest_pgid distance_km rank
#> 1         1            2    96.79089    1
#> 2         1            3   192.85065    2
#> 3         2            3    96.79089    1
#> 4         2            1    96.79089    2
```
