# Calculate distances between PRIO-GRID cells

Calculates great-circle distances between cell centres.

## Usage

``` r
pg_distance(
  from,
  to,
  pairwise = TRUE,
  config = priogrid::pg_current_config()
)
```

## Arguments

- from:

  Source cell IDs.

- to:

  Destination cell IDs.

- pairwise:

  If `TRUE`, calculate element-wise distances with safe scalar
  recycling. If `FALSE`, calculate every source-destination combination.

- config:

  A PRIO-GRID configuration object.

## Value

A data frame with source and destination IDs and `distance_km`.

## Examples

``` r
config <- priogrid::pg_config(nrow = 18, ncol = 36)
pg_distance(1:2, 2:3, config = config)
#>   from_pgid to_pgid distance_km
#> 1         1       2    96.79089
#> 2         2       3    96.79089
pg_distance(1:2, 1:3, pairwise = FALSE, config = config)
#>   from_pgid to_pgid distance_km
#> 1         1       1     0.00000
#> 2         1       2    96.79089
#> 3         1       3   192.85065
#> 4         2       1    96.79089
#> 5         2       2     0.00000
#> 6         2       3    96.79089
```
